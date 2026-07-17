package com.smarttodo.application.service;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.exception.EmailAlreadyExistsException;
import com.smarttodo.application.exception.InvalidCredentialsException;
import com.smarttodo.application.exception.InvalidRefreshTokenException;
import com.smarttodo.application.port.in.AuthResult;
import com.smarttodo.application.port.in.LoginUseCase.LoginCommand;
import com.smarttodo.application.port.in.RegisterUseCase.RegisterCommand;
import com.smarttodo.application.port.out.AccessTokenPort;
import com.smarttodo.application.port.out.PasswordHasherPort;
import com.smarttodo.application.port.out.RefreshTokenRepositoryPort;
import com.smarttodo.application.port.out.UserRepositoryPort;
import com.smarttodo.domain.model.RefreshToken;
import com.smarttodo.domain.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AuthServiceTest {

	private UserRepositoryPort userRepository;
	private PasswordHasherPort passwordHasher;
	private AccessTokenPort accessTokenPort;
	private RefreshTokenRepositoryPort refreshTokenRepository;
	private AuthService authService;

	private final User existingUser = User.createNew("mario@example.com", "$bcrypt$hash", "Mario");

	@BeforeEach
	void setUp() {
		userRepository = mock(UserRepositoryPort.class);
		passwordHasher = mock(PasswordHasherPort.class);
		accessTokenPort = mock(AccessTokenPort.class);
		refreshTokenRepository = mock(RefreshTokenRepositoryPort.class);
		authService = new AuthService(userRepository, passwordHasher, accessTokenPort,
				refreshTokenRepository);

		when(accessTokenPort.generateAccessToken(any(UUID.class), anyString())).thenReturn("jwt-token");
		when(accessTokenPort.accessTokenTtl()).thenReturn(Duration.ofMinutes(15));
		when(accessTokenPort.refreshTokenTtl()).thenReturn(Duration.ofDays(7));
		when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(inv -> inv.getArgument(0));
	}

	// --- register ---

	@Test
	void should_hashPasswordAndPersistUser_when_registering() {
		when(userRepository.existsByEmail("mario@example.com")).thenReturn(false);
		when(passwordHasher.hash("Password1!")).thenReturn("$bcrypt$hash");
		when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

		AuthResult result = authService.register(
				new RegisterCommand("mario@example.com", "Password1!", "Mario"));

		ArgumentCaptor<User> savedUser = ArgumentCaptor.forClass(User.class);
		verify(userRepository).save(savedUser.capture());
		assertThat(savedUser.getValue().passwordHash()).isEqualTo("$bcrypt$hash");

		assertThat(result.accessToken()).isEqualTo("jwt-token");
		assertThat(result.refreshToken()).isNotBlank();
		assertThat(result.expiresInSeconds()).isEqualTo(900);
	}

	@Test
	void should_rejectRegistration_when_emailAlreadyExists() {
		when(userRepository.existsByEmail("taken@example.com")).thenReturn(true);

		assertThatThrownBy(() -> authService.register(
				new RegisterCommand("taken@example.com", "Password1!", "Chi")))
				.isInstanceOf(EmailAlreadyExistsException.class);

		verify(userRepository, never()).save(any());
	}

	// --- login ---

	@Test
	void should_issueTokenPairAndStoreHashedRefreshToken_when_loginSucceeds() {
		when(userRepository.findByEmail("mario@example.com")).thenReturn(Optional.of(existingUser));
		when(passwordHasher.matches("Password1!", "$bcrypt$hash")).thenReturn(true);

		AuthResult result = authService.login(new LoginCommand("mario@example.com", "Password1!"));

		assertThat(result.accessToken()).isEqualTo("jwt-token");
		assertThat(result.refreshToken()).isNotBlank();

		ArgumentCaptor<RefreshToken> stored = ArgumentCaptor.forClass(RefreshToken.class);
		verify(refreshTokenRepository).save(stored.capture());
		// only the hash is persisted, never the raw token
		assertThat(stored.getValue().tokenHash()).isNotEqualTo(result.refreshToken());
		assertThat(stored.getValue().userId()).isEqualTo(existingUser.id());
		assertThat(stored.getValue().revoked()).isFalse();
	}

	@Test
	void should_rejectLogin_when_passwordIsWrong() {
		when(userRepository.findByEmail("mario@example.com")).thenReturn(Optional.of(existingUser));
		when(passwordHasher.matches("wrong", "$bcrypt$hash")).thenReturn(false);

		assertThatThrownBy(() -> authService.login(new LoginCommand("mario@example.com", "wrong")))
				.isInstanceOf(InvalidCredentialsException.class);
	}

	@Test
	void should_rejectLogin_when_emailIsUnknown() {
		when(userRepository.findByEmail("ghost@example.com")).thenReturn(Optional.empty());

		assertThatThrownBy(() -> authService.login(new LoginCommand("ghost@example.com", "pw")))
				.isInstanceOf(InvalidCredentialsException.class);
	}

	// --- refresh ---

	@Test
	void should_rotateRefreshToken_when_refreshSucceeds() {
		when(userRepository.findByEmail("mario@example.com")).thenReturn(Optional.of(existingUser));
		when(passwordHasher.matches("Password1!", "$bcrypt$hash")).thenReturn(true);
		AuthResult loginResult = authService.login(new LoginCommand("mario@example.com", "Password1!"));
		String rawRefreshToken = loginResult.refreshToken();

		ArgumentCaptor<RefreshToken> storedAtLogin = ArgumentCaptor.forClass(RefreshToken.class);
		verify(refreshTokenRepository).save(storedAtLogin.capture());
		RefreshToken persisted = storedAtLogin.getValue();

		when(refreshTokenRepository.findByTokenHash(persisted.tokenHash()))
				.thenReturn(Optional.of(persisted));
		when(userRepository.findById(existingUser.id())).thenReturn(Optional.of(existingUser));

		AuthResult refreshed = authService.refresh(rawRefreshToken);

		assertThat(refreshed.accessToken()).isEqualTo("jwt-token");
		assertThat(refreshed.refreshToken()).isNotBlank().isNotEqualTo(rawRefreshToken);

		// old token revoked + new token stored
		ArgumentCaptor<RefreshToken> allSaves = ArgumentCaptor.forClass(RefreshToken.class);
		verify(refreshTokenRepository, atLeastOnce()).save(allSaves.capture());
		assertThat(allSaves.getAllValues())
				.anySatisfy(t -> {
					assertThat(t.id()).isEqualTo(persisted.id());
					assertThat(t.revoked()).isTrue();
				});
	}

	@Test
	void should_rejectRefresh_when_tokenIsUnknown() {
		when(refreshTokenRepository.findByTokenHash(anyString())).thenReturn(Optional.empty());

		assertThatThrownBy(() -> authService.refresh("unknown-token"))
				.isInstanceOf(InvalidRefreshTokenException.class);
	}

	@Test
	void should_rejectRefresh_when_tokenIsExpired() {
		RefreshToken expired = new RefreshToken(UUID.randomUUID(), existingUser.id(),
				"some-hash", Instant.now().minus(Duration.ofDays(1)), false, Instant.now());
		when(refreshTokenRepository.findByTokenHash(anyString())).thenReturn(Optional.of(expired));

		assertThatThrownBy(() -> authService.refresh("raw-token"))
				.isInstanceOf(InvalidRefreshTokenException.class);
	}

	@Test
	void should_rejectRefresh_when_tokenIsRevoked() {
		RefreshToken revoked = new RefreshToken(UUID.randomUUID(), existingUser.id(),
				"some-hash", Instant.now().plus(Duration.ofDays(1)), true, Instant.now());
		when(refreshTokenRepository.findByTokenHash(anyString())).thenReturn(Optional.of(revoked));

		assertThatThrownBy(() -> authService.refresh("raw-token"))
				.isInstanceOf(InvalidRefreshTokenException.class);
	}
}

package com.smarttodo.application.service;

import java.time.Duration;
import java.util.UUID;

import com.smarttodo.application.exception.EmailAlreadyExistsException;
import com.smarttodo.application.port.in.AuthResult;
import com.smarttodo.application.port.in.RegisterUseCase.RegisterCommand;
import com.smarttodo.application.port.out.AccessTokenPort;
import com.smarttodo.application.port.out.PasswordHasherPort;
import com.smarttodo.application.port.out.UserRepositoryPort;
import com.smarttodo.domain.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AuthServiceTest {

	private UserRepositoryPort userRepository;
	private PasswordHasherPort passwordHasher;
	private AccessTokenPort accessTokenPort;
	private AuthService authService;

	@BeforeEach
	void setUp() {
		userRepository = mock(UserRepositoryPort.class);
		passwordHasher = mock(PasswordHasherPort.class);
		accessTokenPort = mock(AccessTokenPort.class);
		authService = new AuthService(userRepository, passwordHasher, accessTokenPort);
	}

	@Test
	void should_hashPasswordAndPersistUser_when_registering() {
		when(userRepository.existsByEmail("mario@example.com")).thenReturn(false);
		when(passwordHasher.hash("Password1!")).thenReturn("$bcrypt$hash");
		when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));
		when(accessTokenPort.generateAccessToken(any(UUID.class), anyString())).thenReturn("jwt-token");
		when(accessTokenPort.accessTokenTtl()).thenReturn(Duration.ofMinutes(15));

		AuthResult result = authService.register(
				new RegisterCommand("mario@example.com", "Password1!", "Mario"));

		ArgumentCaptor<User> savedUser = ArgumentCaptor.forClass(User.class);
		verify(userRepository).save(savedUser.capture());
		assertThat(savedUser.getValue().passwordHash()).isEqualTo("$bcrypt$hash");
		assertThat(savedUser.getValue().email()).isEqualTo("mario@example.com");

		assertThat(result.accessToken()).isEqualTo("jwt-token");
		assertThat(result.expiresInSeconds()).isEqualTo(900);
		assertThat(result.user().displayName()).isEqualTo("Mario");
	}

	@Test
	void should_rejectRegistration_when_emailAlreadyExists() {
		when(userRepository.existsByEmail("taken@example.com")).thenReturn(true);

		assertThatThrownBy(() -> authService.register(
				new RegisterCommand("taken@example.com", "Password1!", "Chi")))
				.isInstanceOf(EmailAlreadyExistsException.class);

		verify(userRepository, never()).save(any());
	}
}

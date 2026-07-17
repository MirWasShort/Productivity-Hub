package com.smarttodo.application.service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.HexFormat;

import com.smarttodo.application.exception.EmailAlreadyExistsException;
import com.smarttodo.application.exception.InvalidCredentialsException;
import com.smarttodo.application.exception.InvalidRefreshTokenException;
import com.smarttodo.application.port.in.AuthResult;
import com.smarttodo.application.port.in.LoginUseCase;
import com.smarttodo.application.port.in.RefreshTokenUseCase;
import com.smarttodo.application.port.in.RegisterUseCase;
import com.smarttodo.application.port.out.AccessTokenPort;
import com.smarttodo.application.port.out.PasswordHasherPort;
import com.smarttodo.application.port.out.RefreshTokenRepositoryPort;
import com.smarttodo.application.port.out.UserRepositoryPort;
import com.smarttodo.domain.model.RefreshToken;
import com.smarttodo.domain.model.User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService implements RegisterUseCase, LoginUseCase, RefreshTokenUseCase {

	private static final SecureRandom SECURE_RANDOM = new SecureRandom();

	private final UserRepositoryPort userRepository;
	private final PasswordHasherPort passwordHasher;
	private final AccessTokenPort accessTokenPort;
	private final RefreshTokenRepositoryPort refreshTokenRepository;

	public AuthService(UserRepositoryPort userRepository, PasswordHasherPort passwordHasher,
			AccessTokenPort accessTokenPort, RefreshTokenRepositoryPort refreshTokenRepository) {
		this.userRepository = userRepository;
		this.passwordHasher = passwordHasher;
		this.accessTokenPort = accessTokenPort;
		this.refreshTokenRepository = refreshTokenRepository;
	}

	@Override
	@Transactional
	public AuthResult register(RegisterCommand command) {
		if (userRepository.existsByEmail(command.email())) {
			throw new EmailAlreadyExistsException(command.email());
		}

		User user = User.createNew(
				command.email(),
				passwordHasher.hash(command.password()),
				command.displayName());
		User saved = userRepository.save(user);

		return issueTokens(saved);
	}

	@Override
	@Transactional
	public AuthResult login(LoginCommand command) {
		User user = userRepository.findByEmail(command.email())
				.orElseThrow(InvalidCredentialsException::new);

		if (!passwordHasher.matches(command.password(), user.passwordHash())) {
			throw new InvalidCredentialsException();
		}

		return issueTokens(user);
	}

	@Override
	@Transactional
	public AuthResult refresh(String rawRefreshToken) {
		RefreshToken stored = refreshTokenRepository.findByTokenHash(sha256(rawRefreshToken))
				.orElseThrow(InvalidRefreshTokenException::new);

		if (!stored.isUsable()) {
			throw new InvalidRefreshTokenException();
		}

		User user = userRepository.findById(stored.userId())
				.orElseThrow(InvalidRefreshTokenException::new);

		refreshTokenRepository.save(stored.revoke());

		return issueTokens(user);
	}

	private AuthResult issueTokens(User user) {
		String accessToken = accessTokenPort.generateAccessToken(user.id(), user.email());

		String rawRefreshToken = generateOpaqueToken();
		refreshTokenRepository.save(RefreshToken.createNew(
				user.id(), sha256(rawRefreshToken), accessTokenPort.refreshTokenTtl()));

		return new AuthResult(accessToken, rawRefreshToken,
				accessTokenPort.accessTokenTtl().toSeconds(), user);
	}

	private static String generateOpaqueToken() {
		byte[] bytes = new byte[32];
		SECURE_RANDOM.nextBytes(bytes);
		return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
	}

	private static String sha256(String value) {
		try {
			MessageDigest digest = MessageDigest.getInstance("SHA-256");
			return HexFormat.of().formatHex(digest.digest(value.getBytes()));
		} catch (NoSuchAlgorithmException e) {
			throw new IllegalStateException("SHA-256 not available", e);
		}
	}
}

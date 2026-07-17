package com.smarttodo.application.service;

import com.smarttodo.application.exception.EmailAlreadyExistsException;
import com.smarttodo.application.port.in.AuthResult;
import com.smarttodo.application.port.in.RegisterUseCase;
import com.smarttodo.application.port.out.AccessTokenPort;
import com.smarttodo.application.port.out.PasswordHasherPort;
import com.smarttodo.application.port.out.UserRepositoryPort;
import com.smarttodo.domain.model.User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService implements RegisterUseCase {

	private final UserRepositoryPort userRepository;
	private final PasswordHasherPort passwordHasher;
	private final AccessTokenPort accessTokenPort;

	public AuthService(UserRepositoryPort userRepository, PasswordHasherPort passwordHasher,
			AccessTokenPort accessTokenPort) {
		this.userRepository = userRepository;
		this.passwordHasher = passwordHasher;
		this.accessTokenPort = accessTokenPort;
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

	private AuthResult issueTokens(User user) {
		String accessToken = accessTokenPort.generateAccessToken(user.id(), user.email());
		return new AuthResult(accessToken, accessTokenPort.accessTokenTtl().toSeconds(), user);
	}
}

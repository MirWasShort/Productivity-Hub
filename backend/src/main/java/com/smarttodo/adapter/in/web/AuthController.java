package com.smarttodo.adapter.in.web;

import com.smarttodo.adapter.in.web.dto.AuthResponse;
import com.smarttodo.adapter.in.web.dto.LoginRequest;
import com.smarttodo.adapter.in.web.dto.RefreshRequest;
import com.smarttodo.adapter.in.web.dto.RegisterRequest;
import com.smarttodo.application.port.in.AuthResult;
import com.smarttodo.application.port.in.LoginUseCase;
import com.smarttodo.application.port.in.LoginUseCase.LoginCommand;
import com.smarttodo.application.port.in.RefreshTokenUseCase;
import com.smarttodo.application.port.in.RegisterUseCase;
import com.smarttodo.application.port.in.RegisterUseCase.RegisterCommand;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

	private final RegisterUseCase registerUseCase;
	private final LoginUseCase loginUseCase;
	private final RefreshTokenUseCase refreshTokenUseCase;

	public AuthController(RegisterUseCase registerUseCase, LoginUseCase loginUseCase,
			RefreshTokenUseCase refreshTokenUseCase) {
		this.registerUseCase = registerUseCase;
		this.loginUseCase = loginUseCase;
		this.refreshTokenUseCase = refreshTokenUseCase;
	}

	@PostMapping("/register")
	@ResponseStatus(HttpStatus.CREATED)
	public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
		AuthResult result = registerUseCase.register(
				new RegisterCommand(request.email(), request.password(), request.displayName()));
		return AuthResponse.from(result);
	}

	@PostMapping("/login")
	public AuthResponse login(@Valid @RequestBody LoginRequest request) {
		AuthResult result = loginUseCase.login(
				new LoginCommand(request.email(), request.password()));
		return AuthResponse.from(result);
	}

	@PostMapping("/refresh")
	public AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
		return AuthResponse.from(refreshTokenUseCase.refresh(request.refreshToken()));
	}
}

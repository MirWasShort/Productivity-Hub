package com.smarttodo.adapter.in.web;

import com.smarttodo.adapter.in.web.dto.AuthResponse;
import com.smarttodo.adapter.in.web.dto.RegisterRequest;
import com.smarttodo.application.port.in.AuthResult;
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

	public AuthController(RegisterUseCase registerUseCase) {
		this.registerUseCase = registerUseCase;
	}

	@PostMapping("/register")
	@ResponseStatus(HttpStatus.CREATED)
	public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
		AuthResult result = registerUseCase.register(
				new RegisterCommand(request.email(), request.password(), request.displayName()));
		return AuthResponse.from(result);
	}
}

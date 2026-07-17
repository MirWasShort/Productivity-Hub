package com.smarttodo.application.port.in;

/**
 * Driving port: authenticate with email and password.
 */
public interface LoginUseCase {

	AuthResult login(LoginCommand command);

	record LoginCommand(String email, String password) {
	}
}

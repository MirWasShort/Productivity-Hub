package com.smarttodo.application.port.in;

/**
 * Driving port: register a new user account.
 */
public interface RegisterUseCase {

	AuthResult register(RegisterCommand command);

	record RegisterCommand(String email, String password, String displayName) {
	}
}

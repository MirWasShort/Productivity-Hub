package com.smarttodo.application.port.out;

/**
 * Driven port: password hashing, so the application layer does not
 * depend on a concrete crypto library.
 */
public interface PasswordHasherPort {

	String hash(String rawPassword);

	boolean matches(String rawPassword, String hashedPassword);
}

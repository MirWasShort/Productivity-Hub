package com.smarttodo.application.port.in;

import com.smarttodo.domain.model.User;

/**
 * Outcome of a successful authentication operation.
 */
public record AuthResult(
		String accessToken,
		long expiresInSeconds,
		User user) {
}

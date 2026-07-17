package com.smarttodo.application.port.out;

import java.time.Duration;
import java.util.UUID;

/**
 * Driven port: issuing access tokens, so the application layer does not
 * depend on the JWT implementation.
 */
public interface AccessTokenPort {

	String generateAccessToken(UUID userId, String email);

	Duration accessTokenTtl();

	Duration refreshTokenTtl();
}

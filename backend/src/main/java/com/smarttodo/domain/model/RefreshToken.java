package com.smarttodo.domain.model;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

/**
 * A long-lived credential exchangeable for a new token pair. Only the
 * SHA-256 hash of the raw token is ever stored.
 */
public record RefreshToken(
		UUID id,
		UUID userId,
		String tokenHash,
		Instant expiresAt,
		boolean revoked,
		Instant createdAt) {

	public static RefreshToken createNew(UUID userId, String tokenHash, Duration ttl) {
		Instant now = Instant.now();
		return new RefreshToken(UUID.randomUUID(), userId, tokenHash, now.plus(ttl), false, now);
	}

	public RefreshToken revoke() {
		return new RefreshToken(id, userId, tokenHash, expiresAt, true, createdAt);
	}

	public boolean isUsable() {
		return !revoked && expiresAt.isAfter(Instant.now());
	}
}

package com.smarttodo.domain.model;

import java.time.Instant;
import java.util.UUID;

/**
 * Core user of the application. Pure domain object: no framework imports.
 */
public record User(
		UUID id,
		String email,
		String passwordHash,
		String displayName,
		Instant createdAt,
		Instant updatedAt) {

	public static User createNew(String email, String passwordHash, String displayName) {
		Instant now = Instant.now();
		return new User(UUID.randomUUID(), email, passwordHash, displayName, now, now);
	}
}

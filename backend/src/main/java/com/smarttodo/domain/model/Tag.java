package com.smarttodo.domain.model;

import java.time.Instant;
import java.util.UUID;

public record Tag(
		UUID id,
		UUID userId,
		String name,
		String color,
		Instant createdAt,
		Instant updatedAt) {

	public static Tag createNew(UUID userId, String name, String color) {
		Instant now = Instant.now();
		return new Tag(UUID.randomUUID(), userId, name, color, now, now);
	}

	public Tag update(String name, String color) {
		return new Tag(id, userId, name, color, createdAt, Instant.now());
	}
}

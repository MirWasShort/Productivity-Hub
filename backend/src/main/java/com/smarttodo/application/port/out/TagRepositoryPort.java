package com.smarttodo.application.port.out;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.smarttodo.domain.model.Tag;

public interface TagRepositoryPort {

	Tag save(Tag tag);

	List<Tag> findAllByUserId(UUID userId);

	Optional<Tag> findByIdAndUserId(UUID tagId, UUID userId);

	/** Case-insensitive existence check. */
	boolean existsByUserIdAndName(UUID userId, String name);

	void deleteById(UUID tagId);
}

package com.smarttodo.application.port.in;

import java.util.List;
import java.util.UUID;

import com.smarttodo.domain.model.Tag;

public interface TagUseCases {

	List<Tag> list(UUID userId);

	Tag create(CreateTagCommand command);

	Tag update(UpdateTagCommand command);

	void delete(UUID userId, UUID tagId);

	record CreateTagCommand(UUID userId, String name, String color) {
	}

	record UpdateTagCommand(UUID userId, UUID tagId, String name, String color) {
	}
}

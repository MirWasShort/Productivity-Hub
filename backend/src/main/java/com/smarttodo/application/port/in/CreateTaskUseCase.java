package com.smarttodo.application.port.in;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.smarttodo.domain.model.Task;
import com.smarttodo.domain.model.TaskPriority;

public interface CreateTaskUseCase {

	Task create(CreateTaskCommand command);

	record CreateTaskCommand(UUID userId, String title, String description,
			TaskPriority priority, Instant dueDate, UUID listId, List<UUID> tagIds) {

		public CreateTaskCommand {
			tagIds = tagIds == null ? List.of() : List.copyOf(tagIds);
		}
	}
}

package com.smarttodo.application.port.in;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.smarttodo.domain.model.Task;
import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;

public interface UpdateTaskUseCase {

	Task update(UpdateTaskCommand command);

	record UpdateTaskCommand(UUID userId, UUID taskId, String title, String description,
			TaskStatus status, TaskPriority priority, Instant dueDate,
			UUID listId, List<UUID> tagIds) {

		public UpdateTaskCommand {
			tagIds = tagIds == null ? List.of() : List.copyOf(tagIds);
		}
	}
}

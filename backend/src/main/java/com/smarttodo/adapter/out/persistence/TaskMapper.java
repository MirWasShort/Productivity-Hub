package com.smarttodo.adapter.out.persistence;

import com.smarttodo.domain.model.Task;

final class TaskMapper {

	private TaskMapper() {
	}

	static TaskJpaEntity toEntity(Task task) {
		return new TaskJpaEntity(task.id(), task.userId(), task.title(), task.description(),
				task.status(), task.priority(), task.dueDate(), task.createdAt(), task.updatedAt());
	}

	static Task toDomain(TaskJpaEntity entity) {
		return new Task(entity.getId(), entity.getUserId(), entity.getTitle(),
				entity.getDescription(), entity.getStatus(), entity.getPriority(),
				entity.getDueDate(), entity.getCreatedAt(), entity.getUpdatedAt());
	}
}

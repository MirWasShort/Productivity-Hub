package com.smarttodo.adapter.out.persistence;

import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.stream.Collectors;

import com.smarttodo.domain.model.Task;

final class TaskMapper {

	private TaskMapper() {
	}

	/**
	 * Domain tags are mapped to entity references by id: the rows exist
	 * already (created via the tag endpoints), the join table just
	 * points at them.
	 */
	static TaskJpaEntity toEntity(Task task) {
		var tagEntities = task.tags().stream()
				.map(tag -> new TagJpaEntity(tag.id(), tag.userId(), tag.name(),
						tag.color(), tag.createdAt(), tag.updatedAt()))
				.collect(Collectors.toCollection(LinkedHashSet::new));
		return new TaskJpaEntity(task.id(), task.userId(), task.title(), task.description(),
				task.status(), task.priority(), task.dueDate(), task.completedAt(),
				task.listId(), tagEntities, task.createdAt(), task.updatedAt());
	}

	static Task toDomain(TaskJpaEntity entity) {
		var tags = entity.getTags().stream()
				.map(TagPersistenceAdapter::toDomain)
				.sorted(Comparator.comparing(t -> t.name().toLowerCase()))
				.toList();
		return new Task(entity.getId(), entity.getUserId(), entity.getTitle(),
				entity.getDescription(), entity.getStatus(), entity.getPriority(),
				entity.getDueDate(), entity.getCompletedAt(), entity.getListId(), tags,
				entity.getCreatedAt(), entity.getUpdatedAt());
	}
}

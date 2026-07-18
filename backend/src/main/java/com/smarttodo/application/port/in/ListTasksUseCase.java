package com.smarttodo.application.port.in;

import java.time.Instant;
import java.util.UUID;

import com.smarttodo.application.port.PageResult;
import com.smarttodo.domain.model.Task;
import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;

public interface ListTasksUseCase {

	PageResult<Task> list(UUID userId, TaskQuery query, int page, int size);

	/**
	 * Framework-free search criteria. Every field is optional (null =
	 * no filter); sort has explicit defaults. listId/tagId are reserved
	 * for the lists/tags feature and simply unused until then.
	 */
	record TaskQuery(
			TaskStatus status,
			TaskPriority priority,
			String search,
			Instant dueBefore,
			Instant dueAfter,
			UUID listId,
			UUID tagId,
			TaskSortField sortBy,
			SortDirection direction) {

		public static TaskQuery unfiltered() {
			return new TaskQuery(null, null, null, null, null, null, null,
					TaskSortField.CREATED_AT, SortDirection.DESC);
		}

		public TaskQuery withStatus(TaskStatus status) {
			return new TaskQuery(status, priority, search, dueBefore, dueAfter,
					listId, tagId, sortBy, direction);
		}

		public TaskQuery withPriority(TaskPriority priority) {
			return new TaskQuery(status, priority, search, dueBefore, dueAfter,
					listId, tagId, sortBy, direction);
		}

		public TaskQuery withSearch(String search) {
			return new TaskQuery(status, priority, search, dueBefore, dueAfter,
					listId, tagId, sortBy, direction);
		}

		public TaskQuery withDueBefore(Instant dueBefore) {
			return new TaskQuery(status, priority, search, dueBefore, dueAfter,
					listId, tagId, sortBy, direction);
		}

		public TaskQuery withDueAfter(Instant dueAfter) {
			return new TaskQuery(status, priority, search, dueBefore, dueAfter,
					listId, tagId, sortBy, direction);
		}

		public TaskQuery withSort(TaskSortField sortBy, SortDirection direction) {
			return new TaskQuery(status, priority, search, dueBefore, dueAfter,
					listId, tagId, sortBy, direction);
		}

		public TaskQuery withListId(UUID listId) {
			return new TaskQuery(status, priority, search, dueBefore, dueAfter,
					listId, tagId, sortBy, direction);
		}

		public TaskQuery withTagId(UUID tagId) {
			return new TaskQuery(status, priority, search, dueBefore, dueAfter,
					listId, tagId, sortBy, direction);
		}
	}

	enum TaskSortField {
		CREATED_AT,
		DUE_DATE,
		PRIORITY,
		TITLE
	}

	enum SortDirection {
		ASC,
		DESC
	}
}

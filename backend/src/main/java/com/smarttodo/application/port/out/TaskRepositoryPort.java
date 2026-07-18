package com.smarttodo.application.port.out;

import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.port.PageResult;
import com.smarttodo.domain.model.Task;

public interface TaskRepositoryPort {

	Task save(Task task);

	Optional<Task> findByIdAndUserId(UUID taskId, UUID userId);

	PageResult<Task> findAllByUserId(UUID userId, int page, int size);

	void deleteById(UUID taskId);
}

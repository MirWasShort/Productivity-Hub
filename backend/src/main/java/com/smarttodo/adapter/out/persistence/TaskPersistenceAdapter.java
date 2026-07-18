package com.smarttodo.adapter.out.persistence;

import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.port.PageResult;
import com.smarttodo.application.port.out.TaskRepositoryPort;
import com.smarttodo.domain.model.Task;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Component;

@Component
public class TaskPersistenceAdapter implements TaskRepositoryPort {

	private final TaskJpaRepository jpaRepository;

	public TaskPersistenceAdapter(TaskJpaRepository jpaRepository) {
		this.jpaRepository = jpaRepository;
	}

	@Override
	public Task save(Task task) {
		return TaskMapper.toDomain(jpaRepository.save(TaskMapper.toEntity(task)));
	}

	@Override
	public Optional<Task> findByIdAndUserId(UUID taskId, UUID userId) {
		return jpaRepository.findByIdAndUserId(taskId, userId).map(TaskMapper::toDomain);
	}

	@Override
	public PageResult<Task> findAllByUserId(UUID userId, int page, int size) {
		Page<TaskJpaEntity> result = jpaRepository.findAllByUserId(userId,
				PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt")));
		return new PageResult<>(
				result.getContent().stream().map(TaskMapper::toDomain).toList(),
				result.getNumber(), result.getSize(),
				result.getTotalElements(), result.getTotalPages());
	}

	@Override
	public void deleteById(UUID taskId) {
		jpaRepository.deleteById(taskId);
	}
}

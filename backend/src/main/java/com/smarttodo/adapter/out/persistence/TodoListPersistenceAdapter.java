package com.smarttodo.adapter.out.persistence;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.port.out.TodoListRepositoryPort;
import com.smarttodo.domain.model.TodoList;
import org.springframework.stereotype.Component;

@Component
public class TodoListPersistenceAdapter implements TodoListRepositoryPort {

	private final TodoListJpaRepository jpaRepository;

	public TodoListPersistenceAdapter(TodoListJpaRepository jpaRepository) {
		this.jpaRepository = jpaRepository;
	}

	@Override
	public TodoList save(TodoList list) {
		TodoListJpaEntity entity = new TodoListJpaEntity(list.id(), list.userId(),
				list.name(), list.color(), list.position(), list.createdAt(),
				list.updatedAt());
		return toDomain(jpaRepository.save(entity));
	}

	@Override
	public List<TodoList> findAllByUserId(UUID userId) {
		return jpaRepository.findAllByUserIdOrderByPositionAscCreatedAtAsc(userId)
				.stream().map(TodoListPersistenceAdapter::toDomain).toList();
	}

	@Override
	public Optional<TodoList> findByIdAndUserId(UUID listId, UUID userId) {
		return jpaRepository.findByIdAndUserId(listId, userId)
				.map(TodoListPersistenceAdapter::toDomain);
	}

	@Override
	public void deleteById(UUID listId) {
		jpaRepository.deleteById(listId);
	}

	private static TodoList toDomain(TodoListJpaEntity entity) {
		return new TodoList(entity.getId(), entity.getUserId(), entity.getName(),
				entity.getColor(), entity.getPosition(), entity.getCreatedAt(),
				entity.getUpdatedAt());
	}
}

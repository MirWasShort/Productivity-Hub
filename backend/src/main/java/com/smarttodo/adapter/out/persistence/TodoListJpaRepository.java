package com.smarttodo.adapter.out.persistence;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TodoListJpaRepository extends JpaRepository<TodoListJpaEntity, UUID> {

	List<TodoListJpaEntity> findAllByUserIdOrderByPositionAscCreatedAtAsc(UUID userId);

	Optional<TodoListJpaEntity> findByIdAndUserId(UUID id, UUID userId);
}

package com.smarttodo.adapter.out.persistence;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskJpaRepository extends JpaRepository<TaskJpaEntity, UUID> {

	Optional<TaskJpaEntity> findByIdAndUserId(UUID id, UUID userId);

	Page<TaskJpaEntity> findAllByUserId(UUID userId, Pageable pageable);
}

package com.smarttodo.adapter.out.persistence;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface TaskJpaRepository
		extends JpaRepository<TaskJpaEntity, UUID>, JpaSpecificationExecutor<TaskJpaEntity> {

	Optional<TaskJpaEntity> findByIdAndUserId(UUID id, UUID userId);
}

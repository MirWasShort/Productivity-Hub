package com.smarttodo.adapter.out.persistence;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

public interface RefreshTokenJpaRepository extends JpaRepository<RefreshTokenJpaEntity, UUID> {

	Optional<RefreshTokenJpaEntity> findByTokenHash(String tokenHash);
}

package com.smarttodo.adapter.out.persistence;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TagJpaRepository extends JpaRepository<TagJpaEntity, UUID> {

	List<TagJpaEntity> findAllByUserIdOrderByNameAsc(UUID userId);

	Optional<TagJpaEntity> findByIdAndUserId(UUID id, UUID userId);

	@Query("select count(t) > 0 from TagJpaEntity t "
			+ "where t.userId = :userId and lower(t.name) = lower(:name)")
	boolean existsByUserIdAndNameIgnoreCase(@Param("userId") UUID userId,
			@Param("name") String name);
}

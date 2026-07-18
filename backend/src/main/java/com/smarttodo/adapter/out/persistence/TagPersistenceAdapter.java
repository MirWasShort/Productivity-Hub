package com.smarttodo.adapter.out.persistence;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.port.out.TagRepositoryPort;
import com.smarttodo.domain.model.Tag;
import org.springframework.stereotype.Component;

@Component
public class TagPersistenceAdapter implements TagRepositoryPort {

	private final TagJpaRepository jpaRepository;

	public TagPersistenceAdapter(TagJpaRepository jpaRepository) {
		this.jpaRepository = jpaRepository;
	}

	@Override
	public Tag save(Tag tag) {
		TagJpaEntity entity = new TagJpaEntity(tag.id(), tag.userId(), tag.name(),
				tag.color(), tag.createdAt(), tag.updatedAt());
		return toDomain(jpaRepository.save(entity));
	}

	@Override
	public List<Tag> findAllByUserId(UUID userId) {
		return jpaRepository.findAllByUserIdOrderByNameAsc(userId)
				.stream().map(TagPersistenceAdapter::toDomain).toList();
	}

	@Override
	public Optional<Tag> findByIdAndUserId(UUID tagId, UUID userId) {
		return jpaRepository.findByIdAndUserId(tagId, userId)
				.map(TagPersistenceAdapter::toDomain);
	}

	@Override
	public boolean existsByUserIdAndName(UUID userId, String name) {
		return jpaRepository.existsByUserIdAndNameIgnoreCase(userId, name);
	}

	@Override
	public void deleteById(UUID tagId) {
		jpaRepository.deleteById(tagId);
	}

	static Tag toDomain(TagJpaEntity entity) {
		return new Tag(entity.getId(), entity.getUserId(), entity.getName(),
				entity.getColor(), entity.getCreatedAt(), entity.getUpdatedAt());
	}
}

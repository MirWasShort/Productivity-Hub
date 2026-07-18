package com.smarttodo.application.service;

import java.util.List;
import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.exception.TagAlreadyExistsException;
import com.smarttodo.application.port.in.TagUseCases;
import com.smarttodo.application.port.out.TagRepositoryPort;
import com.smarttodo.domain.model.Tag;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TagService implements TagUseCases {

	private final TagRepositoryPort repository;

	public TagService(TagRepositoryPort repository) {
		this.repository = repository;
	}

	@Override
	@Transactional(readOnly = true)
	public List<Tag> list(UUID userId) {
		return repository.findAllByUserId(userId);
	}

	@Override
	@Transactional
	public Tag create(CreateTagCommand command) {
		requireFreeName(command.userId(), command.name());
		return repository.save(Tag.createNew(command.userId(), command.name(), command.color()));
	}

	@Override
	@Transactional
	public Tag update(UpdateTagCommand command) {
		Tag existing = requireOwnTag(command.userId(), command.tagId());
		if (!existing.name().equalsIgnoreCase(command.name())) {
			requireFreeName(command.userId(), command.name());
		}
		return repository.save(existing.update(command.name(), command.color()));
	}

	@Override
	@Transactional
	public void delete(UUID userId, UUID tagId) {
		requireOwnTag(userId, tagId);
		repository.deleteById(tagId);
	}

	private void requireFreeName(UUID userId, String name) {
		if (repository.existsByUserIdAndName(userId, name)) {
			throw new TagAlreadyExistsException(name);
		}
	}

	private Tag requireOwnTag(UUID userId, UUID tagId) {
		return repository.findByIdAndUserId(tagId, userId)
				.orElseThrow(() -> new ResourceNotFoundException("Tag not found: " + tagId));
	}
}

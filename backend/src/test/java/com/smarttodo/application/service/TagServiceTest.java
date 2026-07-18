package com.smarttodo.application.service;

import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.exception.TagAlreadyExistsException;
import com.smarttodo.application.port.in.TagUseCases.CreateTagCommand;
import com.smarttodo.application.port.in.TagUseCases.UpdateTagCommand;
import com.smarttodo.application.port.out.TagRepositoryPort;
import com.smarttodo.domain.model.Tag;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TagServiceTest {

	private static final UUID OWNER = UUID.randomUUID();

	private TagRepositoryPort repository;
	private TagService service;

	@BeforeEach
	void setUp() {
		repository = mock(TagRepositoryPort.class);
		service = new TagService(repository);
		when(repository.save(any(Tag.class))).thenAnswer(inv -> inv.getArgument(0));
	}

	@Test
	void should_createTag_when_nameIsFree() {
		when(repository.existsByUserIdAndName(OWNER, "urgente")).thenReturn(false);

		Tag tag = service.create(new CreateTagCommand(OWNER, "urgente", "#FF0000"));

		assertThat(tag.name()).isEqualTo("urgente");
		verify(repository).save(any(Tag.class));
	}

	@Test
	void should_rejectCreation_when_nameAlreadyUsedCaseInsensitively() {
		when(repository.existsByUserIdAndName(OWNER, "Urgente")).thenReturn(true);

		assertThatThrownBy(() -> service.create(new CreateTagCommand(OWNER, "Urgente", null)))
				.isInstanceOf(TagAlreadyExistsException.class);

		verify(repository, never()).save(any());
	}

	@Test
	void should_updateOwnTag_when_ownerAsks() {
		Tag tag = Tag.createNew(OWNER, "casa", null);
		when(repository.findByIdAndUserId(tag.id(), OWNER)).thenReturn(Optional.of(tag));
		when(repository.existsByUserIdAndName(OWNER, "casa-mia")).thenReturn(false);

		Tag updated = service.update(new UpdateTagCommand(OWNER, tag.id(), "casa-mia", "#00FF00"));

		assertThat(updated.id()).isEqualTo(tag.id());
		assertThat(updated.name()).isEqualTo("casa-mia");
	}

	@Test
	void should_throwNotFound_when_updatingForeignTag() {
		when(repository.findByIdAndUserId(any(), any())).thenReturn(Optional.empty());

		assertThatThrownBy(() -> service.update(
				new UpdateTagCommand(UUID.randomUUID(), UUID.randomUUID(), "x", null)))
				.isInstanceOf(ResourceNotFoundException.class);
	}

	@Test
	void should_throwNotFoundAndNotDelete_when_deletingForeignTag() {
		when(repository.findByIdAndUserId(any(), any())).thenReturn(Optional.empty());

		assertThatThrownBy(() -> service.delete(UUID.randomUUID(), UUID.randomUUID()))
				.isInstanceOf(ResourceNotFoundException.class);

		verify(repository, never()).deleteById(any());
	}
}

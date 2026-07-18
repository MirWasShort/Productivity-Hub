package com.smarttodo.application.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.port.in.TodoListUseCases.CreateListCommand;
import com.smarttodo.application.port.in.TodoListUseCases.UpdateListCommand;
import com.smarttodo.application.port.out.TodoListRepositoryPort;
import com.smarttodo.domain.model.TodoList;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class TodoListServiceTest {

	private static final UUID OWNER = UUID.randomUUID();
	private static final UUID STRANGER = UUID.randomUUID();

	private TodoListRepositoryPort repository;
	private TodoListService service;

	@BeforeEach
	void setUp() {
		repository = mock(TodoListRepositoryPort.class);
		service = new TodoListService(repository);
		when(repository.save(any(TodoList.class))).thenAnswer(inv -> inv.getArgument(0));
	}

	@Test
	void should_createListForUser_when_commandGiven() {
		TodoList created = service.create(new CreateListCommand(OWNER, "Lavoro", "#4F46E5"));

		ArgumentCaptor<TodoList> saved = ArgumentCaptor.forClass(TodoList.class);
		verify(repository).save(saved.capture());
		assertThat(saved.getValue().userId()).isEqualTo(OWNER);
		assertThat(created.name()).isEqualTo("Lavoro");
		assertThat(created.color()).isEqualTo("#4F46E5");
	}

	@Test
	void should_listOwnLists_when_asked() {
		TodoList list = TodoList.createNew(OWNER, "Casa", null);
		when(repository.findAllByUserId(OWNER)).thenReturn(List.of(list));

		assertThat(service.list(OWNER)).containsExactly(list);
	}

	@Test
	void should_updateOwnList_when_ownerAsks() {
		TodoList list = TodoList.createNew(OWNER, "Casa", null);
		when(repository.findByIdAndUserId(list.id(), OWNER)).thenReturn(Optional.of(list));

		TodoList updated = service.update(
				new UpdateListCommand(OWNER, list.id(), "Casa nuova", "#FF0000"));

		assertThat(updated.id()).isEqualTo(list.id());
		assertThat(updated.name()).isEqualTo("Casa nuova");
		assertThat(updated.createdAt()).isEqualTo(list.createdAt());
	}

	@Test
	void should_throwNotFound_when_updatingForeignList() {
		when(repository.findByIdAndUserId(any(), any())).thenReturn(Optional.empty());

		assertThatThrownBy(() -> service.update(
				new UpdateListCommand(STRANGER, UUID.randomUUID(), "X", null)))
				.isInstanceOf(ResourceNotFoundException.class);

		verify(repository, never()).save(any());
	}

	@Test
	void should_throwNotFoundAndNotDelete_when_deletingForeignList() {
		when(repository.findByIdAndUserId(any(), any())).thenReturn(Optional.empty());

		assertThatThrownBy(() -> service.delete(STRANGER, UUID.randomUUID()))
				.isInstanceOf(ResourceNotFoundException.class);

		verify(repository, never()).deleteById(any());
	}
}

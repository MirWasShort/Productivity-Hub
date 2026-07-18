package com.smarttodo.adapter.in.web;

import java.util.List;
import java.util.UUID;

import com.smarttodo.adapter.in.web.dto.ListRequest;
import com.smarttodo.adapter.in.web.dto.ListResponse;
import com.smarttodo.application.port.in.TodoListUseCases;
import com.smarttodo.application.port.in.TodoListUseCases.CreateListCommand;
import com.smarttodo.application.port.in.TodoListUseCases.UpdateListCommand;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/lists")
public class ListController {

	private final TodoListUseCases useCases;

	public ListController(TodoListUseCases useCases) {
		this.useCases = useCases;
	}

	@GetMapping
	public List<ListResponse> list(@AuthenticationPrincipal UUID userId) {
		return useCases.list(userId).stream().map(ListResponse::from).toList();
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public ListResponse create(@AuthenticationPrincipal UUID userId,
			@Valid @RequestBody ListRequest request) {
		return ListResponse.from(useCases.create(
				new CreateListCommand(userId, request.name(), request.color())));
	}

	@PutMapping("/{listId}")
	public ListResponse update(@AuthenticationPrincipal UUID userId,
			@PathVariable UUID listId, @Valid @RequestBody ListRequest request) {
		return ListResponse.from(useCases.update(
				new UpdateListCommand(userId, listId, request.name(), request.color())));
	}

	@DeleteMapping("/{listId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@AuthenticationPrincipal UUID userId, @PathVariable UUID listId) {
		useCases.delete(userId, listId);
	}
}

package com.smarttodo.adapter.in.web;

import java.util.UUID;

import com.smarttodo.adapter.in.web.dto.CreateTaskRequest;
import com.smarttodo.adapter.in.web.dto.PageResponse;
import com.smarttodo.adapter.in.web.dto.TaskResponse;
import com.smarttodo.adapter.in.web.dto.UpdateTaskRequest;
import com.smarttodo.application.port.in.CreateTaskUseCase;
import com.smarttodo.application.port.in.CreateTaskUseCase.CreateTaskCommand;
import com.smarttodo.application.port.in.DeleteTaskUseCase;
import com.smarttodo.application.port.in.GetTaskUseCase;
import com.smarttodo.application.port.in.ListTasksUseCase;
import com.smarttodo.application.port.in.UpdateTaskUseCase;
import com.smarttodo.application.port.in.UpdateTaskUseCase.UpdateTaskCommand;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/tasks")
public class TaskController {

	private final CreateTaskUseCase createTaskUseCase;
	private final GetTaskUseCase getTaskUseCase;
	private final ListTasksUseCase listTasksUseCase;
	private final UpdateTaskUseCase updateTaskUseCase;
	private final DeleteTaskUseCase deleteTaskUseCase;

	public TaskController(CreateTaskUseCase createTaskUseCase, GetTaskUseCase getTaskUseCase,
			ListTasksUseCase listTasksUseCase, UpdateTaskUseCase updateTaskUseCase,
			DeleteTaskUseCase deleteTaskUseCase) {
		this.createTaskUseCase = createTaskUseCase;
		this.getTaskUseCase = getTaskUseCase;
		this.listTasksUseCase = listTasksUseCase;
		this.updateTaskUseCase = updateTaskUseCase;
		this.deleteTaskUseCase = deleteTaskUseCase;
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public TaskResponse create(@AuthenticationPrincipal UUID userId,
			@Valid @RequestBody CreateTaskRequest request) {
		return TaskResponse.from(createTaskUseCase.create(new CreateTaskCommand(
				userId, request.title(), request.description(),
				request.priority(), request.dueDate())));
	}

	@GetMapping("/{taskId}")
	public TaskResponse get(@AuthenticationPrincipal UUID userId, @PathVariable UUID taskId) {
		return TaskResponse.from(getTaskUseCase.get(userId, taskId));
	}

	@GetMapping
	public PageResponse<TaskResponse> list(@AuthenticationPrincipal UUID userId,
			@RequestParam(defaultValue = "0") int page,
			@RequestParam(defaultValue = "20") int size) {
		return PageResponse.from(listTasksUseCase.list(userId, page, size), TaskResponse::from);
	}

	@PutMapping("/{taskId}")
	public TaskResponse update(@AuthenticationPrincipal UUID userId, @PathVariable UUID taskId,
			@Valid @RequestBody UpdateTaskRequest request) {
		return TaskResponse.from(updateTaskUseCase.update(new UpdateTaskCommand(
				userId, taskId, request.title(), request.description(),
				request.status(), request.priority(), request.dueDate())));
	}

	@DeleteMapping("/{taskId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@AuthenticationPrincipal UUID userId, @PathVariable UUID taskId) {
		deleteTaskUseCase.delete(userId, taskId);
	}
}

package com.smarttodo.adapter.in.web.dto;

import java.time.Instant;

import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UpdateTaskRequest(
		@NotBlank @Size(max = 200) String title,
		@Size(max = 10_000) String description,
		@NotNull TaskStatus status,
		@NotNull TaskPriority priority,
		Instant dueDate) {
}

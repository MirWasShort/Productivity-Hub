package com.smarttodo.adapter.in.web.dto;

import java.time.Instant;

import com.smarttodo.domain.model.TaskPriority;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateTaskRequest(
		@NotBlank @Size(max = 200) String title,
		@Size(max = 10_000) String description,
		TaskPriority priority,
		Instant dueDate) {
}

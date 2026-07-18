package com.smarttodo.adapter.in.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/// Shared body for create and update: both carry name + optional color.
public record ListRequest(
		@NotBlank @Size(max = 100) String name,
		@Pattern(regexp = "^#[0-9A-Fa-f]{6}$",
				message = "must be a hex color like #4F46E5") String color) {
}

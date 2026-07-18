package com.smarttodo.adapter.in.web.dto;

import java.time.Instant;
import java.util.UUID;

import com.smarttodo.domain.model.TodoList;

public record ListResponse(
		UUID id,
		String name,
		String color,
		int position,
		Instant createdAt,
		Instant updatedAt) {

	public static ListResponse from(TodoList list) {
		return new ListResponse(list.id(), list.name(), list.color(), list.position(),
				list.createdAt(), list.updatedAt());
	}
}

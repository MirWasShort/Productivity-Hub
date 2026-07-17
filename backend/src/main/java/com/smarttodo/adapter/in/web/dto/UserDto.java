package com.smarttodo.adapter.in.web.dto;

import java.util.UUID;

import com.smarttodo.domain.model.User;

public record UserDto(UUID id, String email, String displayName) {

	public static UserDto from(User user) {
		return new UserDto(user.id(), user.email(), user.displayName());
	}
}

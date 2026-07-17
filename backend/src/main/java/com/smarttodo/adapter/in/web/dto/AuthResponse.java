package com.smarttodo.adapter.in.web.dto;

import com.smarttodo.application.port.in.AuthResult;

public record AuthResponse(String accessToken, long expiresIn, UserDto user) {

	public static AuthResponse from(AuthResult result) {
		return new AuthResponse(result.accessToken(), result.expiresInSeconds(),
				UserDto.from(result.user()));
	}
}

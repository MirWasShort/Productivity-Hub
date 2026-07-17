package com.smarttodo.adapter.in.web.dto;

import com.smarttodo.application.port.in.AuthResult;

public record AuthResponse(String accessToken, String refreshToken, long expiresIn, UserDto user) {

	public static AuthResponse from(AuthResult result) {
		return new AuthResponse(result.accessToken(), result.refreshToken(),
				result.expiresInSeconds(), UserDto.from(result.user()));
	}
}

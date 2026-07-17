package com.smarttodo.adapter.in.web.dto;

import java.time.Instant;
import java.util.Map;

/**
 * Consistent error body for every non-2xx response of the API.
 */
public record ErrorResponse(
		Instant timestamp,
		int status,
		String error,
		String message,
		String path,
		Map<String, String> fieldErrors) {

	public static ErrorResponse of(int status, String error, String message, String path) {
		return new ErrorResponse(Instant.now(), status, error, message, path, null);
	}

	public static ErrorResponse withFieldErrors(int status, String error, String message,
			String path, Map<String, String> fieldErrors) {
		return new ErrorResponse(Instant.now(), status, error, message, path, fieldErrors);
	}
}

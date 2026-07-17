package com.smarttodo.infrastructure.security;

import java.io.IOException;

import com.smarttodo.adapter.in.web.dto.ErrorResponse;
import tools.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

/**
 * Returns the API's standard JSON error body on authentication failures,
 * instead of Spring Security's default empty 401.
 */
@Component
public class JsonAuthenticationEntryPoint implements AuthenticationEntryPoint {

	private final ObjectMapper objectMapper;

	public JsonAuthenticationEntryPoint(ObjectMapper objectMapper) {
		this.objectMapper = objectMapper;
	}

	@Override
	public void commence(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException authException) throws IOException {
		ErrorResponse body = ErrorResponse.of(
				HttpStatus.UNAUTHORIZED.value(),
				"Unauthorized",
				"Authentication required",
				request.getRequestURI());

		response.setStatus(HttpStatus.UNAUTHORIZED.value());
		response.setContentType(MediaType.APPLICATION_JSON_VALUE);
		objectMapper.writeValue(response.getWriter(), body);
	}
}

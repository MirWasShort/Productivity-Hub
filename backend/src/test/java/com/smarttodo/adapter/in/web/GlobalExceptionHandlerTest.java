package com.smarttodo.adapter.in.web;

import java.util.List;
import java.util.UUID;

import com.smarttodo.application.port.in.CreateTaskUseCase;
import com.smarttodo.application.port.in.DeleteTaskUseCase;
import com.smarttodo.application.port.in.GetTaskUseCase;
import com.smarttodo.application.port.in.ListTasksUseCase;
import com.smarttodo.application.port.in.UpdateTaskUseCase;
import com.smarttodo.infrastructure.security.JsonAuthenticationEntryPoint;
import com.smarttodo.infrastructure.security.JwtTokenProvider;
import com.smarttodo.infrastructure.security.SecurityConfig;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Verifies the API-wide error contract: every failure mode produces the
 * same ErrorResponse shape.
 */
@WebMvcTest(TaskController.class)
@Import({SecurityConfig.class, JsonAuthenticationEntryPoint.class})
class GlobalExceptionHandlerTest {

	private static final UUID USER_ID = UUID.randomUUID();

	@Autowired
	private MockMvc mockMvc;

	@MockitoBean
	private CreateTaskUseCase createTaskUseCase;

	@MockitoBean
	private GetTaskUseCase getTaskUseCase;

	@MockitoBean
	private ListTasksUseCase listTasksUseCase;

	@MockitoBean
	private UpdateTaskUseCase updateTaskUseCase;

	@MockitoBean
	private DeleteTaskUseCase deleteTaskUseCase;

	@MockitoBean
	private JwtTokenProvider tokenProvider;

	private static RequestPostProcessor authenticatedAs(UUID userId) {
		return authentication(new UsernamePasswordAuthenticationToken(userId, null, List.of()));
	}

	@Test
	void should_includeFieldErrors_when_validationFails() throws Exception {
		mockMvc.perform(post("/api/v1/tasks")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"title":"","priority":"LOW"}
								"""))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.status").value(400))
				.andExpect(jsonPath("$.error").value("Bad Request"))
				.andExpect(jsonPath("$.path").value("/api/v1/tasks"))
				.andExpect(jsonPath("$.fieldErrors.title").exists());
	}

	@Test
	void should_return500WithStandardBody_when_unexpectedErrorOccurs() throws Exception {
		when(getTaskUseCase.get(eq(USER_ID), any(UUID.class)))
				.thenThrow(new IllegalStateException("boom"));

		mockMvc.perform(get("/api/v1/tasks/" + UUID.randomUUID())
						.with(authenticatedAs(USER_ID)))
				.andExpect(status().isInternalServerError())
				.andExpect(jsonPath("$.status").value(500))
				.andExpect(jsonPath("$.error").value("Internal Server Error"))
				// implementation details must never leak to the client
				.andExpect(jsonPath("$.message").value("An unexpected error occurred"));
	}
}

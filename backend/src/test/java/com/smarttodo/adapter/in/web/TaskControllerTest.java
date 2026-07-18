package com.smarttodo.adapter.in.web;

import java.util.List;
import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.port.PageResult;
import com.smarttodo.application.port.in.CreateTaskUseCase;
import com.smarttodo.application.port.in.DeleteTaskUseCase;
import com.smarttodo.application.port.in.GetTaskUseCase;
import com.smarttodo.application.port.in.ListTasksUseCase;
import com.smarttodo.application.port.in.UpdateTaskUseCase;
import com.smarttodo.domain.model.Task;
import com.smarttodo.domain.model.TaskPriority;
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
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Filters stay enabled and the real SecurityConfig is imported: the
 * authentication() post-processor populates the SecurityContext through
 * the security filter chain, which is what makes @AuthenticationPrincipal
 * resolve the user id (and our config has CSRF disabled, matching prod).
 */
@WebMvcTest(TaskController.class)
@Import({SecurityConfig.class, JsonAuthenticationEntryPoint.class})
class TaskControllerTest {

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

	private static Task sampleTask() {
		return Task.createNew(USER_ID, "Spesa", "Latte", TaskPriority.HIGH, null);
	}

	@Test
	void should_return201WithTask_when_creationSucceeds() throws Exception {
		Task task = sampleTask();
		when(createTaskUseCase.create(any())).thenReturn(task);

		mockMvc.perform(post("/api/v1/tasks")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"title":"Spesa","description":"Latte","priority":"HIGH"}
								"""))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.id").value(task.id().toString()))
				.andExpect(jsonPath("$.title").value("Spesa"))
				.andExpect(jsonPath("$.status").value("TODO"))
				.andExpect(jsonPath("$.priority").value("HIGH"));
	}

	@Test
	void should_return400_when_titleIsBlank() throws Exception {
		mockMvc.perform(post("/api/v1/tasks")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"title":"","priority":"LOW"}
								"""))
				.andExpect(status().isBadRequest());
	}

	@Test
	void should_return200WithTask_when_gettingOwnTask() throws Exception {
		Task task = sampleTask();
		when(getTaskUseCase.get(USER_ID, task.id())).thenReturn(task);

		mockMvc.perform(get("/api/v1/tasks/" + task.id()).with(authenticatedAs(USER_ID)))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.title").value("Spesa"));
	}

	@Test
	void should_return404WithErrorBody_when_taskDoesNotExist() throws Exception {
		UUID missing = UUID.randomUUID();
		when(getTaskUseCase.get(USER_ID, missing))
				.thenThrow(new ResourceNotFoundException("Task not found"));

		mockMvc.perform(get("/api/v1/tasks/" + missing).with(authenticatedAs(USER_ID)))
				.andExpect(status().isNotFound())
				.andExpect(jsonPath("$.status").value(404))
				.andExpect(jsonPath("$.error").value("Not Found"));
	}

	@Test
	void should_returnPagedList_when_listing() throws Exception {
		Task task = sampleTask();
		when(listTasksUseCase.list(eq(USER_ID), anyInt(), anyInt()))
				.thenReturn(new PageResult<>(List.of(task), 0, 20, 1, 1));

		mockMvc.perform(get("/api/v1/tasks").with(authenticatedAs(USER_ID)))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.items[0].title").value("Spesa"))
				.andExpect(jsonPath("$.totalElements").value(1))
				.andExpect(jsonPath("$.page").value(0));
	}

	@Test
	void should_return200WithUpdatedTask_when_updateSucceeds() throws Exception {
		Task task = sampleTask();
		when(updateTaskUseCase.update(any())).thenReturn(task);

		mockMvc.perform(put("/api/v1/tasks/" + task.id())
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"title":"Spesa","description":"Latte","status":"DONE","priority":"HIGH"}
								"""))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.title").value("Spesa"));
	}

	@Test
	void should_return400_when_updateHasInvalidStatus() throws Exception {
		mockMvc.perform(put("/api/v1/tasks/" + UUID.randomUUID())
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"title":"X","status":"NOT_A_STATUS","priority":"HIGH"}
								"""))
				.andExpect(status().isBadRequest());
	}

	@Test
	void should_return204_when_deleteSucceeds() throws Exception {
		mockMvc.perform(delete("/api/v1/tasks/" + UUID.randomUUID())
						.with(authenticatedAs(USER_ID)))
				.andExpect(status().isNoContent());
	}
}

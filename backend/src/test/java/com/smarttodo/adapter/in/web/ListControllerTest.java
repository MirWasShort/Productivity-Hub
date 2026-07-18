package com.smarttodo.adapter.in.web;

import java.util.List;
import java.util.UUID;

import com.smarttodo.application.exception.ResourceNotFoundException;
import com.smarttodo.application.port.in.TodoListUseCases;
import com.smarttodo.domain.model.TodoList;
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
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ListController.class)
@Import({SecurityConfig.class, JsonAuthenticationEntryPoint.class})
class ListControllerTest {

	private static final UUID USER_ID = UUID.randomUUID();

	@Autowired
	private MockMvc mockMvc;

	@MockitoBean
	private TodoListUseCases todoListUseCases;

	@MockitoBean
	private JwtTokenProvider tokenProvider;

	private static RequestPostProcessor authenticatedAs(UUID userId) {
		return authentication(new UsernamePasswordAuthenticationToken(userId, null, List.of()));
	}

	@Test
	void should_returnLists_when_listing() throws Exception {
		TodoList list = TodoList.createNew(USER_ID, "Lavoro", "#4F46E5");
		when(todoListUseCases.list(USER_ID)).thenReturn(List.of(list));

		mockMvc.perform(get("/api/v1/lists").with(authenticatedAs(USER_ID)))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$[0].name").value("Lavoro"))
				.andExpect(jsonPath("$[0].color").value("#4F46E5"));
	}

	@Test
	void should_return201_when_creationSucceeds() throws Exception {
		TodoList list = TodoList.createNew(USER_ID, "Casa", null);
		when(todoListUseCases.create(any())).thenReturn(list);

		mockMvc.perform(post("/api/v1/lists")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"name":"Casa"}
								"""))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.name").value("Casa"));
	}

	@Test
	void should_return400_when_nameIsBlank() throws Exception {
		mockMvc.perform(post("/api/v1/lists")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"name":""}
								"""))
				.andExpect(status().isBadRequest());
	}

	@Test
	void should_return400_when_colorIsNotHex() throws Exception {
		mockMvc.perform(post("/api/v1/lists")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"name":"Casa","color":"rosso"}
								"""))
				.andExpect(status().isBadRequest());
	}

	@Test
	void should_return200_when_updateSucceeds() throws Exception {
		TodoList list = TodoList.createNew(USER_ID, "Rinominata", null);
		when(todoListUseCases.update(any())).thenReturn(list);

		mockMvc.perform(put("/api/v1/lists/" + list.id())
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"name":"Rinominata"}
								"""))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.name").value("Rinominata"));
	}

	@Test
	void should_return404_when_listDoesNotExist() throws Exception {
		when(todoListUseCases.update(any()))
				.thenThrow(new ResourceNotFoundException("List not found"));

		mockMvc.perform(put("/api/v1/lists/" + UUID.randomUUID())
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"name":"X"}
								"""))
				.andExpect(status().isNotFound());
	}

	@Test
	void should_return204_when_deleteSucceeds() throws Exception {
		mockMvc.perform(delete("/api/v1/lists/" + UUID.randomUUID())
						.with(authenticatedAs(USER_ID)))
				.andExpect(status().isNoContent());
	}
}

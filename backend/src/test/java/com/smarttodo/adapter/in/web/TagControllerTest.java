package com.smarttodo.adapter.in.web;

import java.util.List;
import java.util.UUID;

import com.smarttodo.application.exception.TagAlreadyExistsException;
import com.smarttodo.application.port.in.TagUseCases;
import com.smarttodo.domain.model.Tag;
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
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(TagController.class)
@Import({SecurityConfig.class, JsonAuthenticationEntryPoint.class})
class TagControllerTest {

	private static final UUID USER_ID = UUID.randomUUID();

	@Autowired
	private MockMvc mockMvc;

	@MockitoBean
	private TagUseCases tagUseCases;

	@MockitoBean
	private JwtTokenProvider tokenProvider;

	private static RequestPostProcessor authenticatedAs(UUID userId) {
		return authentication(new UsernamePasswordAuthenticationToken(userId, null, List.of()));
	}

	@Test
	void should_returnTags_when_listing() throws Exception {
		when(tagUseCases.list(USER_ID))
				.thenReturn(List.of(Tag.createNew(USER_ID, "urgente", "#FF0000")));

		mockMvc.perform(get("/api/v1/tags").with(authenticatedAs(USER_ID)))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$[0].name").value("urgente"));
	}

	@Test
	void should_return201_when_creationSucceeds() throws Exception {
		when(tagUseCases.create(any()))
				.thenReturn(Tag.createNew(USER_ID, "casa", null));

		mockMvc.perform(post("/api/v1/tags")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"name":"casa"}
								"""))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.name").value("casa"));
	}

	@Test
	void should_return409WithErrorBody_when_nameIsDuplicate() throws Exception {
		when(tagUseCases.create(any()))
				.thenThrow(new TagAlreadyExistsException("casa"));

		mockMvc.perform(post("/api/v1/tags")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"name":"casa"}
								"""))
				.andExpect(status().isConflict())
				.andExpect(jsonPath("$.status").value(409));
	}

	@Test
	void should_return400_when_nameIsBlank() throws Exception {
		mockMvc.perform(post("/api/v1/tags")
						.with(authenticatedAs(USER_ID))
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"name":""}
								"""))
				.andExpect(status().isBadRequest());
	}

	@Test
	void should_return204_when_deleteSucceeds() throws Exception {
		mockMvc.perform(delete("/api/v1/tags/" + UUID.randomUUID())
						.with(authenticatedAs(USER_ID)))
				.andExpect(status().isNoContent());
	}
}

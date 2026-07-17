package com.smarttodo.adapter.in.web;

import java.util.UUID;

import com.smarttodo.application.exception.EmailAlreadyExistsException;
import com.smarttodo.application.port.in.AuthResult;
import com.smarttodo.application.port.in.RegisterUseCase;
import com.smarttodo.domain.model.User;
import com.smarttodo.infrastructure.security.JwtTokenProvider;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
class AuthControllerTest {

	@Autowired
	private MockMvc mockMvc;

	@MockitoBean
	private RegisterUseCase registerUseCase;

	@MockitoBean
	private JwtTokenProvider tokenProvider;

	private static final String VALID_BODY = """
			{"email":"mario@example.com","password":"Password1!","displayName":"Mario"}
			""";

	@Test
	void should_return201WithTokens_when_registrationSucceeds() throws Exception {
		User user = User.createNew("mario@example.com", "hash", "Mario");
		when(registerUseCase.register(any())).thenReturn(new AuthResult("jwt-token", 900, user));

		mockMvc.perform(post("/api/v1/auth/register")
						.contentType(MediaType.APPLICATION_JSON)
						.content(VALID_BODY))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.accessToken").value("jwt-token"))
				.andExpect(jsonPath("$.expiresIn").value(900))
				.andExpect(jsonPath("$.user.email").value("mario@example.com"))
				.andExpect(jsonPath("$.user.displayName").value("Mario"))
				.andExpect(jsonPath("$.user.id").value(user.id().toString()));
	}

	@Test
	void should_return400_when_emailIsInvalid() throws Exception {
		mockMvc.perform(post("/api/v1/auth/register")
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"email":"not-an-email","password":"Password1!","displayName":"Mario"}
								"""))
				.andExpect(status().isBadRequest());
	}

	@Test
	void should_return400_when_passwordIsTooShort() throws Exception {
		mockMvc.perform(post("/api/v1/auth/register")
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"email":"mario@example.com","password":"short","displayName":"Mario"}
								"""))
				.andExpect(status().isBadRequest());
	}

	@Test
	void should_return409WithErrorBody_when_emailAlreadyRegistered() throws Exception {
		when(registerUseCase.register(any()))
				.thenThrow(new EmailAlreadyExistsException("mario@example.com"));

		mockMvc.perform(post("/api/v1/auth/register")
						.contentType(MediaType.APPLICATION_JSON)
						.content(VALID_BODY))
				.andExpect(status().isConflict())
				.andExpect(jsonPath("$.status").value(409))
				.andExpect(jsonPath("$.error").value("Conflict"))
				.andExpect(jsonPath("$.path").value("/api/v1/auth/register"));
	}
}

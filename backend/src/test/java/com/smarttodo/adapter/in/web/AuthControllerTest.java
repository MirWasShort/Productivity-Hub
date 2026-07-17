package com.smarttodo.adapter.in.web;

import com.smarttodo.application.exception.EmailAlreadyExistsException;
import com.smarttodo.application.exception.InvalidCredentialsException;
import com.smarttodo.application.exception.InvalidRefreshTokenException;
import com.smarttodo.application.port.in.AuthResult;
import com.smarttodo.application.port.in.LoginUseCase;
import com.smarttodo.application.port.in.RefreshTokenUseCase;
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
import static org.mockito.ArgumentMatchers.anyString;
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
	private LoginUseCase loginUseCase;

	@MockitoBean
	private RefreshTokenUseCase refreshTokenUseCase;

	@MockitoBean
	private JwtTokenProvider tokenProvider;

	private static final User USER = User.createNew("mario@example.com", "hash", "Mario");
	private static final AuthResult RESULT = new AuthResult("jwt-token", "raw-refresh", 900, USER);

	private static final String VALID_REGISTER_BODY = """
			{"email":"mario@example.com","password":"Password1!","displayName":"Mario"}
			""";

	// --- register ---

	@Test
	void should_return201WithTokenPair_when_registrationSucceeds() throws Exception {
		when(registerUseCase.register(any())).thenReturn(RESULT);

		mockMvc.perform(post("/api/v1/auth/register")
						.contentType(MediaType.APPLICATION_JSON)
						.content(VALID_REGISTER_BODY))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.accessToken").value("jwt-token"))
				.andExpect(jsonPath("$.refreshToken").value("raw-refresh"))
				.andExpect(jsonPath("$.expiresIn").value(900))
				.andExpect(jsonPath("$.user.email").value("mario@example.com"))
				.andExpect(jsonPath("$.user.id").value(USER.id().toString()));
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
						.content(VALID_REGISTER_BODY))
				.andExpect(status().isConflict())
				.andExpect(jsonPath("$.status").value(409))
				.andExpect(jsonPath("$.error").value("Conflict"))
				.andExpect(jsonPath("$.path").value("/api/v1/auth/register"));
	}

	// --- login ---

	@Test
	void should_return200WithTokenPair_when_loginSucceeds() throws Exception {
		when(loginUseCase.login(any())).thenReturn(RESULT);

		mockMvc.perform(post("/api/v1/auth/login")
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"email":"mario@example.com","password":"Password1!"}
								"""))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.accessToken").value("jwt-token"))
				.andExpect(jsonPath("$.refreshToken").value("raw-refresh"));
	}

	@Test
	void should_return401WithErrorBody_when_credentialsAreInvalid() throws Exception {
		when(loginUseCase.login(any())).thenThrow(new InvalidCredentialsException());

		mockMvc.perform(post("/api/v1/auth/login")
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"email":"mario@example.com","password":"wrong-pass"}
								"""))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.status").value(401))
				.andExpect(jsonPath("$.error").value("Unauthorized"));
	}

	// --- refresh ---

	@Test
	void should_return200WithNewPair_when_refreshSucceeds() throws Exception {
		when(refreshTokenUseCase.refresh(anyString())).thenReturn(RESULT);

		mockMvc.perform(post("/api/v1/auth/refresh")
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"refreshToken":"some-raw-token"}
								"""))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.accessToken").value("jwt-token"))
				.andExpect(jsonPath("$.refreshToken").value("raw-refresh"));
	}

	@Test
	void should_return401_when_refreshTokenIsInvalid() throws Exception {
		when(refreshTokenUseCase.refresh(anyString()))
				.thenThrow(new InvalidRefreshTokenException());

		mockMvc.perform(post("/api/v1/auth/refresh")
						.contentType(MediaType.APPLICATION_JSON)
						.content("""
								{"refreshToken":"stolen-or-expired"}
								"""))
				.andExpect(status().isUnauthorized());
	}
}

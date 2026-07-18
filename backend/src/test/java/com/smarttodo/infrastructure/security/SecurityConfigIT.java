package com.smarttodo.infrastructure.security;

import java.util.UUID;

import com.smarttodo.TestcontainersConfiguration;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestcontainersConfiguration.class)
class SecurityConfigIT {

	@Autowired
	private MockMvc mockMvc;

	@Autowired
	private JwtTokenProvider tokenProvider;

	@Test
	void should_allowAnonymousAccess_when_healthEndpointIsCalled() throws Exception {
		mockMvc.perform(get("/health"))
				.andExpect(status().isOk());
	}

	@Test
	void should_return401WithJsonError_when_protectedRouteIsCalledWithoutToken() throws Exception {
		mockMvc.perform(get("/api/v1/tasks"))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.status").value(401))
				.andExpect(jsonPath("$.error").value("Unauthorized"))
				.andExpect(jsonPath("$.path").value("/api/v1/tasks"));
	}

	@Test
	void should_return401_when_tokenIsInvalid() throws Exception {
		mockMvc.perform(get("/api/v1/tasks")
						.header("Authorization", "Bearer not-a-real-token"))
				.andExpect(status().isUnauthorized());
	}

	@Test
	void should_passAuthentication_when_tokenIsValid() throws Exception {
		String token = tokenProvider.generateAccessToken(UUID.randomUUID(), "mario@example.com");

		mockMvc.perform(get("/api/v1/tasks")
						.header("Authorization", "Bearer " + token))
				.andExpect(status().isOk());
	}
}

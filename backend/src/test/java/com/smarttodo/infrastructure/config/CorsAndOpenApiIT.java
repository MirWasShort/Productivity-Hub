package com.smarttodo.infrastructure.config;

import com.smarttodo.TestcontainersConfiguration;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestcontainersConfiguration.class)
class CorsAndOpenApiIT {

	@Autowired
	private MockMvc mockMvc;

	@Test
	void should_answerPreflightWithCorsHeaders_when_originIsLocalhost() throws Exception {
		mockMvc.perform(options("/api/v1/tasks")
						.header("Origin", "http://localhost:5555")
						.header("Access-Control-Request-Method", "POST")
						.header("Access-Control-Request-Headers", "authorization,content-type"))
				.andExpect(status().isOk())
				.andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:5555"))
				.andExpect(header().exists("Access-Control-Allow-Methods"));
	}

	@Test
	void should_rejectPreflight_when_originIsNotAllowed() throws Exception {
		mockMvc.perform(options("/api/v1/tasks")
						.header("Origin", "https://evil.example.com")
						.header("Access-Control-Request-Method", "POST"))
				.andExpect(status().isForbidden());
	}

	@Test
	void should_exposeOpenApiDocs_when_anonymous() throws Exception {
		mockMvc.perform(get("/v3/api-docs"))
				.andExpect(status().isOk());
	}
}

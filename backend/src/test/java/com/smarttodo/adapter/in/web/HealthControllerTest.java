package com.smarttodo.adapter.in.web;

import com.smarttodo.infrastructure.security.JwtTokenProvider;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(HealthController.class)
@AutoConfigureMockMvc(addFilters = false)
class HealthControllerTest {

	@Autowired
	private MockMvc mockMvc;

	// The @WebMvcTest slice pulls in Filter beans (JwtAuthenticationFilter),
	// which needs a JwtTokenProvider; mock it so the slice stays lightweight.
	@MockitoBean
	private JwtTokenProvider tokenProvider;

	@Test
	void should_returnStatusUp_when_healthEndpointIsCalled() throws Exception {
		mockMvc.perform(get("/health"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.status").value("UP"));
	}
}

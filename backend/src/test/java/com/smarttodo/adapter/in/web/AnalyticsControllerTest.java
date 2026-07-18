package com.smarttodo.adapter.in.web;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.smarttodo.application.port.in.GetAnalyticsUseCase;
import com.smarttodo.application.port.in.GetAnalyticsUseCase.AnalyticsSummaryView;
import com.smarttodo.application.port.in.GetAnalyticsUseCase.CompletionsView;
import com.smarttodo.application.port.in.GetAnalyticsUseCase.DayCount;
import com.smarttodo.domain.model.TaskPriority;
import com.smarttodo.domain.model.TaskStatus;
import com.smarttodo.infrastructure.security.JsonAuthenticationEntryPoint;
import com.smarttodo.infrastructure.security.JwtTokenProvider;
import com.smarttodo.infrastructure.security.SecurityConfig;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AnalyticsController.class)
@Import({SecurityConfig.class, JsonAuthenticationEntryPoint.class})
class AnalyticsControllerTest {

	private static final UUID USER_ID = UUID.randomUUID();

	@Autowired
	private MockMvc mockMvc;

	@MockitoBean
	private GetAnalyticsUseCase useCase;

	@MockitoBean
	private JwtTokenProvider tokenProvider;

	private static RequestPostProcessor authenticatedAs(UUID userId) {
		return authentication(new UsernamePasswordAuthenticationToken(userId, null, List.of()));
	}

	@Test
	void should_returnSummary() throws Exception {
		when(useCase.summary(USER_ID)).thenReturn(new AnalyticsSummaryView(
				10, 4, 2, 1,
				Map.of(TaskStatus.TODO, 5L, TaskStatus.IN_PROGRESS, 1L, TaskStatus.DONE, 4L),
				Map.of(TaskPriority.LOW, 3L, TaskPriority.MEDIUM, 4L, TaskPriority.HIGH, 3L)));

		mockMvc.perform(get("/api/v1/analytics/summary").with(authenticatedAs(USER_ID)))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.total").value(10))
				.andExpect(jsonPath("$.completed").value(4))
				.andExpect(jsonPath("$.overdue").value(2))
				.andExpect(jsonPath("$.dueToday").value(1))
				.andExpect(jsonPath("$.byPriority.HIGH").value(3));
	}

	@Test
	void should_returnCompletions() throws Exception {
		when(useCase.completions(eq(USER_ID), anyInt())).thenReturn(new CompletionsView(
				LocalDate.of(2026, 7, 12), LocalDate.of(2026, 7, 19),
				List.of(new DayCount(LocalDate.of(2026, 7, 18), 3))));

		mockMvc.perform(get("/api/v1/analytics/completions?days=7")
						.with(authenticatedAs(USER_ID)))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.days[0].date").value("2026-07-18"))
				.andExpect(jsonPath("$.days[0].count").value(3));
	}

	@Test
	void should_require_authentication() throws Exception {
		mockMvc.perform(get("/api/v1/analytics/summary"))
				.andExpect(status().isUnauthorized());
	}
}

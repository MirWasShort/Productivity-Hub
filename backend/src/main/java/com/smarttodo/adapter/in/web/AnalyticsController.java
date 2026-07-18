package com.smarttodo.adapter.in.web;

import java.util.UUID;

import com.smarttodo.application.port.in.GetAnalyticsUseCase;
import com.smarttodo.application.port.in.GetAnalyticsUseCase.AnalyticsSummaryView;
import com.smarttodo.application.port.in.GetAnalyticsUseCase.CompletionsView;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/analytics")
public class AnalyticsController {

	private final GetAnalyticsUseCase useCase;

	public AnalyticsController(GetAnalyticsUseCase useCase) {
		this.useCase = useCase;
	}

	@GetMapping("/summary")
	public AnalyticsSummaryView summary(@AuthenticationPrincipal UUID userId) {
		return useCase.summary(userId);
	}

	@GetMapping("/completions")
	public CompletionsView completions(@AuthenticationPrincipal UUID userId,
			@RequestParam(defaultValue = "42") int days) {
		return useCase.completions(userId, days);
	}
}

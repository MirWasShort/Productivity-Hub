package com.smarttodo.infrastructure.security;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Extracts and validates the Bearer token, then populates the
 * SecurityContext with the authenticated user id. No business logic here:
 * authorization decisions belong to the SecurityFilterChain rules.
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

	private static final String BEARER_PREFIX = "Bearer ";

	private final JwtTokenProvider tokenProvider;

	public JwtAuthenticationFilter(JwtTokenProvider tokenProvider) {
		this.tokenProvider = tokenProvider;
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
			FilterChain filterChain) throws ServletException, IOException {
		String header = request.getHeader("Authorization");

		if (header != null && header.startsWith(BEARER_PREFIX)) {
			String token = header.substring(BEARER_PREFIX.length());
			if (tokenProvider.validateToken(token)) {
				UUID userId = tokenProvider.extractUserId(token);
				UsernamePasswordAuthenticationToken authentication =
						new UsernamePasswordAuthenticationToken(userId, null, List.of());
				SecurityContextHolder.getContext().setAuthentication(authentication);
			}
		}

		filterChain.doFilter(request, response);
	}
}

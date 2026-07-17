package com.smarttodo.infrastructure.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

	private final JwtAuthenticationFilter jwtAuthenticationFilter;
	private final JsonAuthenticationEntryPoint authenticationEntryPoint;

	public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter,
			JsonAuthenticationEntryPoint authenticationEntryPoint) {
		this.jwtAuthenticationFilter = jwtAuthenticationFilter;
		this.authenticationEntryPoint = authenticationEntryPoint;
	}

	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
		return http
				.csrf(AbstractHttpConfigurer::disable)
				.cors(Customizer.withDefaults())
				.sessionManagement(session ->
						session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.authorizeHttpRequests(auth -> auth
						.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
						.requestMatchers(
								"/api/v1/auth/**",
								"/health",
								"/actuator/health",
								"/swagger-ui.html",
								"/swagger-ui/**",
								"/v3/api-docs/**").permitAll()
						.anyRequest().authenticated())
				.exceptionHandling(handling ->
						handling.authenticationEntryPoint(authenticationEntryPoint))
				.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
				.build();
	}

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
}

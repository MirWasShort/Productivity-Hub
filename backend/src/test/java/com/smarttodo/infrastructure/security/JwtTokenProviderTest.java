package com.smarttodo.infrastructure.security;

import java.time.Duration;
import java.util.UUID;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class JwtTokenProviderTest {

	private static final String SECRET = "test-secret-that-is-at-least-32-bytes-long!";
	private static final UUID USER_ID = UUID.randomUUID();
	private static final String EMAIL = "mario@example.com";

	private JwtTokenProvider providerWithTtl(Duration accessTtl) {
		return new JwtTokenProvider(new JwtProperties(SECRET, accessTtl, Duration.ofDays(7)));
	}

	@Test
	void should_roundTripUserIdAndEmail_when_tokenIsGeneratedAndParsed() {
		JwtTokenProvider provider = providerWithTtl(Duration.ofMinutes(15));

		String token = provider.generateAccessToken(USER_ID, EMAIL);

		assertThat(provider.validateToken(token)).isTrue();
		assertThat(provider.extractUserId(token)).isEqualTo(USER_ID);
	}

	@Test
	void should_rejectToken_when_expired() {
		JwtTokenProvider provider = providerWithTtl(Duration.ofMinutes(-5));

		String expired = provider.generateAccessToken(USER_ID, EMAIL);

		assertThat(provider.validateToken(expired)).isFalse();
	}

	@Test
	void should_rejectToken_when_signatureIsTampered() {
		JwtTokenProvider provider = providerWithTtl(Duration.ofMinutes(15));

		String token = provider.generateAccessToken(USER_ID, EMAIL);
		String tampered = token.substring(0, token.length() - 4) + "AAAA";

		assertThat(provider.validateToken(tampered)).isFalse();
	}

	@Test
	void should_rejectToken_when_signedWithDifferentKey() {
		JwtTokenProvider provider = providerWithTtl(Duration.ofMinutes(15));
		JwtTokenProvider otherKeyProvider = new JwtTokenProvider(new JwtProperties(
				"another-secret-that-is-also-32-bytes-plus!", Duration.ofMinutes(15), Duration.ofDays(7)));

		String foreignToken = otherKeyProvider.generateAccessToken(USER_ID, EMAIL);

		assertThat(provider.validateToken(foreignToken)).isFalse();
	}

	@Test
	void should_rejectGarbage_when_tokenIsNotAJwt() {
		JwtTokenProvider provider = providerWithTtl(Duration.ofMinutes(15));

		assertThat(provider.validateToken("not-a-jwt")).isFalse();
		assertThat(provider.validateToken("")).isFalse();
	}
}

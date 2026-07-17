package com.smarttodo.infrastructure.security;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

import javax.crypto.SecretKey;

import com.smarttodo.application.port.out.AccessTokenPort;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

@Component
public class JwtTokenProvider implements AccessTokenPort {

	private final SecretKey key;
	private final JwtProperties properties;

	public JwtTokenProvider(JwtProperties properties) {
		this.properties = properties;
		this.key = Keys.hmacShaKeyFor(properties.secret().getBytes(StandardCharsets.UTF_8));
	}

	@Override
	public String generateAccessToken(UUID userId, String email) {
		Instant now = Instant.now();
		return Jwts.builder()
				.subject(userId.toString())
				.claim("email", email)
				.issuedAt(Date.from(now))
				.expiration(Date.from(now.plus(properties.accessTokenTtl())))
				.signWith(key)
				.compact();
	}

	public boolean validateToken(String token) {
		try {
			parseClaims(token);
			return true;
		} catch (JwtException | IllegalArgumentException e) {
			return false;
		}
	}

	@Override
	public java.time.Duration accessTokenTtl() {
		return properties.accessTokenTtl();
	}

	@Override
	public java.time.Duration refreshTokenTtl() {
		return properties.refreshTokenTtl();
	}

	public UUID extractUserId(String token) {
		return UUID.fromString(parseClaims(token).getSubject());
	}

	private io.jsonwebtoken.Claims parseClaims(String token) {
		return Jwts.parser()
				.verifyWith(key)
				.build()
				.parseSignedClaims(token)
				.getPayload();
	}
}

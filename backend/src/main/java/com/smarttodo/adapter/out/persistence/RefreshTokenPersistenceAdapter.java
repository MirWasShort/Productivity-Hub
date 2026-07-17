package com.smarttodo.adapter.out.persistence;

import java.util.Optional;

import com.smarttodo.application.port.out.RefreshTokenRepositoryPort;
import com.smarttodo.domain.model.RefreshToken;
import org.springframework.stereotype.Component;

@Component
public class RefreshTokenPersistenceAdapter implements RefreshTokenRepositoryPort {

	private final RefreshTokenJpaRepository jpaRepository;

	public RefreshTokenPersistenceAdapter(RefreshTokenJpaRepository jpaRepository) {
		this.jpaRepository = jpaRepository;
	}

	@Override
	public RefreshToken save(RefreshToken refreshToken) {
		RefreshTokenJpaEntity entity = new RefreshTokenJpaEntity(
				refreshToken.id(), refreshToken.userId(), refreshToken.tokenHash(),
				refreshToken.expiresAt(), refreshToken.revoked(), refreshToken.createdAt());
		return toDomain(jpaRepository.save(entity));
	}

	@Override
	public Optional<RefreshToken> findByTokenHash(String tokenHash) {
		return jpaRepository.findByTokenHash(tokenHash).map(RefreshTokenPersistenceAdapter::toDomain);
	}

	private static RefreshToken toDomain(RefreshTokenJpaEntity entity) {
		return new RefreshToken(entity.getId(), entity.getUserId(), entity.getTokenHash(),
				entity.getExpiresAt(), entity.isRevoked(), entity.getCreatedAt());
	}
}

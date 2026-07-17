package com.smarttodo.application.port.out;

import java.util.Optional;

import com.smarttodo.domain.model.RefreshToken;

public interface RefreshTokenRepositoryPort {

	RefreshToken save(RefreshToken refreshToken);

	Optional<RefreshToken> findByTokenHash(String tokenHash);
}

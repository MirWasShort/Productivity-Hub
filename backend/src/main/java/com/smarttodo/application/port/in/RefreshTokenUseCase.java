package com.smarttodo.application.port.in;

/**
 * Driving port: exchange a valid refresh token for a new token pair.
 * The presented token is revoked in the process (rotation).
 */
public interface RefreshTokenUseCase {

	AuthResult refresh(String rawRefreshToken);
}

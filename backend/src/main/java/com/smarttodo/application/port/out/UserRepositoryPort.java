package com.smarttodo.application.port.out;

import java.util.Optional;
import java.util.UUID;

import com.smarttodo.domain.model.User;

/**
 * Driven port: what the application needs from user persistence,
 * expressed in domain terms. Implemented by an adapter.
 */
public interface UserRepositoryPort {

	User save(User user);

	Optional<User> findByEmail(String email);

	Optional<User> findById(UUID id);

	boolean existsByEmail(String email);
}

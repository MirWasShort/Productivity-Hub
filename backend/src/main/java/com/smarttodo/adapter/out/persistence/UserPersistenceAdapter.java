package com.smarttodo.adapter.out.persistence;

import java.util.Optional;
import java.util.UUID;

import com.smarttodo.application.port.out.UserRepositoryPort;
import com.smarttodo.domain.model.User;
import org.springframework.stereotype.Component;

@Component
public class UserPersistenceAdapter implements UserRepositoryPort {

	private final UserJpaRepository jpaRepository;

	public UserPersistenceAdapter(UserJpaRepository jpaRepository) {
		this.jpaRepository = jpaRepository;
	}

	@Override
	public User save(User user) {
		return UserMapper.toDomain(jpaRepository.save(UserMapper.toEntity(user)));
	}

	@Override
	public Optional<User> findByEmail(String email) {
		return jpaRepository.findByEmail(email).map(UserMapper::toDomain);
	}

	@Override
	public Optional<User> findById(UUID id) {
		return jpaRepository.findById(id).map(UserMapper::toDomain);
	}

	@Override
	public boolean existsByEmail(String email) {
		return jpaRepository.existsByEmail(email);
	}
}

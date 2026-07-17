package com.smarttodo.adapter.out.persistence;

import com.smarttodo.domain.model.User;

final class UserMapper {

	private UserMapper() {
	}

	static UserJpaEntity toEntity(User user) {
		return new UserJpaEntity(user.id(), user.email(), user.passwordHash(),
				user.displayName(), user.createdAt(), user.updatedAt());
	}

	static User toDomain(UserJpaEntity entity) {
		return new User(entity.getId(), entity.getEmail(), entity.getPasswordHash(),
				entity.getDisplayName(), entity.getCreatedAt(), entity.getUpdatedAt());
	}
}

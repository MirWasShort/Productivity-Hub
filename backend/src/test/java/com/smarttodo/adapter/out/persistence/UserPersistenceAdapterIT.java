package com.smarttodo.adapter.out.persistence;

import java.util.Optional;

import com.smarttodo.TestcontainersConfiguration;
import com.smarttodo.domain.model.User;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.dao.DataIntegrityViolationException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@DataJpaTest
@Import({TestcontainersConfiguration.class, UserPersistenceAdapter.class})
class UserPersistenceAdapterIT {

	@Autowired
	private UserPersistenceAdapter adapter;

	@Autowired
	private UserJpaRepository jpaRepository;

	@Test
	void should_persistAndReturnUser_when_saved() {
		User user = User.createNew("mario@example.com", "hashed-pw", "Mario");

		User saved = adapter.save(user);

		assertThat(saved.id()).isEqualTo(user.id());
		assertThat(adapter.findByEmail("mario@example.com"))
				.hasValueSatisfying(found -> {
					assertThat(found.email()).isEqualTo("mario@example.com");
					assertThat(found.passwordHash()).isEqualTo("hashed-pw");
					assertThat(found.displayName()).isEqualTo("Mario");
					assertThat(found.createdAt()).isNotNull();
				});
	}

	@Test
	void should_returnEmpty_when_emailNotFound() {
		Optional<User> result = adapter.findByEmail("nobody@example.com");

		assertThat(result).isEmpty();
	}

	@Test
	void should_reportExistence_when_emailAlreadyRegistered() {
		adapter.save(User.createNew("taken@example.com", "pw", "Taken"));

		assertThat(adapter.existsByEmail("taken@example.com")).isTrue();
		assertThat(adapter.existsByEmail("free@example.com")).isFalse();
	}

	@Test
	void should_rejectDuplicateEmail_when_uniqueConstraintViolated() {
		adapter.save(User.createNew("dup@example.com", "pw1", "First"));
		jpaRepository.flush();

		assertThatThrownBy(() -> {
			adapter.save(User.createNew("dup@example.com", "pw2", "Second"));
			jpaRepository.flush();
		}).isInstanceOf(DataIntegrityViolationException.class);
	}

	@Test
	void should_findUserById_when_present() {
		User saved = adapter.save(User.createNew("byid@example.com", "pw", "ById"));

		assertThat(adapter.findById(saved.id()))
				.hasValueSatisfying(found -> assertThat(found.email()).isEqualTo("byid@example.com"));
	}
}

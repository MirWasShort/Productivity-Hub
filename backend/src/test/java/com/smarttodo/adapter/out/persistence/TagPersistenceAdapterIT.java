package com.smarttodo.adapter.out.persistence;

import com.smarttodo.TestcontainersConfiguration;
import com.smarttodo.domain.model.Tag;
import com.smarttodo.domain.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.dao.DataIntegrityViolationException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@DataJpaTest
@Import({TestcontainersConfiguration.class, TagPersistenceAdapter.class,
		UserPersistenceAdapter.class})
class TagPersistenceAdapterIT {

	@Autowired
	private TagPersistenceAdapter adapter;

	@Autowired
	private UserPersistenceAdapter userAdapter;

	@Autowired
	private TagJpaRepository jpaRepository;

	private User alice;

	@BeforeEach
	void setUp() {
		alice = userAdapter.save(User.createNew("alice@example.com", "pw", "Alice"));
	}

	@Test
	void should_persistAndReload_when_saved() {
		Tag tag = Tag.createNew(alice.id(), "urgente", "#FF0000");

		adapter.save(tag);

		assertThat(adapter.findAllByUserId(alice.id()))
				.singleElement()
				.satisfies(found -> {
					assertThat(found.name()).isEqualTo("urgente");
					assertThat(found.color()).isEqualTo("#FF0000");
				});
	}

	@Test
	void should_detectExistingName_caseInsensitively() {
		adapter.save(Tag.createNew(alice.id(), "Urgente", null));

		assertThat(adapter.existsByUserIdAndName(alice.id(), "urgente")).isTrue();
		assertThat(adapter.existsByUserIdAndName(alice.id(), "URGENTE")).isTrue();
		assertThat(adapter.existsByUserIdAndName(alice.id(), "altro")).isFalse();
	}

	@Test
	void should_enforceUniquenessAtDatabaseLevel_when_raceSlipsThrough() {
		adapter.save(Tag.createNew(alice.id(), "casa", null));
		jpaRepository.flush();

		assertThatThrownBy(() -> {
			adapter.save(Tag.createNew(alice.id(), "CASA", null));
			jpaRepository.flush();
		}).isInstanceOf(DataIntegrityViolationException.class);
	}
}

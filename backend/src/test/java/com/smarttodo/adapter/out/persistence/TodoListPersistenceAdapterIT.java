package com.smarttodo.adapter.out.persistence;

import com.smarttodo.TestcontainersConfiguration;
import com.smarttodo.domain.model.TodoList;
import com.smarttodo.domain.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@Import({TestcontainersConfiguration.class, TodoListPersistenceAdapter.class,
		UserPersistenceAdapter.class})
class TodoListPersistenceAdapterIT {

	@Autowired
	private TodoListPersistenceAdapter adapter;

	@Autowired
	private UserPersistenceAdapter userAdapter;

	private User alice;
	private User bob;

	@BeforeEach
	void setUp() {
		alice = userAdapter.save(User.createNew("alice@example.com", "pw", "Alice"));
		bob = userAdapter.save(User.createNew("bob@example.com", "pw", "Bob"));
	}

	@Test
	void should_persistAndReload_when_saved() {
		TodoList list = TodoList.createNew(alice.id(), "Lavoro", "#4F46E5");

		adapter.save(list);

		assertThat(adapter.findByIdAndUserId(list.id(), alice.id()))
				.hasValueSatisfying(found -> {
					assertThat(found.name()).isEqualTo("Lavoro");
					assertThat(found.color()).isEqualTo("#4F46E5");
				});
	}

	@Test
	void should_returnOnlyOwnLists_when_listing() {
		adapter.save(TodoList.createNew(alice.id(), "Mia", null));
		adapter.save(TodoList.createNew(bob.id(), "Di Bob", null));

		assertThat(adapter.findAllByUserId(alice.id()))
				.hasSize(1)
				.allSatisfy(l -> assertThat(l.name()).isEqualTo("Mia"));
	}

	@Test
	void should_scopeLookupToOwner_when_findingById() {
		TodoList list = TodoList.createNew(alice.id(), "Privata", null);
		adapter.save(list);

		assertThat(adapter.findByIdAndUserId(list.id(), bob.id())).isEmpty();
	}

	@Test
	void should_removeList_when_deleted() {
		TodoList list = TodoList.createNew(alice.id(), "Da cancellare", null);
		adapter.save(list);

		adapter.deleteById(list.id());

		assertThat(adapter.findByIdAndUserId(list.id(), alice.id())).isEmpty();
	}
}

package com.smarttodo.adapter.out.persistence;

import java.time.Duration;
import java.time.Instant;

import com.smarttodo.TestcontainersConfiguration;
import com.smarttodo.domain.model.RefreshToken;
import com.smarttodo.domain.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@Import({TestcontainersConfiguration.class, RefreshTokenPersistenceAdapter.class,
		UserPersistenceAdapter.class})
class RefreshTokenPersistenceAdapterIT {

	@Autowired
	private RefreshTokenPersistenceAdapter adapter;

	@Autowired
	private UserPersistenceAdapter userAdapter;

	private User owner;

	@BeforeEach
	void setUp() {
		owner = userAdapter.save(User.createNew("owner@example.com", "pw", "Owner"));
	}

	@Test
	void should_persistAndFindByHash_when_saved() {
		RefreshToken token = RefreshToken.createNew(owner.id(), "hash-abc", Duration.ofDays(7));

		adapter.save(token);

		assertThat(adapter.findByTokenHash("hash-abc"))
				.hasValueSatisfying(found -> {
					assertThat(found.userId()).isEqualTo(owner.id());
					assertThat(found.revoked()).isFalse();
					assertThat(found.expiresAt()).isAfter(Instant.now().plus(Duration.ofDays(6)));
				});
	}

	@Test
	void should_returnEmpty_when_hashUnknown() {
		assertThat(adapter.findByTokenHash("missing")).isEmpty();
	}

	@Test
	void should_persistRevocation_when_tokenIsRevokedAndSaved() {
		RefreshToken token = RefreshToken.createNew(owner.id(), "hash-revoke", Duration.ofDays(7));
		adapter.save(token);

		adapter.save(token.revoke());

		assertThat(adapter.findByTokenHash("hash-revoke"))
				.hasValueSatisfying(found -> assertThat(found.revoked()).isTrue());
	}
}

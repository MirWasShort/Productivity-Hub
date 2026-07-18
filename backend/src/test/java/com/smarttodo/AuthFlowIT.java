package com.smarttodo;

import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * The whole system exercised over real HTTP against a real database:
 * registration, task CRUD, per-user isolation and refresh rotation in
 * one journey. If this passes, the wiring is right end to end.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class AuthFlowIT {

	@Autowired
	private TestRestTemplate rest;

	@SuppressWarnings({"unchecked", "rawtypes"})
	private ResponseEntity<Map<String, Object>> postJson(String path, String body, String bearer) {
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		if (bearer != null) {
			headers.setBearerAuth(bearer);
		}
		return (ResponseEntity) rest.exchange(path, HttpMethod.POST,
				new HttpEntity<>(body, headers), Map.class);
	}

	@SuppressWarnings({"unchecked", "rawtypes"})
	private ResponseEntity<Map<String, Object>> getJson(String path, String bearer) {
		HttpHeaders headers = new HttpHeaders();
		headers.setBearerAuth(bearer);
		return (ResponseEntity) rest.exchange(path, HttpMethod.GET,
				new HttpEntity<>(headers), Map.class);
	}

	@Test
	void fullJourney_register_crud_isolation_refreshRotation() {
		// --- Alice registers and gets a token pair ---
		ResponseEntity<Map<String, Object>> registered = postJson("/api/v1/auth/register", """
				{"email":"alice@it.dev","password":"Password1!","displayName":"Alice"}
				""", null);
		assertThat(registered.getStatusCode()).isEqualTo(HttpStatus.CREATED);
		String aliceAccess = (String) registered.getBody().get("accessToken");
		String aliceRefresh = (String) registered.getBody().get("refreshToken");
		assertThat(aliceAccess).isNotBlank();
		assertThat(aliceRefresh).isNotBlank();

		// --- Alice creates a task ---
		ResponseEntity<Map<String, Object>> created = postJson("/api/v1/tasks", """
				{"title":"Comprare il latte","priority":"HIGH"}
				""", aliceAccess);
		assertThat(created.getStatusCode()).isEqualTo(HttpStatus.CREATED);
		String taskId = (String) created.getBody().get("id");

		// --- Alice sees it in her list ---
		ResponseEntity<Map<String, Object>> aliceList = getJson("/api/v1/tasks", aliceAccess);
		assertThat(aliceList.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat((Iterable<?>) aliceList.getBody().get("items")).hasSize(1);

		// --- Bob registers: cannot see Alice's task, his list is empty ---
		ResponseEntity<Map<String, Object>> bobRegistered = postJson("/api/v1/auth/register", """
				{"email":"bob@it.dev","password":"Password1!","displayName":"Bob"}
				""", null);
		String bobAccess = (String) bobRegistered.getBody().get("accessToken");

		ResponseEntity<Map<String, Object>> bobReadsAlice =
				getJson("/api/v1/tasks/" + taskId, bobAccess);
		assertThat(bobReadsAlice.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);

		ResponseEntity<Map<String, Object>> bobList = getJson("/api/v1/tasks", bobAccess);
		assertThat((Iterable<?>) bobList.getBody().get("items")).isEmpty();

		// --- Refresh rotates: new pair works, old refresh token dies ---
		ResponseEntity<Map<String, Object>> refreshed = postJson("/api/v1/auth/refresh",
				"{\"refreshToken\":\"" + aliceRefresh + "\"}", null);
		assertThat(refreshed.getStatusCode()).isEqualTo(HttpStatus.OK);
		String newAccess = (String) refreshed.getBody().get("accessToken");
		assertThat((String) refreshed.getBody().get("refreshToken")).isNotEqualTo(aliceRefresh);

		ResponseEntity<Map<String, Object>> reuseOldRefresh = postJson("/api/v1/auth/refresh",
				"{\"refreshToken\":\"" + aliceRefresh + "\"}", null);
		assertThat(reuseOldRefresh.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);

		// --- The refreshed access token drives the task to DONE ---
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		headers.setBearerAuth(newAccess);
		ResponseEntity<Map> updated = rest.exchange("/api/v1/tasks/" + taskId, HttpMethod.PUT,
				new HttpEntity<>("""
						{"title":"Comprare il latte","status":"DONE","priority":"HIGH"}
						""", headers), Map.class);
		assertThat(updated.getStatusCode()).isEqualTo(HttpStatus.OK);
		assertThat(updated.getBody().get("status")).isEqualTo("DONE");

		// --- Delete and verify it is gone ---
		ResponseEntity<Void> deleted = rest.exchange("/api/v1/tasks/" + taskId,
				HttpMethod.DELETE, new HttpEntity<>(headers), Void.class);
		assertThat(deleted.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);

		ResponseEntity<Map<String, Object>> gone = getJson("/api/v1/tasks/" + taskId, aliceAccess);
		assertThat(gone.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
	}
}

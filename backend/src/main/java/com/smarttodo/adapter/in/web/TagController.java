package com.smarttodo.adapter.in.web;

import java.util.List;
import java.util.UUID;

import com.smarttodo.adapter.in.web.dto.TagRequest;
import com.smarttodo.adapter.in.web.dto.TagResponse;
import com.smarttodo.application.port.in.TagUseCases;
import com.smarttodo.application.port.in.TagUseCases.CreateTagCommand;
import com.smarttodo.application.port.in.TagUseCases.UpdateTagCommand;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/tags")
public class TagController {

	private final TagUseCases useCases;

	public TagController(TagUseCases useCases) {
		this.useCases = useCases;
	}

	@GetMapping
	public List<TagResponse> list(@AuthenticationPrincipal UUID userId) {
		return useCases.list(userId).stream().map(TagResponse::from).toList();
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public TagResponse create(@AuthenticationPrincipal UUID userId,
			@Valid @RequestBody TagRequest request) {
		return TagResponse.from(useCases.create(
				new CreateTagCommand(userId, request.name(), request.color())));
	}

	@PutMapping("/{tagId}")
	public TagResponse update(@AuthenticationPrincipal UUID userId,
			@PathVariable UUID tagId, @Valid @RequestBody TagRequest request) {
		return TagResponse.from(useCases.update(
				new UpdateTagCommand(userId, tagId, request.name(), request.color())));
	}

	@DeleteMapping("/{tagId}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@AuthenticationPrincipal UUID userId, @PathVariable UUID tagId) {
		useCases.delete(userId, tagId);
	}
}

package com.smarttodo.adapter.in.web.dto;

import java.util.UUID;

import com.smarttodo.domain.model.Tag;

public record TagResponse(UUID id, String name, String color) {

	public static TagResponse from(Tag tag) {
		return new TagResponse(tag.id(), tag.name(), tag.color());
	}
}

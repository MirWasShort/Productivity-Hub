package com.smarttodo.application.exception;

public class TagAlreadyExistsException extends RuntimeException {

	public TagAlreadyExistsException(String name) {
		super("Tag already exists: " + name);
	}
}

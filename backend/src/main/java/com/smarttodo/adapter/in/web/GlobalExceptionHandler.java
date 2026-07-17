package com.smarttodo.adapter.in.web;

import com.smarttodo.adapter.in.web.dto.ErrorResponse;
import com.smarttodo.application.exception.EmailAlreadyExistsException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(EmailAlreadyExistsException.class)
	@ResponseStatus(HttpStatus.CONFLICT)
	public ErrorResponse handleEmailAlreadyExists(EmailAlreadyExistsException ex,
			HttpServletRequest request) {
		return ErrorResponse.of(HttpStatus.CONFLICT.value(), "Conflict",
				ex.getMessage(), request.getRequestURI());
	}
}

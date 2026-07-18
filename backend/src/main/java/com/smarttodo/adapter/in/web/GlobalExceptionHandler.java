package com.smarttodo.adapter.in.web;

import java.util.LinkedHashMap;
import java.util.Map;

import com.smarttodo.adapter.in.web.dto.ErrorResponse;
import com.smarttodo.application.exception.EmailAlreadyExistsException;
import com.smarttodo.application.exception.InvalidCredentialsException;
import com.smarttodo.application.exception.InvalidRefreshTokenException;
import com.smarttodo.application.exception.ResourceNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

	private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

	@ExceptionHandler(MethodArgumentNotValidException.class)
	@ResponseStatus(HttpStatus.BAD_REQUEST)
	public ErrorResponse handleValidationErrors(MethodArgumentNotValidException ex,
			HttpServletRequest request) {
		Map<String, String> fieldErrors = new LinkedHashMap<>();
		for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
			fieldErrors.putIfAbsent(fieldError.getField(), fieldError.getDefaultMessage());
		}
		return ErrorResponse.withFieldErrors(HttpStatus.BAD_REQUEST.value(), "Bad Request",
				"Validation failed", request.getRequestURI(), fieldErrors);
	}

	@ExceptionHandler(org.springframework.http.converter.HttpMessageNotReadableException.class)
	@ResponseStatus(HttpStatus.BAD_REQUEST)
	public ErrorResponse handleUnreadableBody(
			org.springframework.http.converter.HttpMessageNotReadableException ex,
			HttpServletRequest request) {
		return ErrorResponse.of(HttpStatus.BAD_REQUEST.value(), "Bad Request",
				"Malformed request body", request.getRequestURI());
	}

	@ExceptionHandler(Exception.class)
	@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
	public ErrorResponse handleUnexpected(Exception ex, HttpServletRequest request) {
		log.error("Unhandled exception processing {} {}", request.getMethod(),
				request.getRequestURI(), ex);
		return ErrorResponse.of(HttpStatus.INTERNAL_SERVER_ERROR.value(),
				"Internal Server Error", "An unexpected error occurred",
				request.getRequestURI());
	}

	@ExceptionHandler(ResourceNotFoundException.class)
	@ResponseStatus(HttpStatus.NOT_FOUND)
	public ErrorResponse handleResourceNotFound(ResourceNotFoundException ex,
			HttpServletRequest request) {
		return ErrorResponse.of(HttpStatus.NOT_FOUND.value(), "Not Found",
				ex.getMessage(), request.getRequestURI());
	}

	@ExceptionHandler(EmailAlreadyExistsException.class)
	@ResponseStatus(HttpStatus.CONFLICT)
	public ErrorResponse handleEmailAlreadyExists(EmailAlreadyExistsException ex,
			HttpServletRequest request) {
		return ErrorResponse.of(HttpStatus.CONFLICT.value(), "Conflict",
				ex.getMessage(), request.getRequestURI());
	}

	@ExceptionHandler({InvalidCredentialsException.class, InvalidRefreshTokenException.class})
	@ResponseStatus(HttpStatus.UNAUTHORIZED)
	public ErrorResponse handleAuthenticationFailures(RuntimeException ex,
			HttpServletRequest request) {
		return ErrorResponse.of(HttpStatus.UNAUTHORIZED.value(), "Unauthorized",
				ex.getMessage(), request.getRequestURI());
	}
}

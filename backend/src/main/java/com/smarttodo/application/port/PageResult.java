package com.smarttodo.application.port;

import java.util.List;

/**
 * Framework-free pagination result, shared between driving and driven ports.
 */
public record PageResult<T>(
		List<T> items,
		int page,
		int size,
		long totalElements,
		int totalPages) {
}

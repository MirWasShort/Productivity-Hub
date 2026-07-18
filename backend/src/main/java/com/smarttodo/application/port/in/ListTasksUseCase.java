package com.smarttodo.application.port.in;

import java.util.UUID;

import com.smarttodo.application.port.PageResult;
import com.smarttodo.domain.model.Task;

public interface ListTasksUseCase {

	PageResult<Task> list(UUID userId, int page, int size);
}

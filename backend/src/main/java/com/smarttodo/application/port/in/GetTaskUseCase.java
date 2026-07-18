package com.smarttodo.application.port.in;

import java.util.UUID;

import com.smarttodo.domain.model.Task;

public interface GetTaskUseCase {

	Task get(UUID userId, UUID taskId);
}

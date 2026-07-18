package com.smarttodo.application.port.in;

import java.util.UUID;

public interface DeleteTaskUseCase {

	void delete(UUID userId, UUID taskId);
}

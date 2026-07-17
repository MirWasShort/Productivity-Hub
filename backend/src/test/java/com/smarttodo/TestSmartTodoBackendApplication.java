package com.smarttodo;

import org.springframework.boot.SpringApplication;

public class TestSmartTodoBackendApplication {

	public static void main(String[] args) {
		SpringApplication.from(SmartTodoBackendApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}

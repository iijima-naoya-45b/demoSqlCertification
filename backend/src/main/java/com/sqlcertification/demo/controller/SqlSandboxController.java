package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.SqlExecutionRequest;
import com.sqlcertification.demo.model.SqlExecutionResult;
import com.sqlcertification.demo.service.SqlSandboxService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/sandbox")
public class SqlSandboxController {

    private final SqlSandboxService sqlSandboxService;

    public SqlSandboxController(SqlSandboxService sqlSandboxService) {
        this.sqlSandboxService = sqlSandboxService;
    }

    @PostMapping("/execute")
    public ResponseEntity<SqlExecutionResult> execute(@Valid @RequestBody SqlExecutionRequest request) {
        SqlExecutionResult result = sqlSandboxService.execute(request.getSql(), request.getExerciseId());
        return ResponseEntity.ok(result);
    }
}

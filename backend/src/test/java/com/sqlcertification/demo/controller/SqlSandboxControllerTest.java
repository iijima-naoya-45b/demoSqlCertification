package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.exception.GlobalExceptionHandler;
import com.sqlcertification.demo.exception.SqlSandboxBlockedException;
import com.sqlcertification.demo.model.SqlExecutionResult;
import com.sqlcertification.demo.service.SqlSandboxService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(SqlSandboxController.class)
@Import(GlobalExceptionHandler.class)
class SqlSandboxControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private SqlSandboxService sqlSandboxService;

    @Test
    void execute_shouldReturnResult() throws Exception {
        SqlExecutionResult result = new SqlExecutionResult();
        result.setAuditStatus("ALLOWED");
        result.setColumns(List.of("customerId"));
        result.setRows(List.of(List.of(1)));
        result.setRowCount(1);
        result.setExecutionTimeMs(12L);

        when(sqlSandboxService.execute(anyString(), isNull())).thenReturn(result);

        mockMvc.perform(post("/api/sandbox/execute")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"sql\":\"SELECT 1\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.auditStatus").value("ALLOWED"))
                .andExpect(jsonPath("$.rowCount").value(1));
    }

    @Test
    void execute_shouldReturn403WhenBlocked() throws Exception {
        when(sqlSandboxService.execute(anyString(), isNull()))
                .thenThrow(new SqlSandboxBlockedException(
                        "DELETE文は実行できません",
                        "DELETE"
                ));

        mockMvc.perform(post("/api/sandbox/execute")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"sql\":\"DELETE FROM customers\"}"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.auditStatus").value("BLOCKED"))
                .andExpect(jsonPath("$.detectedKeyword").value("DELETE"));
    }
}

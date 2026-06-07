package com.sqlcertification.demo.service;

import com.sqlcertification.demo.exception.SqlSandboxBlockedException;
import com.sqlcertification.demo.model.SqlExecutionResult;
import com.sqlcertification.demo.security.SqlSecurityValidator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Service
public class SqlSandboxService {

    private final JdbcTemplate jdbcTemplate;
    private final SqlSecurityValidator sqlSecurityValidator;
    private final SandboxAuditService sandboxAuditService;
    private final int maxRows;
    private final int queryTimeoutSeconds;

    public SqlSandboxService(
            JdbcTemplate jdbcTemplate,
            SqlSecurityValidator sqlSecurityValidator,
            SandboxAuditService sandboxAuditService,
            @Value("${app.sandbox.max-rows:500}") int maxRows,
            @Value("${app.sandbox.query-timeout-seconds:15}") int queryTimeoutSeconds
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.sqlSecurityValidator = sqlSecurityValidator;
        this.sandboxAuditService = sandboxAuditService;
        this.maxRows = maxRows;
        this.queryTimeoutSeconds = queryTimeoutSeconds;
    }

    @Transactional(readOnly = true)
    public SqlExecutionResult execute(String sql, String exerciseId) {
        try {
            sqlSecurityValidator.validate(sql);
        } catch (SqlSandboxBlockedException ex) {
            sandboxAuditService.logBlocked(sql, ex.getDetectedKeyword(), ex.getMessage(), exerciseId);
            throw ex;
        }

        jdbcTemplate.setMaxRows(maxRows + 1);
        jdbcTemplate.setQueryTimeout(queryTimeoutSeconds);

        long startedAt = System.currentTimeMillis();

        try {
            SqlExecutionResult result = jdbcTemplate.query(sql, resultSet -> {
                ResultSetMetaData metaData = resultSet.getMetaData();
                int columnCount = metaData.getColumnCount();

                List<String> columns = new ArrayList<>();
                for (int columnIndex = 1; columnIndex <= columnCount; columnIndex++) {
                    columns.add(metaData.getColumnLabel(columnIndex));
                }

                List<List<Object>> rows = new ArrayList<>();
                int rowIndex = 0;
                boolean truncated = false;

                while (resultSet.next()) {
                    if (rowIndex >= maxRows) {
                        truncated = true;
                        break;
                    }
                    rows.add(extractRow(resultSet, columnCount));
                    rowIndex++;
                }

                SqlExecutionResult executionResult = new SqlExecutionResult();
                executionResult.setAuditStatus("ALLOWED");
                executionResult.setColumns(columns);
                executionResult.setRows(rows);
                executionResult.setRowCount(rows.size());
                executionResult.setTruncated(truncated);
                if (truncated) {
                    executionResult.setMessage(
                            "SqlSandboxService.execute: 結果が "
                                    + maxRows
                                    + " 行を超えたため切り捨てました。"
                    );
                }
                return executionResult;
            });

            long executionTimeMs = System.currentTimeMillis() - startedAt;
            result.setExecutionTimeMs(executionTimeMs);
            sandboxAuditService.logAllowed(sql, result.getRowCount(), executionTimeMs, exerciseId);
            return result;
        } catch (Exception ex) {
            throw new IllegalArgumentException(
                    "SqlSandboxService.execute: SQL実行エラー。message=" + ex.getMessage(),
                    ex
            );
        }
    }

    private List<Object> extractRow(java.sql.ResultSet resultSet, int columnCount) throws SQLException {
        List<Object> row = new ArrayList<>();
        for (int columnIndex = 1; columnIndex <= columnCount; columnIndex++) {
            row.add(resultSet.getObject(columnIndex));
        }
        return row;
    }
}

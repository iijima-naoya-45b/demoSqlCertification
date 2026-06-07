package com.sqlcertification.demo.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sqlcertification.demo.mapper.SandboxAuditMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class SandboxAuditService {

    private static final Logger logger = LoggerFactory.getLogger(SandboxAuditService.class);

    private final SandboxAuditMapper sandboxAuditMapper;
    private final ObjectMapper objectMapper;

    public SandboxAuditService(SandboxAuditMapper sandboxAuditMapper, ObjectMapper objectMapper) {
        this.sandboxAuditMapper = sandboxAuditMapper;
        this.objectMapper = objectMapper;
    }

    public void logAllowed(String sql, int rowCount, long executionTimeMs, String exerciseId) {
        Map<String, Object> detail = new LinkedHashMap<>();
        detail.put("sql", truncate(sql));
        detail.put("rowCount", rowCount);
        detail.put("executionTimeMs", executionTimeMs);
        detail.put("exerciseId", exerciseId);
        detail.put("result", "ALLOWED");

        persistAudit("SELECT", detail);
        logger.info("SandboxAuditService.logAllowed: rowCount={}, executionTimeMs={}", rowCount, executionTimeMs);
    }

    public void logBlocked(String sql, String detectedKeyword, String reason, String exerciseId) {
        Map<String, Object> detail = new LinkedHashMap<>();
        detail.put("sql", truncate(sql));
        detail.put("detectedKeyword", detectedKeyword);
        detail.put("reason", reason);
        detail.put("exerciseId", exerciseId);
        detail.put("result", "BLOCKED");

        String actionType = mapBlockedActionType(detectedKeyword);
        persistAudit(actionType, detail);
        logger.warn(
                "SandboxAuditService.logBlocked: detectedKeyword={}, reason={}",
                detectedKeyword,
                reason
        );
    }

    private String mapBlockedActionType(String detectedKeyword) {
        if ("DELETE".equals(detectedKeyword)) {
            return "DELETE";
        }
        if ("UPDATE".equals(detectedKeyword) || "INSERT".equals(detectedKeyword)) {
            return "UPDATE";
        }
        if ("DROP".equals(detectedKeyword) || "TRUNCATE".equals(detectedKeyword) || "ALTER".equals(detectedKeyword)) {
            return "DELETE";
        }
        return "SELECT";
    }

    private void persistAudit(String actionType, Map<String, Object> detail) {
        try {
            String detailJson = objectMapper.writeValueAsString(detail);
            sandboxAuditMapper.insertAuditLog(actionType, (String) detail.get("sql"), detailJson);
        } catch (JsonProcessingException ex) {
            logger.error(
                    "SandboxAuditService.persistAudit: JSON変換に失敗しました。actionType={}, message={}",
                    actionType,
                    ex.getMessage()
            );
        } catch (Exception ex) {
            logger.error(
                    "SandboxAuditService.persistAudit: auditLogs への記録に失敗しました。actionType={}, message={}",
                    actionType,
                    ex.getMessage()
            );
        }
    }

    private String truncate(String sql) {
        if (sql == null) {
            return "";
        }
        return sql.length() > 2000 ? sql.substring(0, 2000) + "..." : sql;
    }
}

package com.sqlcertification.demo.exception;

public class SqlSandboxBlockedException extends RuntimeException {

    private final String detectedKeyword;
    private final String auditStatus;

    public SqlSandboxBlockedException(String message, String detectedKeyword) {
        super(message);
        this.detectedKeyword = detectedKeyword;
        this.auditStatus = "BLOCKED";
    }

    public String getDetectedKeyword() {
        return detectedKeyword;
    }

    public String getAuditStatus() {
        return auditStatus;
    }
}

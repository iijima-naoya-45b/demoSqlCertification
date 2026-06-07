package com.sqlcertification.demo.model;

public class SqlBlockedResult {

    private String auditStatus;
    private String blockedReason;
    private String detectedKeyword;

    public SqlBlockedResult(String blockedReason, String detectedKeyword) {
        this.auditStatus = "BLOCKED";
        this.blockedReason = blockedReason;
        this.detectedKeyword = detectedKeyword;
    }

    public String getAuditStatus() {
        return auditStatus;
    }

    public void setAuditStatus(String auditStatus) {
        this.auditStatus = auditStatus;
    }

    public String getBlockedReason() {
        return blockedReason;
    }

    public void setBlockedReason(String blockedReason) {
        this.blockedReason = blockedReason;
    }

    public String getDetectedKeyword() {
        return detectedKeyword;
    }

    public void setDetectedKeyword(String detectedKeyword) {
        this.detectedKeyword = detectedKeyword;
    }
}

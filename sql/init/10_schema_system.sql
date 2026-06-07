-- ============================================================
-- システムドメイン (System)
-- テーブル数: 7
-- ============================================================

CREATE TABLE userAccounts (
    userAccountId      SERIAL PRIMARY KEY,
    employeeId         INTEGER REFERENCES employees(employeeId),
    customerId         INTEGER REFERENCES customers(customerId),
    username           VARCHAR(50) NOT NULL UNIQUE,
    email              VARCHAR(255) NOT NULL UNIQUE,
    passwordHash       VARCHAR(255) NOT NULL,
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    lastLoginAt        TIMESTAMP,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (employeeId IS NOT NULL OR customerId IS NOT NULL)
);

COMMENT ON TABLE userAccounts IS 'ユーザーアカウント（従業員・顧客ログイン）';

CREATE TABLE roles (
    roleId             SERIAL PRIMARY KEY,
    roleCode           VARCHAR(30) NOT NULL UNIQUE,
    roleName           VARCHAR(100) NOT NULL,
    description        VARCHAR(200),
    isActive           BOOLEAN NOT NULL DEFAULT TRUE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE roles IS 'ロール定義（権限グループ）';

CREATE TABLE permissions (
    permissionId       SERIAL PRIMARY KEY,
    permissionCode     VARCHAR(50) NOT NULL UNIQUE,
    permissionName     VARCHAR(100) NOT NULL,
    resourceName       VARCHAR(50) NOT NULL,
    actionName         VARCHAR(30) NOT NULL,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE permissions IS '権限定義（リソース・アクション）';

CREATE TABLE rolePermissions (
    rolePermissionId   SERIAL PRIMARY KEY,
    roleId             INTEGER NOT NULL REFERENCES roles(roleId) ON DELETE CASCADE,
    permissionId       INTEGER NOT NULL REFERENCES permissions(permissionId) ON DELETE CASCADE,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (roleId, permissionId)
);

COMMENT ON TABLE rolePermissions IS 'ロールと権限の中間テーブル';

CREATE TABLE userRoleMappings (
    userRoleMappingId  SERIAL PRIMARY KEY,
    userAccountId      INTEGER NOT NULL REFERENCES userAccounts(userAccountId) ON DELETE CASCADE,
    roleId             INTEGER NOT NULL REFERENCES roles(roleId) ON DELETE CASCADE,
    assignedAt         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assignedByUserAccountId INTEGER REFERENCES userAccounts(userAccountId),
    UNIQUE (userAccountId, roleId)
);

COMMENT ON TABLE userRoleMappings IS 'ユーザーとロールの割当';

CREATE TABLE auditLogs (
    auditLogId         BIGSERIAL PRIMARY KEY,
    userAccountId      INTEGER REFERENCES userAccounts(userAccountId),
    tableName          VARCHAR(100) NOT NULL,
    recordId           INTEGER,
    actionType         VARCHAR(20) NOT NULL
        CHECK (actionType IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT')),
    oldValues          JSONB,
    newValues          JSONB,
    ipAddress          INET,
    occurredAt         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE auditLogs IS '監査ログ（テーブル操作の記録）';

CREATE TABLE batchJobLogs (
    batchJobLogId      BIGSERIAL PRIMARY KEY,
    jobName            VARCHAR(100) NOT NULL,
    jobStatus          VARCHAR(20) NOT NULL DEFAULT 'running'
        CHECK (jobStatus IN ('running', 'completed', 'failed', 'cancelled')),
    startedAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finishedAt         TIMESTAMP,
    processedCount     INTEGER NOT NULL DEFAULT 0 CHECK (processedCount >= 0),
    errorCount         INTEGER NOT NULL DEFAULT 0 CHECK (errorCount >= 0),
    errorMessage       TEXT,
    createdAt          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE batchJobLogs IS 'バッチジョブ実行ログ（処理件数・エラー）';

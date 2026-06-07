package com.sqlcertification.demo.security;

import com.sqlcertification.demo.exception.SqlSandboxBlockedException;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

@Component
public class SqlSecurityValidator {

    private static final List<String> blockedKeywords = List.of(
            "DELETE", "DROP", "TRUNCATE", "ALTER", "CREATE", "INSERT", "UPDATE",
            "GRANT", "REVOKE", "COPY", "VACUUM", "REINDEX", "CLUSTER", "REFRESH",
            "CALL", "DO", "EXECUTE", "MERGE", "REPLACE", "LOAD", "IMPORT",
            "PG_SLEEP", "PG_CANCEL_BACKEND", "PG_TERMINATE_BACKEND", "LOCK", "UNLOCK"
    );

    private static final Pattern allowedStartPattern = Pattern.compile(
            "^(SELECT|WITH|EXPLAIN|SHOW|VALUES)\\b",
            Pattern.CASE_INSENSITIVE | Pattern.DOTALL
    );

    private static final Pattern selectIntoPattern = Pattern.compile(
            "\\bSELECT\\b[\\s\\S]*?\\bINTO\\b",
            Pattern.CASE_INSENSITIVE
    );

    private static final Pattern multipleStatementPattern = Pattern.compile(";\\s*\\S");

    public void validate(String rawSql) {
        if (rawSql == null || rawSql.isBlank()) {
            throw new SqlSandboxBlockedException(
                    "SqlSecurityValidator.validate: SQLが空です。SELECT文を入力してください。",
                    "EMPTY"
            );
        }

        String normalizedSql = stripComments(rawSql).trim();
        if (normalizedSql.isEmpty()) {
            throw new SqlSandboxBlockedException(
                    "SqlSecurityValidator.validate: 有効なSQLが見つかりません。",
                    "EMPTY"
            );
        }

        if (multipleStatementPattern.matcher(normalizedSql).find()) {
            throw new SqlSandboxBlockedException(
                    "SqlSecurityValidator.validate: 複数SQLの同時実行は許可されていません。",
                    "MULTI_STATEMENT"
            );
        }

        String upperSql = normalizedSql.toUpperCase(Locale.ROOT);

        for (String keyword : blockedKeywords) {
            Pattern keywordPattern = Pattern.compile("\\b" + keyword + "\\b");
            if (keywordPattern.matcher(upperSql).find()) {
                throw new SqlSandboxBlockedException(
                        "SqlSecurityValidator.validate: "
                                + keyword + " 文は演習サンドボックスでは実行できません（監査により拒否）。",
                        keyword
                );
            }
        }

        if (selectIntoPattern.matcher(normalizedSql).find()) {
            throw new SqlSandboxBlockedException(
                    "SqlSecurityValidator.validate: SELECT ... INTO は許可されていません。",
                    "SELECT_INTO"
            );
        }

        if (!allowedStartPattern.matcher(normalizedSql).find()) {
            throw new SqlSandboxBlockedException(
                    "SqlSecurityValidator.validate: 許可されているのは SELECT / WITH / EXPLAIN / SHOW のみです。",
                    "DISALLOWED_STATEMENT"
            );
        }
    }

    String stripComments(String sql) {
        String withoutBlockComments = sql.replaceAll("/\\*[\\s\\S]*?\\*/", " ");
        return withoutBlockComments.replaceAll("(?m)--.*$", " ");
    }
}

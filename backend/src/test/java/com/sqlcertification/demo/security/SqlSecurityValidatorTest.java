package com.sqlcertification.demo.security;

import com.sqlcertification.demo.exception.SqlSandboxBlockedException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class SqlSecurityValidatorTest {

    private SqlSecurityValidator validator;

    @BeforeEach
    void setUp() {
        validator = new SqlSecurityValidator();
    }

    @Test
    void validate_shouldAllowSelectQuery() {
        assertThatCode(() -> validator.validate("SELECT customerId, customerName FROM customers LIMIT 10"))
                .doesNotThrowAnyException();
    }

    @Test
    void validate_shouldAllowWithClause() {
        assertThatCode(() -> validator.validate(
                "WITH ranked AS (SELECT productId FROM products) SELECT * FROM ranked"
        )).doesNotThrowAnyException();
    }

    @Test
    void validate_shouldAllowExplainAnalyze() {
        assertThatCode(() -> validator.validate(
                "EXPLAIN ANALYZE SELECT * FROM customers WHERE prefecture = '東京都'"
        )).doesNotThrowAnyException();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "DELETE FROM customers WHERE customerId = 1",
            "delete from orders",
            "DROP TABLE customers",
            "TRUNCATE customers",
            "UPDATE customers SET email = 'x@y.z'",
            "INSERT INTO customers (customerName) VALUES ('test')",
            "CREATE TABLE evil (id int)",
            "ALTER TABLE customers ADD COLUMN x int",
            "CALL sp_confirmOrder(10)"
    })
    void validate_shouldBlockDestructiveStatements(String sql) {
        assertThatThrownBy(() -> validator.validate(sql))
                .isInstanceOf(SqlSandboxBlockedException.class)
                .hasMessageContaining("監査により拒否");
    }

    @Test
    void validate_shouldBlockMultipleStatements() {
        assertThatThrownBy(() -> validator.validate("SELECT 1; SELECT 2"))
                .isInstanceOf(SqlSandboxBlockedException.class)
                .hasMessageContaining("複数SQL");
    }

    @Test
    void validate_shouldBlockSelectInto() {
        assertThatThrownBy(() -> validator.validate("SELECT customerId INTO TEMP t FROM customers"))
                .isInstanceOf(SqlSandboxBlockedException.class)
                .hasMessageContaining("SELECT ... INTO");
    }

    @Test
    void validate_shouldAllowSqlWithStrippedBlockComment() {
        assertThatCode(() -> validator.validate(
                "SELECT customerId FROM customers /* practice query */ LIMIT 5"
        )).doesNotThrowAnyException();
    }
}

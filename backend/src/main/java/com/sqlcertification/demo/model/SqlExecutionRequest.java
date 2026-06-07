package com.sqlcertification.demo.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class SqlExecutionRequest {

    @NotBlank(message = "sql は必須です")
    @Size(max = 10000, message = "sql は10000文字以内で入力してください")
    private String sql;

    private String exerciseId;

    public String getSql() {
        return sql;
    }

    public void setSql(String sql) {
        this.sql = sql;
    }

    public String getExerciseId() {
        return exerciseId;
    }

    public void setExerciseId(String exerciseId) {
        this.exerciseId = exerciseId;
    }
}

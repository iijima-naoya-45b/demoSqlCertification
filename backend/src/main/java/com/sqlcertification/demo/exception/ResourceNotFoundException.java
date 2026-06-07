package com.sqlcertification.demo.exception;

public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String functionName, String parameterName, Object parameterValue) {
        super(String.format(
                "%s: 指定されたリソースが見つかりません。%s=%s",
                functionName,
                parameterName,
                parameterValue
        ));
    }
}

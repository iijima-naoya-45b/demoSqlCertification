package com.sqlcertification.demo.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface SandboxAuditMapper {

    void insertAuditLog(
            @Param("actionType") String actionType,
            @Param("sqlText") String sqlText,
            @Param("detailJson") String detailJson
    );
}

package com.sqlcertification.demo.mapper;

import com.sqlcertification.demo.model.Employee;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface EmployeeMapper {

    List<Employee> selectEmployees(
            @Param("departmentName") String departmentName,
            @Param("activeOnly") Boolean activeOnly,
            @Param("limit") int limit,
            @Param("offset") int offset
    );

    long countEmployees(
            @Param("departmentName") String departmentName,
            @Param("activeOnly") Boolean activeOnly
    );
}

package com.sqlcertification.demo.service;

import com.sqlcertification.demo.mapper.EmployeeMapper;
import com.sqlcertification.demo.model.Employee;
import com.sqlcertification.demo.model.PageResult;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EmployeeService {

    private final EmployeeMapper employeeMapper;

    public EmployeeService(EmployeeMapper employeeMapper) {
        this.employeeMapper = employeeMapper;
    }

    public PageResult<Employee> getEmployees(
            String departmentName,
            Boolean activeOnly,
            int page,
            int pageSize
    ) {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.min(Math.max(pageSize, 1), 100);
        int offset = (safePage - 1) * safePageSize;

        List<Employee> items = employeeMapper.selectEmployees(
                departmentName, activeOnly, safePageSize, offset
        );
        long totalCount = employeeMapper.countEmployees(departmentName, activeOnly);

        return new PageResult<>(items, totalCount, safePage, safePageSize);
    }
}

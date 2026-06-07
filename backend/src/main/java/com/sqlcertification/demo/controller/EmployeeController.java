package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.Employee;
import com.sqlcertification.demo.model.PageResult;
import com.sqlcertification.demo.service.EmployeeService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/employees")
public class EmployeeController {

    private final EmployeeService employeeService;

    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    @GetMapping
    public PageResult<Employee> getEmployees(
            @RequestParam(required = false) String departmentName,
            @RequestParam(required = false) Boolean activeOnly,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize
    ) {
        return employeeService.getEmployees(departmentName, activeOnly, page, pageSize);
    }
}

package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.Customer;
import com.sqlcertification.demo.model.CustomerDetail;
import com.sqlcertification.demo.model.PageResult;
import com.sqlcertification.demo.service.CustomerService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {

    private final CustomerService customerService;

    public CustomerController(CustomerService customerService) {
        this.customerService = customerService;
    }

    @GetMapping
    public PageResult<Customer> getCustomers(
            @RequestParam(required = false) String prefecture,
            @RequestParam(required = false) String membershipTier,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize
    ) {
        return customerService.getCustomers(prefecture, membershipTier, keyword, page, pageSize);
    }

    @GetMapping("/{customerId}")
    public CustomerDetail getCustomer(@PathVariable int customerId) {
        return customerService.getCustomerById(customerId);
    }
}

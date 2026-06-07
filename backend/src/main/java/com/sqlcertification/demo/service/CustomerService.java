package com.sqlcertification.demo.service;

import com.sqlcertification.demo.exception.ResourceNotFoundException;
import com.sqlcertification.demo.mapper.CustomerMapper;
import com.sqlcertification.demo.model.Customer;
import com.sqlcertification.demo.model.CustomerDetail;
import com.sqlcertification.demo.model.PageResult;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerService {

    private final CustomerMapper customerMapper;

    public CustomerService(CustomerMapper customerMapper) {
        this.customerMapper = customerMapper;
    }

    public PageResult<Customer> getCustomers(
            String prefecture,
            String membershipTier,
            String keyword,
            int page,
            int pageSize
    ) {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.min(Math.max(pageSize, 1), 100);
        int offset = (safePage - 1) * safePageSize;

        List<Customer> items = customerMapper.selectCustomers(
                prefecture, membershipTier, keyword, safePageSize, offset
        );
        long totalCount = customerMapper.countCustomers(prefecture, membershipTier, keyword);

        return new PageResult<>(items, totalCount, safePage, safePageSize);
    }

    public CustomerDetail getCustomerById(int customerId) {
        CustomerDetail customer = customerMapper.selectCustomerById(customerId);
        if (customer == null) {
            throw new ResourceNotFoundException(
                    "CustomerService.getCustomerById",
                    "customerId",
                    customerId
            );
        }
        return customer;
    }
}

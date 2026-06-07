package com.sqlcertification.demo.mapper;

import com.sqlcertification.demo.model.Customer;
import com.sqlcertification.demo.model.CustomerDetail;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CustomerMapper {

    List<Customer> selectCustomers(
            @Param("prefecture") String prefecture,
            @Param("membershipTier") String membershipTier,
            @Param("keyword") String keyword,
            @Param("limit") int limit,
            @Param("offset") int offset
    );

    long countCustomers(
            @Param("prefecture") String prefecture,
            @Param("membershipTier") String membershipTier,
            @Param("keyword") String keyword
    );

    CustomerDetail selectCustomerById(@Param("customerId") int customerId);
}

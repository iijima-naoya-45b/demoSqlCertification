package com.sqlcertification.demo.mapper;

import com.sqlcertification.demo.model.OrderSummary;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface OrderMapper {

    List<OrderSummary> selectOrders(
            @Param("status") String status,
            @Param("customerId") Integer customerId,
            @Param("limit") int limit,
            @Param("offset") int offset
    );

    long countOrders(
            @Param("status") String status,
            @Param("customerId") Integer customerId
    );

    OrderSummary selectOrderById(@Param("orderId") int orderId);
}

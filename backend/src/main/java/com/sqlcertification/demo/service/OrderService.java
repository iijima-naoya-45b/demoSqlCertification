package com.sqlcertification.demo.service;

import com.sqlcertification.demo.exception.ResourceNotFoundException;
import com.sqlcertification.demo.mapper.OrderMapper;
import com.sqlcertification.demo.model.OrderSummary;
import com.sqlcertification.demo.model.PageResult;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class OrderService {

    private final OrderMapper orderMapper;

    public OrderService(OrderMapper orderMapper) {
        this.orderMapper = orderMapper;
    }

    public PageResult<OrderSummary> getOrders(
            String status,
            Integer customerId,
            int page,
            int pageSize
    ) {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.min(Math.max(pageSize, 1), 100);
        int offset = (safePage - 1) * safePageSize;

        List<OrderSummary> items = orderMapper.selectOrders(
                status, customerId, safePageSize, offset
        );
        long totalCount = orderMapper.countOrders(status, customerId);

        return new PageResult<>(items, totalCount, safePage, safePageSize);
    }

    public OrderSummary getOrderById(int orderId) {
        OrderSummary order = orderMapper.selectOrderById(orderId);
        if (order == null) {
            throw new ResourceNotFoundException(
                    "OrderService.getOrderById",
                    "orderId",
                    orderId
            );
        }
        return order;
    }
}

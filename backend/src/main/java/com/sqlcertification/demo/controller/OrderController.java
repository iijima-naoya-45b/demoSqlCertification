package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.OrderSummary;
import com.sqlcertification.demo.model.PageResult;
import com.sqlcertification.demo.service.OrderService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    public PageResult<OrderSummary> getOrders(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Integer customerId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize
    ) {
        return orderService.getOrders(status, customerId, page, pageSize);
    }

    @GetMapping("/{orderId}")
    public OrderSummary getOrder(@PathVariable int orderId) {
        return orderService.getOrderById(orderId);
    }
}

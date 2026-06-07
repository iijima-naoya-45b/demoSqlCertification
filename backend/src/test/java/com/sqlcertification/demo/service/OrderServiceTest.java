package com.sqlcertification.demo.service;

import com.sqlcertification.demo.exception.ResourceNotFoundException;
import com.sqlcertification.demo.mapper.OrderMapper;
import com.sqlcertification.demo.model.OrderSummary;
import com.sqlcertification.demo.model.PageResult;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderMapper orderMapper;

    @InjectMocks
    private OrderService orderService;

    @Test
    void getOrders_shouldReturnPagedOrders() {
        OrderSummary order = new OrderSummary();
        order.setOrderId(100);
        order.setCustomerName("佐藤 花子");
        order.setStatus("delivered");
        order.setOrderDate(LocalDateTime.of(2024, 6, 1, 10, 0));
        order.setTotalAmount(5000.0);

        when(orderMapper.selectOrders(eq("delivered"), isNull(), eq(10), eq(0)))
                .thenReturn(List.of(order));
        when(orderMapper.countOrders(eq("delivered"), isNull()))
                .thenReturn(1L);

        PageResult<OrderSummary> result = orderService.getOrders("delivered", null, 1, 10);

        assertThat(result.getItems()).hasSize(1);
        assertThat(result.getItems().get(0).getOrderId()).isEqualTo(100);
        assertThat(result.getTotalCount()).isEqualTo(1L);
    }

    @Test
    void getOrderById_shouldThrowWhenNotFound() {
        when(orderMapper.selectOrderById(404)).thenReturn(null);

        assertThatThrownBy(() -> orderService.getOrderById(404))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("orderId=404");
    }
}

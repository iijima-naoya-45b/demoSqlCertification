package com.sqlcertification.demo.service;

import com.sqlcertification.demo.exception.ResourceNotFoundException;
import com.sqlcertification.demo.mapper.CustomerMapper;
import com.sqlcertification.demo.model.Customer;
import com.sqlcertification.demo.model.CustomerDetail;
import com.sqlcertification.demo.model.PageResult;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CustomerServiceTest {

    @Mock
    private CustomerMapper customerMapper;

    @InjectMocks
    private CustomerService customerService;

    @Test
    void getCustomers_shouldNormalizePagingAndReturnPageResult() {
        Customer customer = buildCustomer(1);
        when(customerMapper.selectCustomers(isNull(), isNull(), isNull(), eq(20), eq(0)))
                .thenReturn(List.of(customer));
        when(customerMapper.countCustomers(isNull(), isNull(), isNull()))
                .thenReturn(1L);

        PageResult<Customer> result = customerService.getCustomers(null, null, null, 1, 20);

        assertThat(result.getItems()).hasSize(1);
        assertThat(result.getTotalCount()).isEqualTo(1L);
        assertThat(result.getPage()).isEqualTo(1);
        assertThat(result.getPageSize()).isEqualTo(20);
    }

    @Test
    void getCustomers_shouldClampPageSizeToMaximum() {
        when(customerMapper.selectCustomers(isNull(), isNull(), isNull(), eq(100), eq(0)))
                .thenReturn(List.of());
        when(customerMapper.countCustomers(isNull(), isNull(), isNull()))
                .thenReturn(0L);

        PageResult<Customer> result = customerService.getCustomers(null, null, null, 0, 500);

        assertThat(result.getPage()).isEqualTo(1);
        assertThat(result.getPageSize()).isEqualTo(100);
        verify(customerMapper).selectCustomers(isNull(), isNull(), isNull(), eq(100), eq(0));
    }

    @Test
    void getCustomerById_shouldReturnCustomerWhenFound() {
        CustomerDetail detail = buildCustomerDetail(10);
        when(customerMapper.selectCustomerById(10)).thenReturn(detail);

        CustomerDetail result = customerService.getCustomerById(10);

        assertThat(result.getCustomerId()).isEqualTo(10);
        assertThat(result.getOrderCount()).isEqualTo(3L);
    }

    @Test
    void getCustomerById_shouldThrowWhenNotFound() {
        when(customerMapper.selectCustomerById(999)).thenReturn(null);

        assertThatThrownBy(() -> customerService.getCustomerById(999))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("customerId=999");
    }

    private Customer buildCustomer(int customerId) {
        Customer customer = new Customer();
        customer.setCustomerId(customerId);
        customer.setCustomerName("山田 太郎");
        customer.setEmail("yamada@example.com");
        customer.setPrefecture("東京都");
        customer.setCity("渋谷区");
        customer.setRegisteredAt(LocalDate.of(2024, 1, 1));
        customer.setMembershipTier("gold");
        customer.setCreatedAt(LocalDateTime.of(2024, 1, 1, 0, 0));
        return customer;
    }

    private CustomerDetail buildCustomerDetail(int customerId) {
        CustomerDetail detail = new CustomerDetail();
        detail.setCustomerId(customerId);
        detail.setCustomerName("山田 太郎");
        detail.setEmail("yamada@example.com");
        detail.setOrderCount(3L);
        detail.setTotalPurchaseAmount(12000.0);
        detail.setAverageOrderAmount(4000.0);
        return detail;
    }
}

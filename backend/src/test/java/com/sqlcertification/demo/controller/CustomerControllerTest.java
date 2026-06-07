package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.exception.GlobalExceptionHandler;
import com.sqlcertification.demo.exception.ResourceNotFoundException;
import com.sqlcertification.demo.model.Customer;
import com.sqlcertification.demo.model.CustomerDetail;
import com.sqlcertification.demo.model.PageResult;
import com.sqlcertification.demo.service.CustomerService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(CustomerController.class)
@Import(GlobalExceptionHandler.class)
class CustomerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private CustomerService customerService;

    @Test
    void getCustomers_shouldReturnPagedJson() throws Exception {
        Customer customer = new Customer();
        customer.setCustomerId(1);
        customer.setCustomerName("山田 太郎");
        customer.setEmail("yamada@example.com");
        customer.setMembershipTier("gold");

        when(customerService.getCustomers(isNull(), isNull(), isNull(), eq(1), eq(20)))
                .thenReturn(new PageResult<>(List.of(customer), 1L, 1, 20));

        mockMvc.perform(get("/api/customers"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].customerId").value(1))
                .andExpect(jsonPath("$.items[0].customerName").value("山田 太郎"))
                .andExpect(jsonPath("$.totalCount").value(1));
    }

    @Test
    void getCustomer_shouldReturn404WhenNotFound() throws Exception {
        when(customerService.getCustomerById(anyInt()))
                .thenThrow(new ResourceNotFoundException("CustomerService.getCustomerById", "customerId", 999));

        mockMvc.perform(get("/api/customers/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("customerId=999")));
    }

    @Test
    void getCustomer_shouldReturnCustomerDetail() throws Exception {
        CustomerDetail detail = new CustomerDetail();
        detail.setCustomerId(5);
        detail.setCustomerName("鈴木 一郎");
        detail.setOrderCount(2L);

        when(customerService.getCustomerById(5)).thenReturn(detail);

        mockMvc.perform(get("/api/customers/5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.customerId").value(5))
                .andExpect(jsonPath("$.orderCount").value(2));
    }
}

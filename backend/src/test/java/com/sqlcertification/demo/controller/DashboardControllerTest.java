package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.DashboardStats;
import com.sqlcertification.demo.model.MembershipTierStat;
import com.sqlcertification.demo.service.DashboardService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Map;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(DashboardController.class)
class DashboardControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private DashboardService dashboardService;

    @Test
    void getStats_shouldReturnDashboardData() throws Exception {
        DashboardStats stats = new DashboardStats();
        stats.setCustomerCount(10000L);
        stats.setOrderCount(50000L);
        stats.setProductCount(2000L);
        stats.setTotalRevenue(1500000.0);

        MembershipTierStat tierStat = new MembershipTierStat();
        tierStat.setMembershipTier("gold");
        tierStat.setCustomerCount(2500L);

        when(dashboardService.getDashboardData()).thenReturn(Map.of(
                "stats", stats,
                "membershipTierStats", List.of(tierStat)
        ));

        mockMvc.perform(get("/api/dashboard/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stats.customerCount").value(10000))
                .andExpect(jsonPath("$.stats.orderCount").value(50000))
                .andExpect(jsonPath("$.membershipTierStats[0].membershipTier").value("gold"));
    }
}

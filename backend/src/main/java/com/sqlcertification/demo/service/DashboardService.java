package com.sqlcertification.demo.service;

import com.sqlcertification.demo.mapper.DashboardMapper;
import com.sqlcertification.demo.model.DashboardStats;
import com.sqlcertification.demo.model.MembershipTierStat;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DashboardService {

    private final DashboardMapper dashboardMapper;

    public DashboardService(DashboardMapper dashboardMapper) {
        this.dashboardMapper = dashboardMapper;
    }

    public Map<String, Object> getDashboardData() {
        DashboardStats stats = dashboardMapper.selectStats();
        List<MembershipTierStat> tierStats = dashboardMapper.selectMembershipTierStats();

        Map<String, Object> result = new HashMap<>();
        result.put("stats", stats);
        result.put("membershipTierStats", tierStats);
        return result;
    }
}

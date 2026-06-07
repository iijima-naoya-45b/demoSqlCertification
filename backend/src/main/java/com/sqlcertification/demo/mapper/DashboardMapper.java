package com.sqlcertification.demo.mapper;

import com.sqlcertification.demo.model.DashboardStats;
import com.sqlcertification.demo.model.MembershipTierStat;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface DashboardMapper {

    DashboardStats selectStats();

    List<MembershipTierStat> selectMembershipTierStats();
}

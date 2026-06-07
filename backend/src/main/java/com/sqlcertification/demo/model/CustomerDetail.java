package com.sqlcertification.demo.model;

public class CustomerDetail extends Customer {

    private long orderCount;
    private double totalPurchaseAmount;
    private double averageOrderAmount;

    public long getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(long orderCount) {
        this.orderCount = orderCount;
    }

    public double getTotalPurchaseAmount() {
        return totalPurchaseAmount;
    }

    public void setTotalPurchaseAmount(double totalPurchaseAmount) {
        this.totalPurchaseAmount = totalPurchaseAmount;
    }

    public double getAverageOrderAmount() {
        return averageOrderAmount;
    }

    public void setAverageOrderAmount(double averageOrderAmount) {
        this.averageOrderAmount = averageOrderAmount;
    }
}

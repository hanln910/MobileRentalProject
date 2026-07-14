package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity class representing an Overdue Rental Penalty.
 * $10/day late fee for overdue rentals.
 */
public class OverduePenalty implements Serializable {

    private int penaltyId;
    private int orderId;
    private int userId;
    private int overdueDays;
    private double dailyRate;
    private double totalPenalty;
    private String status; // Pending, Paid, Waived
    private Date issuedAt;
    private Date paidAt;
    private Date createdAt;
    private Date updatedAt;

    // Transient fields for display
    private String customerName;
    private String customerEmail;
    private String motorbikeName;

    public OverduePenalty() {
    }

    public int getPenaltyId() {
        return penaltyId;
    }

    public void setPenaltyId(int penaltyId) {
        this.penaltyId = penaltyId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getOverdueDays() {
        return overdueDays;
    }

    public void setOverdueDays(int overdueDays) {
        this.overdueDays = overdueDays;
    }

    public double getDailyRate() {
        return dailyRate;
    }

    public void setDailyRate(double dailyRate) {
        this.dailyRate = dailyRate;
    }

    public double getTotalPenalty() {
        return totalPenalty;
    }

    public void setTotalPenalty(double totalPenalty) {
        this.totalPenalty = totalPenalty;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getIssuedAt() {
        return issuedAt;
    }

    public void setIssuedAt(Date issuedAt) {
        this.issuedAt = issuedAt;
    }

    public Date getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(Date paidAt) {
        this.paidAt = paidAt;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public String getMotorbikeName() {
        return motorbikeName;
    }

    public void setMotorbikeName(String motorbikeName) {
        this.motorbikeName = motorbikeName;
    }
}

package model;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * Entity class representing a Rental Order.
 * Status: Pending, Confirmed, Renting, Returned, Cancelled
 */
public class RentalOrder implements Serializable {

    private int orderId;
    private int userId;
    private Date orderDate;
    private double totalAmount;
    private String status;
    private String notes;
    private String rejectReason;
    private Date createdAt;
    private Date updatedAt;

    // Transient fields for display
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private List<RentalOrderDetail> orderDetails;

    public RentalOrder() {
    }

    public RentalOrder(int orderId, int userId, Date orderDate, double totalAmount, String status) {
        this.orderId = orderId;
        this.userId = userId;
        this.orderDate = orderDate;
        this.totalAmount = totalAmount;
        this.status = status;
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

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public List<RentalOrderDetail> getOrderDetails() {
        return orderDetails;
    }

    public void setOrderDetails(List<RentalOrderDetail> orderDetails) {
        this.orderDetails = orderDetails;
    }

    @Override
    public String toString() {
        return "RentalOrder{" + "orderId=" + orderId + ", userId=" + userId + ", status=" + status + '}';
    }
}

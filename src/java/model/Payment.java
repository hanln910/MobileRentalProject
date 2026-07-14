package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity class representing a Payment.
 * Payment methods: Cash, Credit Card, Bank Transfer
 * Status: Pending, Completed, Refunded
 */
public class Payment implements Serializable {

    private int paymentId;
    private int orderId;
    private double amount;
    private String paymentMethod;
    private Date paymentDate;
    private String status;

    public Payment() {
    }

    public Payment(int paymentId, int orderId, double amount, String paymentMethod, String status) {
        this.paymentId = paymentId;
        this.orderId = orderId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.status = status;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public Date getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Date paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Payment{" + "paymentId=" + paymentId + ", orderId=" + orderId + ", amount=" + amount + '}';
    }
}

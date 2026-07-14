package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity class representing a Rental Order Detail.
 * Each order can have one or more motorbike rental details.
 */
public class RentalOrderDetail implements Serializable {

    private int detailId;
    private int orderId;
    private int motorbikeId;
    private Date rentalDate;
    private Date returnDate;
    private int totalDays;
    private double pricePerDay;
    private double subTotal;

    // Transient fields for display
    private String motorbikeName;
    private String brandName;
    private String categoryName;
    private String motorbikeImage;

    public RentalOrderDetail() {
    }

    public RentalOrderDetail(int detailId, int orderId, int motorbikeId,
                             Date rentalDate, Date returnDate, int totalDays,
                             double pricePerDay, double subTotal) {
        this.detailId = detailId;
        this.orderId = orderId;
        this.motorbikeId = motorbikeId;
        this.rentalDate = rentalDate;
        this.returnDate = returnDate;
        this.totalDays = totalDays;
        this.pricePerDay = pricePerDay;
        this.subTotal = subTotal;
    }

    public int getDetailId() {
        return detailId;
    }

    public void setDetailId(int detailId) {
        this.detailId = detailId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getMotorbikeId() {
        return motorbikeId;
    }

    public void setMotorbikeId(int motorbikeId) {
        this.motorbikeId = motorbikeId;
    }

    public Date getRentalDate() {
        return rentalDate;
    }

    public void setRentalDate(Date rentalDate) {
        this.rentalDate = rentalDate;
    }

    public Date getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(Date returnDate) {
        this.returnDate = returnDate;
    }

    public int getTotalDays() {
        return totalDays;
    }

    public void setTotalDays(int totalDays) {
        this.totalDays = totalDays;
    }

    public double getPricePerDay() {
        return pricePerDay;
    }

    public void setPricePerDay(double pricePerDay) {
        this.pricePerDay = pricePerDay;
    }

    public double getSubTotal() {
        return subTotal;
    }

    public void setSubTotal(double subTotal) {
        this.subTotal = subTotal;
    }

    public String getMotorbikeName() {
        return motorbikeName;
    }

    public void setMotorbikeName(String motorbikeName) {
        this.motorbikeName = motorbikeName;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getMotorbikeImage() {
        return motorbikeImage;
    }

    public void setMotorbikeImage(String motorbikeImage) {
        this.motorbikeImage = motorbikeImage;
    }

    @Override
    public String toString() {
        return "RentalOrderDetail{" + "detailId=" + detailId + ", orderId=" + orderId + '}';
    }
}

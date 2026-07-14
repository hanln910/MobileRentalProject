package model;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * Entity class representing a Motorbike in the system.
 */
public class Motorbike implements Serializable {

    private int motorbikeId;
    private String name;
    private int brandId;
    private int categoryId;
    private int year;
    private double pricePerDay;
    private String description;
    private String status; // Available, Rented, Maintenance
    private String imageUrl;
    private Date createdAt;
    private Date updatedAt;

    // Transient fields for display
    private String brandName;
    private String categoryName;
    private double avgRating;
    private int reviewCount;
    private List<MotorbikeImage> images;

    public Motorbike() {
    }

    public Motorbike(int motorbikeId, String name, int brandId, int categoryId,
                     int year, double pricePerDay, String description, String status, String imageUrl) {
        this.motorbikeId = motorbikeId;
        this.name = name;
        this.brandId = brandId;
        this.categoryId = categoryId;
        this.year = year;
        this.pricePerDay = pricePerDay;
        this.description = description;
        this.status = status;
        this.imageUrl = imageUrl;
    }

    public int getMotorbikeId() {
        return motorbikeId;
    }

    public void setMotorbikeId(int motorbikeId) {
        this.motorbikeId = motorbikeId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public double getPricePerDay() {
        return pricePerDay;
    }

    public void setPricePerDay(double pricePerDay) {
        this.pricePerDay = pricePerDay;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
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

    public double getAvgRating() {
        return avgRating;
    }

    public void setAvgRating(double avgRating) {
        this.avgRating = avgRating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public List<MotorbikeImage> getImages() {
        return images;
    }

    public void setImages(List<MotorbikeImage> images) {
        this.images = images;
    }

    @Override
    public String toString() {
        return "Motorbike{" + "motorbikeId=" + motorbikeId + ", name=" + name + '}';
    }
}

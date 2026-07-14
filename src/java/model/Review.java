package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity class representing a Review.
 * Customers can review motorbikes after completing a rental.
 */
public class Review implements Serializable {

    private int reviewId;
    private int userId;
    private int motorbikeId;
    private int orderId;
    private int rating;
    private String comment;
    private Date createdAt;

    // Transient fields for display
    private String userName;
    private String userAvatar;
    private String motorbikeName;

    public Review() {
    }

    public Review(int reviewId, int userId, int motorbikeId, int orderId, int rating, String comment) {
        this.reviewId = reviewId;
        this.userId = userId;
        this.motorbikeId = motorbikeId;
        this.orderId = orderId;
        this.rating = rating;
        this.comment = comment;
    }

    public int getReviewId() {
        return reviewId;
    }

    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getMotorbikeId() {
        return motorbikeId;
    }

    public void setMotorbikeId(int motorbikeId) {
        this.motorbikeId = motorbikeId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserAvatar() {
        return userAvatar;
    }

    public void setUserAvatar(String userAvatar) {
        this.userAvatar = userAvatar;
    }

    public String getMotorbikeName() {
        return motorbikeName;
    }

    public void setMotorbikeName(String motorbikeName) {
        this.motorbikeName = motorbikeName;
    }

    @Override
    public String toString() {
        return "Review{" + "reviewId=" + reviewId + ", rating=" + rating + '}';
    }
}

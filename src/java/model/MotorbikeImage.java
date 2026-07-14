package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity class representing a Motorbike Image.
 * Each motorbike can have multiple images.
 */
public class MotorbikeImage implements Serializable {

    private int imageId;
    private int motorbikeId;
    private String imageUrl;
    private boolean isPrimary;
    private Date createdAt;

    public MotorbikeImage() {
    }

    public MotorbikeImage(int imageId, int motorbikeId, String imageUrl, boolean isPrimary) {
        this.imageId = imageId;
        this.motorbikeId = motorbikeId;
        this.imageUrl = imageUrl;
        this.isPrimary = isPrimary;
    }

    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public int getMotorbikeId() {
        return motorbikeId;
    }

    public void setMotorbikeId(int motorbikeId) {
        this.motorbikeId = motorbikeId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isIsPrimary() {
        return isPrimary;
    }

    public void setIsPrimary(boolean isPrimary) {
        this.isPrimary = isPrimary;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "MotorbikeImage{" + "imageId=" + imageId + ", motorbikeId=" + motorbikeId + '}';
    }
}

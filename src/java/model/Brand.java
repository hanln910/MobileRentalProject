package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity class representing a Motorbike Brand.
 * Examples: Honda, Yamaha, Kawasaki, Ducati, Harley Davidson, Vespa
 */
public class Brand implements Serializable {

    private int brandId;
    private String brandName;
    private String logo;
    private Date createdAt;

    public Brand() {
    }

    public Brand(int brandId, String brandName) {
        this.brandId = brandId;
        this.brandName = brandName;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getLogo() {
        return logo;
    }

    public void setLogo(String logo) {
        this.logo = logo;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Brand{" + "brandId=" + brandId + ", brandName=" + brandName + '}';
    }
}

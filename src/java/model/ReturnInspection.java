package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity class representing a Return Inspection.
 * Customer submits photo/video evidence when returning a bike.
 * Staff reviews and approves or issues a damage fine.
 */
public class ReturnInspection implements Serializable {

    private int inspectionId;
    private int orderId;
    // Customer-submitted evidence
    private String photoUrl1;
    private String photoUrl2;
    private String photoUrl3;
    private String videoUrl;
    private String customerNotes;
    private Date submittedAt;
    // Staff review
    private Integer staffId;
    private String staffNotes;
    private String condition; // Pending, Good, Damaged
    // Fine details
    private double fineAmount;
    private String fineReason;
    private String fineStatus; // None, Pending, Paid, Overdue
    private Date fineIssuedAt;
    private Date fineDeadline;
    private Date finePaidAt;
    // Metadata
    private Date reviewedAt;
    private Date createdAt;
    private Date updatedAt;

    // Transient fields for display
    private String staffName;
    private String customerName;
    private String customerEmail;

    public ReturnInspection() {
    }

    public int getInspectionId() {
        return inspectionId;
    }

    public void setInspectionId(int inspectionId) {
        this.inspectionId = inspectionId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getPhotoUrl1() {
        return photoUrl1;
    }

    public void setPhotoUrl1(String photoUrl1) {
        this.photoUrl1 = photoUrl1;
    }

    public String getPhotoUrl2() {
        return photoUrl2;
    }

    public void setPhotoUrl2(String photoUrl2) {
        this.photoUrl2 = photoUrl2;
    }

    public String getPhotoUrl3() {
        return photoUrl3;
    }

    public void setPhotoUrl3(String photoUrl3) {
        this.photoUrl3 = photoUrl3;
    }

    public String getVideoUrl() {
        return videoUrl;
    }

    public void setVideoUrl(String videoUrl) {
        this.videoUrl = videoUrl;
    }

    public String getCustomerNotes() {
        return customerNotes;
    }

    public void setCustomerNotes(String customerNotes) {
        this.customerNotes = customerNotes;
    }

    public Date getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Date submittedAt) {
        this.submittedAt = submittedAt;
    }

    public Integer getStaffId() {
        return staffId;
    }

    public void setStaffId(Integer staffId) {
        this.staffId = staffId;
    }

    public String getStaffNotes() {
        return staffNotes;
    }

    public void setStaffNotes(String staffNotes) {
        this.staffNotes = staffNotes;
    }

    public String getCondition() {
        return condition;
    }

    public void setCondition(String condition) {
        this.condition = condition;
    }

    public double getFineAmount() {
        return fineAmount;
    }

    public void setFineAmount(double fineAmount) {
        this.fineAmount = fineAmount;
    }

    public String getFineReason() {
        return fineReason;
    }

    public void setFineReason(String fineReason) {
        this.fineReason = fineReason;
    }

    public String getFineStatus() {
        return fineStatus;
    }

    public void setFineStatus(String fineStatus) {
        this.fineStatus = fineStatus;
    }

    public Date getFineIssuedAt() {
        return fineIssuedAt;
    }

    public void setFineIssuedAt(Date fineIssuedAt) {
        this.fineIssuedAt = fineIssuedAt;
    }

    public Date getFineDeadline() {
        return fineDeadline;
    }

    public void setFineDeadline(Date fineDeadline) {
        this.fineDeadline = fineDeadline;
    }

    public Date getFinePaidAt() {
        return finePaidAt;
    }

    public void setFinePaidAt(Date finePaidAt) {
        this.finePaidAt = finePaidAt;
    }

    public Date getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(Date reviewedAt) {
        this.reviewedAt = reviewedAt;
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

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
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
}

package model;

import java.io.Serializable;
import java.util.Date;

/**
 * Entity class representing a Digital Rental Contract.
 * Status: Draft, Signed, Completed, Voided
 */
public class RentalContract implements Serializable {

    private int contractId;
    private int orderId;
    private String customerIdCard;
    private String customerIdCardImage;
    private Date customerDOB;
    private String emergencyName;
    private String emergencyPhone;
    private String emergencyRelation;
    private double depositAmount;
    private String terms;
    private boolean customerSigned;
    private Date customerSignedAt;
    private boolean staffSigned;
    private Date staffSignedAt;
    private Integer staffId;
    private String status;
    private Date createdAt;
    private Date updatedAt;

    // Transient fields for display
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String staffName;

    public RentalContract() {
    }

    public int getContractId() {
        return contractId;
    }

    public void setContractId(int contractId) {
        this.contractId = contractId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getCustomerIdCard() {
        return customerIdCard;
    }

    public void setCustomerIdCard(String customerIdCard) {
        this.customerIdCard = customerIdCard;
    }

    public Date getCustomerDOB() {
        return customerDOB;
    }

    public void setCustomerDOB(Date customerDOB) {
        this.customerDOB = customerDOB;
    }

    public String getEmergencyName() {
        return emergencyName;
    }

    public void setEmergencyName(String emergencyName) {
        this.emergencyName = emergencyName;
    }

    public String getEmergencyPhone() {
        return emergencyPhone;
    }

    public void setEmergencyPhone(String emergencyPhone) {
        this.emergencyPhone = emergencyPhone;
    }

    public String getEmergencyRelation() {
        return emergencyRelation;
    }

    public void setEmergencyRelation(String emergencyRelation) {
        this.emergencyRelation = emergencyRelation;
    }

    public double getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(double depositAmount) {
        this.depositAmount = depositAmount;
    }

    public String getTerms() {
        return terms;
    }

    public void setTerms(String terms) {
        this.terms = terms;
    }

    public boolean isCustomerSigned() {
        return customerSigned;
    }

    public void setCustomerSigned(boolean customerSigned) {
        this.customerSigned = customerSigned;
    }

    public Date getCustomerSignedAt() {
        return customerSignedAt;
    }

    public void setCustomerSignedAt(Date customerSignedAt) {
        this.customerSignedAt = customerSignedAt;
    }

    public boolean isStaffSigned() {
        return staffSigned;
    }

    public void setStaffSigned(boolean staffSigned) {
        this.staffSigned = staffSigned;
    }

    public Date getStaffSignedAt() {
        return staffSignedAt;
    }

    public void setStaffSignedAt(Date staffSignedAt) {
        this.staffSignedAt = staffSignedAt;
    }

    public Integer getStaffId() {
        return staffId;
    }

    public void setStaffId(Integer staffId) {
        this.staffId = staffId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getCustomerIdCardImage() {
        return customerIdCardImage;
    }

    public void setCustomerIdCardImage(String customerIdCardImage) {
        this.customerIdCardImage = customerIdCardImage;
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

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }
}

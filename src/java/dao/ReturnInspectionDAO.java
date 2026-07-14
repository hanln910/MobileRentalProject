package dao;

import dal.DbContext;
import model.ReturnInspection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for ReturnInspection operations.
 * Handles bike return evidence submission, staff review, and fine management.
 */
public class ReturnInspectionDAO {

    private static final Logger LOGGER = Logger.getLogger(ReturnInspectionDAO.class.getName());

    /**
     * Customer submits return evidence (photos, video, notes).
     */
    public boolean submitInspection(ReturnInspection insp) {
        String sql = "INSERT INTO ReturnInspections (orderId, photoUrl1, photoUrl2, photoUrl3, videoUrl, customerNotes) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, insp.getOrderId());
            ps.setString(2, insp.getPhotoUrl1());
            ps.setString(3, insp.getPhotoUrl2());
            ps.setString(4, insp.getPhotoUrl3());
            ps.setString(5, insp.getVideoUrl());
            ps.setString(6, insp.getCustomerNotes());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error submitting inspection", ex);
        }
        return false;
    }

    /**
     * Get inspection by order ID.
     */
    public ReturnInspection getByOrderId(int orderId) {
        String sql = "SELECT ri.*, u.fullName AS staffName, "
                + "cu.fullName AS customerName, cu.email AS customerEmail "
                + "FROM ReturnInspections ri "
                + "LEFT JOIN Users u ON ri.staffId = u.userId "
                + "JOIN RentalOrders ro ON ri.orderId = ro.orderId "
                + "JOIN Users cu ON ro.userId = cu.userId "
                + "WHERE ri.orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting inspection by orderId", ex);
        }
        return null;
    }

    /**
     * Get inspection by ID.
     */
    public ReturnInspection getById(int inspectionId) {
        String sql = "SELECT ri.*, u.fullName AS staffName, "
                + "cu.fullName AS customerName, cu.email AS customerEmail "
                + "FROM ReturnInspections ri "
                + "LEFT JOIN Users u ON ri.staffId = u.userId "
                + "JOIN RentalOrders ro ON ri.orderId = ro.orderId "
                + "JOIN Users cu ON ro.userId = cu.userId "
                + "WHERE ri.inspectionId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, inspectionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting inspection by id", ex);
        }
        return null;
    }

    /**
     * Staff approves return - condition is Good, no fine.
     */
    public boolean approveReturn(int orderId, int staffId, String staffNotes) {
        String sql = "UPDATE ReturnInspections SET staffId = ?, staffNotes = ?, condition = 'Good', "
                + "fineStatus = 'None', reviewedAt = GETDATE(), updatedAt = GETDATE() "
                + "WHERE orderId = ? AND condition = 'Pending'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setString(2, staffNotes);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error approving return", ex);
        }
        return false;
    }

    /**
     * Staff issues a damage fine. Deadline = 48 hours from now.
     */
    public boolean issueFine(int orderId, int staffId, String staffNotes, double fineAmount, String fineReason) {
        String sql = "UPDATE ReturnInspections SET staffId = ?, staffNotes = ?, condition = 'Damaged', "
                + "fineAmount = ?, fineReason = ?, fineStatus = 'Pending', "
                + "fineIssuedAt = GETDATE(), fineDeadline = DATEADD(HOUR, 48, GETDATE()), "
                + "reviewedAt = GETDATE(), updatedAt = GETDATE() "
                + "WHERE orderId = ? AND condition = 'Pending'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setString(2, staffNotes);
            ps.setDouble(3, fineAmount);
            ps.setString(4, fineReason);
            ps.setInt(5, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error issuing fine", ex);
        }
        return false;
    }

    /**
     * Customer pays the fine from wallet.
     */
    public boolean markFinePaid(int orderId) {
        String sql = "UPDATE ReturnInspections SET fineStatus = 'Paid', finePaidAt = GETDATE(), updatedAt = GETDATE() "
                + "WHERE orderId = ? AND fineStatus IN ('Pending', 'Overdue')";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error marking fine paid", ex);
        }
        return false;
    }

    /**
     * Get all pending inspections (for staff review).
     */
    public List<ReturnInspection> getPendingInspections() {
        List<ReturnInspection> list = new ArrayList<>();
        String sql = "SELECT ri.*, u.fullName AS staffName, "
                + "cu.fullName AS customerName, cu.email AS customerEmail "
                + "FROM ReturnInspections ri "
                + "LEFT JOIN Users u ON ri.staffId = u.userId "
                + "JOIN RentalOrders ro ON ri.orderId = ro.orderId "
                + "JOIN Users cu ON ro.userId = cu.userId "
                + "WHERE ri.condition = 'Pending' "
                + "ORDER BY ri.submittedAt ASC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting pending inspections", ex);
        }
        return list;
    }

    /**
     * Get all overdue fines (past deadline, not paid).
     * Used to lock accounts.
     */
    public List<ReturnInspection> getOverdueFines() {
        List<ReturnInspection> list = new ArrayList<>();
        String sql = "SELECT ri.*, u.fullName AS staffName, "
                + "cu.fullName AS customerName, cu.email AS customerEmail "
                + "FROM ReturnInspections ri "
                + "LEFT JOIN Users u ON ri.staffId = u.userId "
                + "JOIN RentalOrders ro ON ri.orderId = ro.orderId "
                + "JOIN Users cu ON ro.userId = cu.userId "
                + "WHERE ri.fineStatus = 'Pending' AND ri.fineDeadline < GETDATE() "
                + "ORDER BY ri.fineDeadline ASC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting overdue fines", ex);
        }
        return list;
    }

    /**
     * Mark overdue fines and lock the associated user accounts.
     */
    public int enforceOverdueFines() {
        String sql = "UPDATE ReturnInspections SET fineStatus = 'Overdue', updatedAt = GETDATE() "
                + "WHERE fineStatus = 'Pending' AND fineDeadline < GETDATE()";
        String lockSql = "UPDATE Users SET isActive = 0 WHERE userId IN ("
                + "SELECT ro.userId FROM ReturnInspections ri "
                + "JOIN RentalOrders ro ON ri.orderId = ro.orderId "
                + "WHERE ri.fineStatus = 'Overdue')";
        try (Connection conn = DbContext.getConnection()) {
            conn.setAutoCommit(false);
            int updated = 0;
            try (PreparedStatement ps1 = conn.prepareStatement(sql)) {
                updated = ps1.executeUpdate();
            }
            if (updated > 0) {
                try (PreparedStatement ps2 = conn.prepareStatement(lockSql)) {
                    ps2.executeUpdate();
                }
            }
            conn.commit();
            return updated;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error enforcing overdue fines", ex);
        }
        return 0;
    }

    /**
     * Staff waives a fine (e.g. after admin approves complaint).
     * Sets fineStatus to 'Waived'.
     */
    public boolean waiveFine(int orderId) {
        String sql = "UPDATE ReturnInspections SET fineStatus = 'Waived', updatedAt = GETDATE() "
                + "WHERE orderId = ? AND fineStatus IN ('Pending', 'Overdue')";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error waiving fine", ex);
        }
        return false;
    }

    /**
     * Check if a user has any overdue (unpaid) fines.
     */
    public boolean hasOverdueFines(int userId) {
        String sql = "SELECT COUNT(*) FROM ReturnInspections ri "
                + "JOIN RentalOrders ro ON ri.orderId = ro.orderId "
                + "WHERE ro.userId = ? AND ri.fineStatus = 'Overdue'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking overdue fines for user", ex);
        }
        return false;
    }

    /**
     * Check if an inspection already exists for an order.
     */
    public boolean existsForOrder(int orderId) {
        String sql = "SELECT COUNT(*) FROM ReturnInspections WHERE orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking inspection existence", ex);
        }
        return false;
    }

    private ReturnInspection mapResultSet(ResultSet rs) throws SQLException {
        ReturnInspection ri = new ReturnInspection();
        ri.setInspectionId(rs.getInt("inspectionId"));
        ri.setOrderId(rs.getInt("orderId"));
        ri.setPhotoUrl1(rs.getString("photoUrl1"));
        ri.setPhotoUrl2(rs.getString("photoUrl2"));
        ri.setPhotoUrl3(rs.getString("photoUrl3"));
        ri.setVideoUrl(rs.getString("videoUrl"));
        ri.setCustomerNotes(rs.getString("customerNotes"));
        ri.setSubmittedAt(rs.getTimestamp("submittedAt"));
        int sid = rs.getInt("staffId");
        ri.setStaffId(rs.wasNull() ? null : sid);
        ri.setStaffNotes(rs.getString("staffNotes"));
        ri.setCondition(rs.getString("condition"));
        ri.setFineAmount(rs.getDouble("fineAmount"));
        ri.setFineReason(rs.getString("fineReason"));
        ri.setFineStatus(rs.getString("fineStatus"));
        ri.setFineIssuedAt(rs.getTimestamp("fineIssuedAt"));
        ri.setFineDeadline(rs.getTimestamp("fineDeadline"));
        ri.setFinePaidAt(rs.getTimestamp("finePaidAt"));
        ri.setReviewedAt(rs.getTimestamp("reviewedAt"));
        ri.setCreatedAt(rs.getTimestamp("createdAt"));
        ri.setUpdatedAt(rs.getTimestamp("updatedAt"));
        try {
            ri.setStaffName(rs.getString("staffName"));
            ri.setCustomerName(rs.getString("customerName"));
            ri.setCustomerEmail(rs.getString("customerEmail"));
        } catch (SQLException e) { /* columns may not exist */ }
        return ri;
    }
}

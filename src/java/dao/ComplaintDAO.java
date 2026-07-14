package dao;

import dal.DbContext;
import model.Complaint;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Complaint operations.
 * Handles customer complaints about fines or service quality.
 */
public class ComplaintDAO {

    private static final Logger LOGGER = Logger.getLogger(ComplaintDAO.class.getName());

    /**
     * Customer files a new complaint.
     */
    public boolean createComplaint(Complaint c) {
        String sql = "INSERT INTO Complaints (orderId, userId, subject, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, c.getOrderId());
            ps.setInt(2, c.getUserId());
            ps.setString(3, c.getSubject());
            ps.setString(4, c.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating complaint", ex);
        }
        return false;
    }

    /**
     * Get complaints by user ID.
     */
    public List<Complaint> getComplaintsByUserId(int userId) {
        List<Complaint> list = new ArrayList<>();
        String sql = "SELECT c.*, u.fullName AS customerName, u.email AS customerEmail, "
                + "r.fullName AS resolvedByName "
                + "FROM Complaints c "
                + "JOIN Users u ON c.userId = u.userId "
                + "LEFT JOIN Users r ON c.resolvedBy = r.userId "
                + "WHERE c.userId = ? ORDER BY c.createdAt DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting complaints by user", ex);
        }
        return list;
    }

    /**
     * Get complaints by order ID.
     */
    public List<Complaint> getComplaintsByOrderId(int orderId) {
        List<Complaint> list = new ArrayList<>();
        String sql = "SELECT c.*, u.fullName AS customerName, u.email AS customerEmail, "
                + "r.fullName AS resolvedByName "
                + "FROM Complaints c "
                + "JOIN Users u ON c.userId = u.userId "
                + "LEFT JOIN Users r ON c.resolvedBy = r.userId "
                + "WHERE c.orderId = ? ORDER BY c.createdAt DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting complaints by order", ex);
        }
        return list;
    }

    /**
     * Get all complaints (for admin).
     */
    public List<Complaint> getAllComplaints() {
        List<Complaint> list = new ArrayList<>();
        String sql = "SELECT c.*, u.fullName AS customerName, u.email AS customerEmail, "
                + "r.fullName AS resolvedByName "
                + "FROM Complaints c "
                + "JOIN Users u ON c.userId = u.userId "
                + "LEFT JOIN Users r ON c.resolvedBy = r.userId "
                + "ORDER BY CASE c.status WHEN 'Open' THEN 1 WHEN 'InProgress' THEN 2 ELSE 3 END, c.createdAt DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all complaints", ex);
        }
        return list;
    }

    /**
     * Get a complaint by ID.
     */
    public Complaint getById(int complaintId) {
        String sql = "SELECT c.*, u.fullName AS customerName, u.email AS customerEmail, "
                + "r.fullName AS resolvedByName "
                + "FROM Complaints c "
                + "JOIN Users u ON c.userId = u.userId "
                + "LEFT JOIN Users r ON c.resolvedBy = r.userId "
                + "WHERE c.complaintId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, complaintId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting complaint by id", ex);
        }
        return null;
    }

    /**
     * Admin responds to a complaint (resolve or reject).
     */
    public boolean respondToComplaint(int complaintId, String status, String adminResponse, int resolvedBy) {
        String sql = "UPDATE Complaints SET status = ?, adminResponse = ?, resolvedBy = ?, "
                + "resolvedAt = GETDATE(), updatedAt = GETDATE() WHERE complaintId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, adminResponse);
            ps.setInt(3, resolvedBy);
            ps.setInt(4, complaintId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error responding to complaint", ex);
        }
        return false;
    }

    /**
     * Count open complaints.
     */
    public int countOpenComplaints() {
        String sql = "SELECT COUNT(*) FROM Complaints WHERE status = 'Open'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting open complaints", ex);
        }
        return 0;
    }

    private Complaint mapResultSet(ResultSet rs) throws SQLException {
        Complaint c = new Complaint();
        c.setComplaintId(rs.getInt("complaintId"));
        c.setOrderId(rs.getInt("orderId"));
        c.setUserId(rs.getInt("userId"));
        c.setSubject(rs.getString("subject"));
        c.setDescription(rs.getString("description"));
        c.setStatus(rs.getString("status"));
        c.setAdminResponse(rs.getString("adminResponse"));
        c.setResolvedAt(rs.getTimestamp("resolvedAt"));
        int rb = rs.getInt("resolvedBy");
        c.setResolvedBy(rs.wasNull() ? null : rb);
        c.setCreatedAt(rs.getTimestamp("createdAt"));
        c.setUpdatedAt(rs.getTimestamp("updatedAt"));
        try {
            c.setCustomerName(rs.getString("customerName"));
            c.setCustomerEmail(rs.getString("customerEmail"));
            c.setResolvedByName(rs.getString("resolvedByName"));
        } catch (SQLException e) { /* columns may not exist */ }
        return c;
    }
}

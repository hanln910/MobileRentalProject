package dao;

import dal.DbContext;
import model.OverduePenalty;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Overdue Penalty operations.
 * Handles overdue rental fees ($10/day late).
 */
public class OverduePenaltyDAO {

    private static final Logger LOGGER = Logger.getLogger(OverduePenaltyDAO.class.getName());

    /**
     * Get all overdue orders (Renting/Received where returnDate has passed).
     * Returns orders that don't yet have a penalty record or need updating.
     */
    public List<OverduePenalty> getOverdueOrders() {
        List<OverduePenalty> list = new ArrayList<>();
        String sql = "SELECT ro.orderId, ro.userId, u.fullName AS customerName, u.email AS customerEmail, "
                + "d.returnDate, m.name AS motorbikeName, "
                + "DATEDIFF(DAY, d.returnDate, GETDATE()) AS overdueDays, "
                + "op.penaltyId, op.status AS penaltyStatus, op.totalPenalty "
                + "FROM RentalOrders ro "
                + "JOIN RentalOrderDetails d ON ro.orderId = d.orderId "
                + "JOIN Motorbikes m ON d.motorbikeId = m.motorbikeId "
                + "JOIN Users u ON ro.userId = u.userId "
                + "LEFT JOIN OverduePenalties op ON ro.orderId = op.orderId "
                + "WHERE ro.status IN ('Renting', 'Received') "
                + "AND d.returnDate < GETDATE() "
                + "ORDER BY overdueDays DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                OverduePenalty p = new OverduePenalty();
                p.setOrderId(rs.getInt("orderId"));
                p.setUserId(rs.getInt("userId"));
                p.setCustomerName(rs.getString("customerName"));
                p.setCustomerEmail(rs.getString("customerEmail"));
                p.setMotorbikeName(rs.getString("motorbikeName"));
                p.setOverdueDays(rs.getInt("overdueDays"));
                p.setDailyRate(10.00);
                p.setTotalPenalty(p.getOverdueDays() * 10.00);
                int penaltyId = rs.getInt("penaltyId");
                if (!rs.wasNull()) {
                    p.setPenaltyId(penaltyId);
                    p.setStatus(rs.getString("penaltyStatus"));
                }
                list.add(p);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting overdue orders", ex);
        }
        return list;
    }

    /**
     * Issue or update an overdue penalty for an order.
     */
    public boolean issuePenalty(int orderId, int userId, int overdueDays) {
        double totalPenalty = overdueDays * 10.00;
        // Upsert: insert if not exists, update if exists
        String checkSql = "SELECT penaltyId FROM OverduePenalties WHERE orderId = ?";
        String insertSql = "INSERT INTO OverduePenalties (orderId, userId, overdueDays, dailyRate, totalPenalty, status) "
                + "VALUES (?, ?, ?, 10.00, ?, 'Pending')";
        String updateSql = "UPDATE OverduePenalties SET overdueDays = ?, totalPenalty = ?, updatedAt = GETDATE() "
                + "WHERE orderId = ? AND status = 'Pending'";
        try (Connection conn = DbContext.getConnection()) {
            // Check if penalty already exists
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, orderId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        // Update existing
                        try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                            updatePs.setInt(1, overdueDays);
                            updatePs.setDouble(2, totalPenalty);
                            updatePs.setInt(3, orderId);
                            return updatePs.executeUpdate() > 0;
                        }
                    } else {
                        // Insert new
                        try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                            insertPs.setInt(1, orderId);
                            insertPs.setInt(2, userId);
                            insertPs.setInt(3, overdueDays);
                            insertPs.setDouble(4, totalPenalty);
                            return insertPs.executeUpdate() > 0;
                        }
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error issuing overdue penalty", ex);
        }
        return false;
    }

    /**
     * Get penalty by order ID.
     */
    public OverduePenalty getByOrderId(int orderId) {
        String sql = "SELECT op.*, u.fullName AS customerName, u.email AS customerEmail "
                + "FROM OverduePenalties op "
                + "JOIN Users u ON op.userId = u.userId "
                + "WHERE op.orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting penalty by orderId", ex);
        }
        return null;
    }

    /**
     * Mark penalty as paid.
     */
    public boolean markPaid(int orderId) {
        String sql = "UPDATE OverduePenalties SET status = 'Paid', paidAt = GETDATE(), updatedAt = GETDATE() "
                + "WHERE orderId = ? AND status = 'Pending'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error marking penalty paid", ex);
        }
        return false;
    }

    /**
     * Waive a penalty.
     */
    public boolean waivePenalty(int orderId) {
        String sql = "UPDATE OverduePenalties SET status = 'Waived', updatedAt = GETDATE() "
                + "WHERE orderId = ? AND status = 'Pending'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error waiving penalty", ex);
        }
        return false;
    }

    /**
     * Check if user has any unpaid overdue penalties.
     */
    public boolean hasUnpaidPenalties(int userId) {
        String sql = "SELECT COUNT(*) FROM OverduePenalties WHERE userId = ? AND status = 'Pending'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking unpaid penalties", ex);
        }
        return false;
    }

    /**
     * Get all pending penalties for a user.
     */
    public List<OverduePenalty> getPendingByUserId(int userId) {
        List<OverduePenalty> list = new ArrayList<>();
        String sql = "SELECT op.*, u.fullName AS customerName, u.email AS customerEmail "
                + "FROM OverduePenalties op "
                + "JOIN Users u ON op.userId = u.userId "
                + "WHERE op.userId = ? AND op.status = 'Pending'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting pending penalties", ex);
        }
        return list;
    }

    private OverduePenalty mapResultSet(ResultSet rs) throws SQLException {
        OverduePenalty p = new OverduePenalty();
        p.setPenaltyId(rs.getInt("penaltyId"));
        p.setOrderId(rs.getInt("orderId"));
        p.setUserId(rs.getInt("userId"));
        p.setOverdueDays(rs.getInt("overdueDays"));
        p.setDailyRate(rs.getDouble("dailyRate"));
        p.setTotalPenalty(rs.getDouble("totalPenalty"));
        p.setStatus(rs.getString("status"));
        p.setIssuedAt(rs.getTimestamp("issuedAt"));
        p.setPaidAt(rs.getTimestamp("paidAt"));
        p.setCreatedAt(rs.getTimestamp("createdAt"));
        p.setUpdatedAt(rs.getTimestamp("updatedAt"));
        try {
            p.setCustomerName(rs.getString("customerName"));
            p.setCustomerEmail(rs.getString("customerEmail"));
        } catch (SQLException e) { /* columns may not exist */ }
        return p;
    }
}

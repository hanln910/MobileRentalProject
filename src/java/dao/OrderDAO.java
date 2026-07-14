package dao;

import dal.DbContext;
import model.RentalOrder;
import model.RentalOrderDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Rental Order operations.
 * Handles CRUD operations for RentalOrders and RentalOrderDetails tables.
 */
public class OrderDAO {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

    /**
     * Create a new rental order with details.
     * Uses transaction to ensure data consistency.
     */
    public int createOrder(RentalOrder order, RentalOrderDetail detail) {
        Connection conn = null;
        try {
            conn = DbContext.getConnection();
            conn.setAutoCommit(false);

            // Insert order
            String sqlOrder = "INSERT INTO RentalOrders (userId, totalAmount, status) VALUES (?, ?, 'Pending')";
            int orderId;
            try (PreparedStatement ps = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, order.getUserId());
                ps.setDouble(2, order.getTotalAmount());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        orderId = rs.getInt(1);
                    } else {
                        conn.rollback();
                        return -1;
                    }
                }
            }

            // Insert order detail
            String sqlDetail = "INSERT INTO RentalOrderDetails (orderId, motorbikeId, rentalDate, returnDate, totalDays, pricePerDay, subTotal) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlDetail)) {
                ps.setInt(1, orderId);
                ps.setInt(2, detail.getMotorbikeId());
                ps.setDate(3, new java.sql.Date(detail.getRentalDate().getTime()));
                ps.setDate(4, new java.sql.Date(detail.getReturnDate().getTime()));
                ps.setInt(5, detail.getTotalDays());
                ps.setDouble(6, detail.getPricePerDay());
                ps.setDouble(7, detail.getSubTotal());
                ps.executeUpdate();
            }

            conn.commit();
            return orderId;

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating order", ex);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Error rolling back", e);
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Error closing connection", e);
                }
            }
        }
        return -1;
    }

    /**
     * Get all orders for a specific customer.
     */
    public List<RentalOrder> getOrdersByUserId(int userId) {
        List<RentalOrder> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.fullName AS customerName, u.email AS customerEmail, u.phone AS customerPhone "
                + "FROM RentalOrders o "
                + "JOIN Users u ON o.userId = u.userId "
                + "WHERE o.userId = ? "
                + "ORDER BY o.orderDate DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RentalOrder order = mapResultSetToOrder(rs);
                    order.setOrderDetails(getOrderDetails(order.getOrderId()));
                    orders.add(order);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting orders by user", ex);
        }
        return orders;
    }

    /**
     * Get all orders (for Staff and Admin).
     */
    public List<RentalOrder> getAllOrders() {
        List<RentalOrder> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.fullName AS customerName, u.email AS customerEmail, u.phone AS customerPhone "
                + "FROM RentalOrders o "
                + "JOIN Users u ON o.userId = u.userId "
                + "ORDER BY o.orderDate DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RentalOrder order = mapResultSetToOrder(rs);
                order.setOrderDetails(getOrderDetails(order.getOrderId()));
                orders.add(order);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all orders", ex);
        }
        return orders;
    }

    /**
     * Get order by ID.
     */
    public RentalOrder getOrderById(int orderId) {
        String sql = "SELECT o.*, u.fullName AS customerName, u.email AS customerEmail, u.phone AS customerPhone "
                + "FROM RentalOrders o "
                + "JOIN Users u ON o.userId = u.userId "
                + "WHERE o.orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RentalOrder order = mapResultSetToOrder(rs);
                    order.setOrderDetails(getOrderDetails(orderId));
                    return order;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting order by ID", ex);
        }
        return null;
    }

    /**
     * Get order details for an order.
     */
    public List<RentalOrderDetail> getOrderDetails(int orderId) {
        List<RentalOrderDetail> details = new ArrayList<>();
        String sql = "SELECT od.*, m.name AS motorbikeName, m.imageUrl AS motorbikeImage, "
                + "b.brandName, c.categoryName "
                + "FROM RentalOrderDetails od "
                + "JOIN Motorbikes m ON od.motorbikeId = m.motorbikeId "
                + "JOIN Brands b ON m.brandId = b.brandId "
                + "JOIN Categories c ON m.categoryId = c.categoryId "
                + "WHERE od.orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RentalOrderDetail detail = new RentalOrderDetail();
                    detail.setDetailId(rs.getInt("detailId"));
                    detail.setOrderId(rs.getInt("orderId"));
                    detail.setMotorbikeId(rs.getInt("motorbikeId"));
                    detail.setRentalDate(rs.getDate("rentalDate"));
                    detail.setReturnDate(rs.getDate("returnDate"));
                    detail.setTotalDays(rs.getInt("totalDays"));
                    detail.setPricePerDay(rs.getDouble("pricePerDay"));
                    detail.setSubTotal(rs.getDouble("subTotal"));
                    detail.setMotorbikeName(rs.getString("motorbikeName"));
                    detail.setMotorbikeImage(rs.getString("motorbikeImage"));
                    detail.setBrandName(rs.getString("brandName"));
                    detail.setCategoryName(rs.getString("categoryName"));
                    details.add(detail);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting order details", ex);
        }
        return details;
    }

    /**
     * Update order status.
     * Valid transitions: Pending -> Confirmed, Confirmed -> Renting, Renting -> Returned, Pending -> Cancelled
     */
    public boolean updateOrderStatus(int orderId, String newStatus) {
        String sql = "UPDATE RentalOrders SET status = ?, updatedAt = GETDATE() WHERE orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating order status", ex);
        }
        return false;
    }

    /**
     * Cancel an order (only if status is Pending).
     */
    public boolean cancelOrder(int orderId, int userId) {
        String sql = "UPDATE RentalOrders SET status = 'Cancelled', updatedAt = GETDATE() "
                + "WHERE orderId = ? AND userId = ? AND status = 'Pending'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error cancelling order", ex);
        }
        return false;
    }

    /**
     * Get total number of orders.
     */
    public int getTotalOrders() {
        String sql = "SELECT COUNT(*) FROM RentalOrders";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting orders", ex);
        }
        return 0;
    }

    /**
     * Get count of orders by status.
     */
    public int getOrderCountByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM RentalOrders WHERE status = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting orders by status", ex);
        }
        return 0;
    }

    /**
     * Get total revenue (Returned + Completed + Fined orders).
     */
    public double getTotalRevenue() {
        String sql = "SELECT ISNULL(SUM(totalAmount), 0) FROM RentalOrders WHERE status IN ('Returned', 'Completed', 'Fined')";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting total revenue", ex);
        }
        return 0;
    }

    /**
     * Get monthly revenue for current year (for charts).
     */
    public List<Double> getMonthlyRevenue() {
        List<Double> revenue = new ArrayList<>();
        for (int i = 0; i < 12; i++) {
            revenue.add(0.0);
        }
        String sql = "SELECT MONTH(orderDate) AS m, SUM(totalAmount) AS total "
                + "FROM RentalOrders "
                + "WHERE YEAR(orderDate) = YEAR(GETDATE()) AND status IN ('Returned', 'Completed', 'Fined') "
                + "GROUP BY MONTH(orderDate) ORDER BY m";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int month = rs.getInt("m");
                double total = rs.getDouble("total");
                revenue.set(month - 1, total);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting monthly revenue", ex);
        }
        return revenue;
    }

    /**
     * Get monthly order counts for current year (for charts).
     */
    public List<Integer> getMonthlyOrderCounts() {
        List<Integer> counts = new ArrayList<>();
        for (int i = 0; i < 12; i++) {
            counts.add(0);
        }
        String sql = "SELECT MONTH(orderDate) AS m, COUNT(*) AS cnt "
                + "FROM RentalOrders "
                + "WHERE YEAR(orderDate) = YEAR(GETDATE()) "
                + "GROUP BY MONTH(orderDate) ORDER BY m";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int month = rs.getInt("m");
                int cnt = rs.getInt("cnt");
                counts.set(month - 1, cnt);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting monthly order counts", ex);
        }
        return counts;
    }

    /**
     * Get active rental count for a customer (Pending, Confirmed, Renting, Received, Fined).
     * Used to enforce max 3 concurrent rentals.
     */
    public int getActiveRentalCount(int userId) {
        String sql = "SELECT COUNT(*) FROM RentalOrders WHERE userId = ? "
                + "AND status IN ('Pending', 'Confirmed', 'Renting', 'Received', 'Fined')";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting active rental count", ex);
        }
        return 0;
    }

    /**
     * Get customer order counts (total, active, completed).
     */
    public int getCustomerOrderCount(int userId, String status) {
        String sql;
        if (status == null || status.isEmpty()) {
            sql = "SELECT COUNT(*) FROM RentalOrders WHERE userId = ?";
        } else {
            sql = "SELECT COUNT(*) FROM RentalOrders WHERE userId = ? AND status = ?";
        }
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            if (status != null && !status.isEmpty()) {
                ps.setString(2, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting customer order count", ex);
        }
        return 0;
    }

    /**
     * Get all orders with pagination (newest first).
     */
    public List<RentalOrder> getAllOrdersPaged(int page, int pageSize) {
        List<RentalOrder> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.fullName AS customerName, u.email AS customerEmail, u.phone AS customerPhone "
                + "FROM RentalOrders o "
                + "JOIN Users u ON o.userId = u.userId "
                + "ORDER BY o.createdAt DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (page - 1) * pageSize);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RentalOrder order = mapResultSetToOrder(rs);
                    order.setOrderDetails(getOrderDetails(order.getOrderId()));
                    orders.add(order);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting paged orders", ex);
        }
        return orders;
    }

    /**
     * Get orders by status with pagination (newest first).
     */
    public List<RentalOrder> getOrdersByStatusPaged(String status, int page, int pageSize) {
        List<RentalOrder> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.fullName AS customerName, u.email AS customerEmail, u.phone AS customerPhone "
                + "FROM RentalOrders o "
                + "JOIN Users u ON o.userId = u.userId "
                + "WHERE o.status = ? "
                + "ORDER BY o.createdAt DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RentalOrder order = mapResultSetToOrder(rs);
                    order.setOrderDetails(getOrderDetails(order.getOrderId()));
                    orders.add(order);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting orders by status paged", ex);
        }
        return orders;
    }

    /**
     * Get orders by userId with pagination (newest first).
     */
    public List<RentalOrder> getOrdersByUserIdPaged(int userId, int page, int pageSize) {
        List<RentalOrder> orders = new ArrayList<>();
        String sql = "SELECT o.*, u.fullName AS customerName, u.email AS customerEmail, u.phone AS customerPhone "
                + "FROM RentalOrders o "
                + "JOIN Users u ON o.userId = u.userId "
                + "WHERE o.userId = ? "
                + "ORDER BY o.createdAt DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RentalOrder order = mapResultSetToOrder(rs);
                    order.setOrderDetails(getOrderDetails(order.getOrderId()));
                    orders.add(order);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting user orders paged", ex);
        }
        return orders;
    }

    /**
     * Reject an order (Pending -> Cancelled) with a reason + refund note.
     */
    public boolean rejectOrder(int orderId, String rejectReason) {
        String sql = "UPDATE RentalOrders SET status = 'Cancelled', rejectReason = ?, updatedAt = GETDATE() "
                + "WHERE orderId = ? AND status = 'Pending'";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rejectReason);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error rejecting order", ex);
        }
        return false;
    }

    /**
     * Map ResultSet to RentalOrder object.
     */
    private RentalOrder mapResultSetToOrder(ResultSet rs) throws SQLException {
        RentalOrder order = new RentalOrder();
        order.setOrderId(rs.getInt("orderId"));
        order.setUserId(rs.getInt("userId"));
        order.setOrderDate(rs.getTimestamp("orderDate"));
        order.setTotalAmount(rs.getDouble("totalAmount"));
        order.setStatus(rs.getString("status"));
        order.setNotes(rs.getString("notes"));
        try { order.setRejectReason(rs.getString("rejectReason")); } catch (SQLException e) { }
        order.setCreatedAt(rs.getTimestamp("createdAt"));
        order.setUpdatedAt(rs.getTimestamp("updatedAt"));
        try {
            order.setCustomerName(rs.getString("customerName"));
            order.setCustomerEmail(rs.getString("customerEmail"));
            order.setCustomerPhone(rs.getString("customerPhone"));
        } catch (SQLException e) {
            // These columns may not exist in all queries
        }
        return order;
    }
}

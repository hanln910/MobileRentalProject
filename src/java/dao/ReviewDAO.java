package dao;

import dal.DbContext;
import model.Review;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Review operations.
 * Handles CRUD operations for the Reviews table.
 */
public class ReviewDAO {

    private static final Logger LOGGER = Logger.getLogger(ReviewDAO.class.getName());

    /**
     * Get all reviews for a motorbike.
     */
    public List<Review> getReviewsByMotorbikeId(int motorbikeId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, u.fullName AS userName, u.avatar AS userAvatar "
                + "FROM Reviews r "
                + "JOIN Users u ON r.userId = u.userId "
                + "WHERE r.motorbikeId = ? "
                + "ORDER BY r.createdAt DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, motorbikeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToReview(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting reviews by motorbike", ex);
        }
        return list;
    }

    /**
     * Add a new review.
     */
    public boolean addReview(Review review) {
        String sql = "INSERT INTO Reviews (userId, motorbikeId, orderId, rating, comment) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, review.getUserId());
            ps.setInt(2, review.getMotorbikeId());
            ps.setInt(3, review.getOrderId());
            ps.setInt(4, review.getRating());
            ps.setString(5, review.getComment());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error adding review", ex);
        }
        return false;
    }

    /**
     * Check if a user has already reviewed an order.
     */
    public boolean hasReviewed(int userId, int orderId) {
        String sql = "SELECT COUNT(*) FROM Reviews WHERE userId = ? AND orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking review existence", ex);
        }
        return false;
    }

    /**
     * Get average rating for a motorbike.
     */
    public double getAverageRating(int motorbikeId) {
        String sql = "SELECT ISNULL(AVG(CAST(rating AS FLOAT)), 0) FROM Reviews WHERE motorbikeId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, motorbikeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting average rating", ex);
        }
        return 0;
    }

    /**
     * Get recent reviews for homepage.
     */
    public List<Review> getRecentReviews(int limit) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT TOP (?) r.*, u.fullName AS userName, u.avatar AS userAvatar, "
                + "m.name AS motorbikeName "
                + "FROM Reviews r "
                + "JOIN Users u ON r.userId = u.userId "
                + "JOIN Motorbikes m ON r.motorbikeId = m.motorbikeId "
                + "ORDER BY r.createdAt DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review review = mapResultSetToReview(rs);
                    try {
                        review.setMotorbikeName(rs.getString("motorbikeName"));
                    } catch (SQLException e) {
                        // Column may not exist
                    }
                    list.add(review);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting recent reviews", ex);
        }
        return list;
    }

    /**
     * Map ResultSet to Review object.
     */
    private Review mapResultSetToReview(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("reviewId"));
        r.setUserId(rs.getInt("userId"));
        r.setMotorbikeId(rs.getInt("motorbikeId"));
        r.setOrderId(rs.getInt("orderId"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setCreatedAt(rs.getTimestamp("createdAt"));
        try {
            r.setUserName(rs.getString("userName"));
            r.setUserAvatar(rs.getString("userAvatar"));
        } catch (SQLException e) {
            // These columns may not exist in all queries
        }
        return r;
    }
}

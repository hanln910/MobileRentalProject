package dao;

import dal.DbContext;
import model.Motorbike;
import model.MotorbikeImage;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Motorbike operations.
 * Handles CRUD operations for the Motorbikes table.
 */
public class MotorbikeDAO {

    private static final Logger LOGGER = Logger.getLogger(MotorbikeDAO.class.getName());

    /**
     * Get all motorbikes with brand and category info.
     */
    public List<Motorbike> getAllMotorbikes() {
        List<Motorbike> list = new ArrayList<>();
        String sql = "SELECT m.*, b.brandName, c.categoryName, "
                + "ISNULL((SELECT AVG(CAST(r.rating AS FLOAT)) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS avgRating, "
                + "ISNULL((SELECT COUNT(*) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS reviewCount "
                + "FROM Motorbikes m "
                + "JOIN Brands b ON m.brandId = b.brandId "
                + "JOIN Categories c ON m.categoryId = c.categoryId "
                + "ORDER BY m.createdAt DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToMotorbike(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all motorbikes", ex);
        }
        return list;
    }

    /**
     * Get motorbikes with pagination.
     * @param page current page number (1-based)
     * @param pageSize number of records per page
     */
    public List<Motorbike> getMotorbikesByPage(int page, int pageSize) {
        List<Motorbike> list = new ArrayList<>();
        String sql = "SELECT m.*, b.brandName, c.categoryName, "
                + "ISNULL((SELECT AVG(CAST(r.rating AS FLOAT)) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS avgRating, "
                + "ISNULL((SELECT COUNT(*) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS reviewCount "
                + "FROM Motorbikes m "
                + "JOIN Brands b ON m.brandId = b.brandId "
                + "JOIN Categories c ON m.categoryId = c.categoryId "
                + "ORDER BY m.createdAt DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (page - 1) * pageSize);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToMotorbike(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting motorbikes by page", ex);
        }
        return list;
    }

    /**
     * Search and filter motorbikes.
     * @param keyword search keyword for name
     * @param brandId filter by brand (0 = all)
     * @param categoryId filter by category (0 = all)
     * @param minPrice minimum price (0 = no min)
     * @param maxPrice maximum price (0 = no max)
     * @param sortBy sort option
     * @param page page number
     * @param pageSize page size
     */
    public List<Motorbike> searchMotorbikes(String keyword, int brandId, int categoryId,
                                            double minPrice, double maxPrice,
                                            String sortBy, int page, int pageSize) {
        List<Motorbike> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT m.*, b.brandName, c.categoryName, ");
        sql.append("ISNULL((SELECT AVG(CAST(r.rating AS FLOAT)) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS avgRating, ");
        sql.append("ISNULL((SELECT COUNT(*) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS reviewCount ");
        sql.append("FROM Motorbikes m ");
        sql.append("JOIN Brands b ON m.brandId = b.brandId ");
        sql.append("JOIN Categories c ON m.categoryId = c.categoryId ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (m.name LIKE ? OR b.brandName LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        if (brandId > 0) {
            sql.append("AND m.brandId = ? ");
            params.add(brandId);
        }
        if (categoryId > 0) {
            sql.append("AND m.categoryId = ? ");
            params.add(categoryId);
        }
        if (minPrice > 0) {
            sql.append("AND m.pricePerDay >= ? ");
            params.add(minPrice);
        }
        if (maxPrice > 0) {
            sql.append("AND m.pricePerDay <= ? ");
            params.add(maxPrice);
        }

        // Sort options
        if ("price_asc".equals(sortBy)) {
            sql.append("ORDER BY m.pricePerDay ASC ");
        } else if ("price_desc".equals(sortBy)) {
            sql.append("ORDER BY m.pricePerDay DESC ");
        } else if ("rating".equals(sortBy)) {
            sql.append("ORDER BY avgRating DESC ");
        } else {
            sql.append("ORDER BY m.createdAt DESC ");
        }

        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else if (param instanceof Double) {
                    ps.setDouble(i + 1, (Double) param);
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToMotorbike(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error searching motorbikes", ex);
        }
        return list;
    }

    /**
     * Count motorbikes matching search criteria (for pagination).
     */
    public int countMotorbikes(String keyword, int brandId, int categoryId,
                               double minPrice, double maxPrice) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM Motorbikes m ");
        sql.append("JOIN Brands b ON m.brandId = b.brandId ");
        sql.append("JOIN Categories c ON m.categoryId = c.categoryId ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (m.name LIKE ? OR b.brandName LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        if (brandId > 0) {
            sql.append("AND m.brandId = ? ");
            params.add(brandId);
        }
        if (categoryId > 0) {
            sql.append("AND m.categoryId = ? ");
            params.add(categoryId);
        }
        if (minPrice > 0) {
            sql.append("AND m.pricePerDay >= ? ");
            params.add(minPrice);
        }
        if (maxPrice > 0) {
            sql.append("AND m.pricePerDay <= ? ");
            params.add(maxPrice);
        }

        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    ps.setString(i + 1, (String) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else if (param instanceof Double) {
                    ps.setDouble(i + 1, (Double) param);
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting motorbikes", ex);
        }
        return 0;
    }

    /**
     * Get motorbike by ID with full details.
     */
    public Motorbike getMotorbikeById(int motorbikeId) {
        String sql = "SELECT m.*, b.brandName, c.categoryName, "
                + "ISNULL((SELECT AVG(CAST(r.rating AS FLOAT)) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS avgRating, "
                + "ISNULL((SELECT COUNT(*) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS reviewCount "
                + "FROM Motorbikes m "
                + "JOIN Brands b ON m.brandId = b.brandId "
                + "JOIN Categories c ON m.categoryId = c.categoryId "
                + "WHERE m.motorbikeId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, motorbikeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Motorbike m = mapResultSetToMotorbike(rs);
                    m.setImages(getMotorbikeImages(motorbikeId));
                    return m;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting motorbike by ID", ex);
        }
        return null;
    }

    /**
     * Get images for a motorbike.
     */
    public List<MotorbikeImage> getMotorbikeImages(int motorbikeId) {
        List<MotorbikeImage> images = new ArrayList<>();
        String sql = "SELECT * FROM MotorbikeImages WHERE motorbikeId = ? ORDER BY isPrimary DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, motorbikeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MotorbikeImage img = new MotorbikeImage();
                    img.setImageId(rs.getInt("imageId"));
                    img.setMotorbikeId(rs.getInt("motorbikeId"));
                    img.setImageUrl(rs.getString("imageUrl"));
                    img.setIsPrimary(rs.getBoolean("isPrimary"));
                    img.setCreatedAt(rs.getTimestamp("createdAt"));
                    images.add(img);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting motorbike images", ex);
        }
        return images;
    }

    /**
     * Get featured motorbikes for homepage (top rated, available).
     */
    public List<Motorbike> getFeaturedMotorbikes(int limit) {
        List<Motorbike> list = new ArrayList<>();
        String sql = "SELECT TOP (?) m.*, b.brandName, c.categoryName, "
                + "ISNULL((SELECT AVG(CAST(r.rating AS FLOAT)) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS avgRating, "
                + "ISNULL((SELECT COUNT(*) FROM Reviews r WHERE r.motorbikeId = m.motorbikeId), 0) AS reviewCount "
                + "FROM Motorbikes m "
                + "JOIN Brands b ON m.brandId = b.brandId "
                + "JOIN Categories c ON m.categoryId = c.categoryId "
                + "WHERE m.status = 'Available' "
                + "ORDER BY avgRating DESC, m.createdAt DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToMotorbike(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting featured motorbikes", ex);
        }
        return list;
    }

    /**
     * Add a new motorbike (Admin function).
     */
    public int addMotorbike(Motorbike motorbike) {
        String sql = "INSERT INTO Motorbikes (name, brandId, categoryId, year, pricePerDay, description, status, imageUrl) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, motorbike.getName());
            ps.setInt(2, motorbike.getBrandId());
            ps.setInt(3, motorbike.getCategoryId());
            ps.setInt(4, motorbike.getYear());
            ps.setDouble(5, motorbike.getPricePerDay());
            ps.setString(6, motorbike.getDescription());
            ps.setString(7, motorbike.getStatus());
            ps.setString(8, motorbike.getImageUrl());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error adding motorbike", ex);
        }
        return -1;
    }

    /**
     * Update a motorbike (Admin function).
     */
    public boolean updateMotorbike(Motorbike motorbike) {
        String sql = "UPDATE Motorbikes SET name = ?, brandId = ?, categoryId = ?, year = ?, "
                + "pricePerDay = ?, description = ?, status = ?, imageUrl = ?, updatedAt = GETDATE() "
                + "WHERE motorbikeId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, motorbike.getName());
            ps.setInt(2, motorbike.getBrandId());
            ps.setInt(3, motorbike.getCategoryId());
            ps.setInt(4, motorbike.getYear());
            ps.setDouble(5, motorbike.getPricePerDay());
            ps.setString(6, motorbike.getDescription());
            ps.setString(7, motorbike.getStatus());
            ps.setString(8, motorbike.getImageUrl());
            ps.setInt(9, motorbike.getMotorbikeId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating motorbike", ex);
        }
        return false;
    }

    /**
     * Delete a motorbike (Admin function).
     */
    public boolean deleteMotorbike(int motorbikeId) {
        String sql = "DELETE FROM Motorbikes WHERE motorbikeId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, motorbikeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting motorbike", ex);
        }
        return false;
    }

    /**
     * Update motorbike status.
     */
    public boolean updateMotorbikeStatus(int motorbikeId, String status) {
        String sql = "UPDATE Motorbikes SET status = ?, updatedAt = GETDATE() WHERE motorbikeId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, motorbikeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating motorbike status", ex);
        }
        return false;
    }

    /**
     * Get total number of motorbikes.
     */
    public int getTotalMotorbikes() {
        String sql = "SELECT COUNT(*) FROM Motorbikes";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting motorbikes", ex);
        }
        return 0;
    }

    /**
     * Map ResultSet to Motorbike object.
     */
    private Motorbike mapResultSetToMotorbike(ResultSet rs) throws SQLException {
        Motorbike m = new Motorbike();
        m.setMotorbikeId(rs.getInt("motorbikeId"));
        m.setName(rs.getString("name"));
        m.setBrandId(rs.getInt("brandId"));
        m.setCategoryId(rs.getInt("categoryId"));
        m.setYear(rs.getInt("year"));
        m.setPricePerDay(rs.getDouble("pricePerDay"));
        m.setDescription(rs.getString("description"));
        m.setStatus(rs.getString("status"));
        m.setImageUrl(rs.getString("imageUrl"));
        m.setCreatedAt(rs.getTimestamp("createdAt"));
        m.setUpdatedAt(rs.getTimestamp("updatedAt"));
        try {
            m.setBrandName(rs.getString("brandName"));
            m.setCategoryName(rs.getString("categoryName"));
            m.setAvgRating(rs.getDouble("avgRating"));
            m.setReviewCount(rs.getInt("reviewCount"));
        } catch (SQLException e) {
            // These columns may not exist in all queries
        }
        return m;
    }
}

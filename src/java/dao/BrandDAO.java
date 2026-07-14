package dao;

import dal.DbContext;
import model.Brand;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Brand operations.
 * Handles CRUD operations for the Brands table.
 */
public class BrandDAO {

    private static final Logger LOGGER = Logger.getLogger(BrandDAO.class.getName());

    /**
     * Get all brands.
     */
    public List<Brand> getAllBrands() {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT * FROM Brands ORDER BY brandName";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToBrand(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all brands", ex);
        }
        return list;
    }

    /**
     * Get brand by ID.
     */
    public Brand getBrandById(int brandId) {
        String sql = "SELECT * FROM Brands WHERE brandId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, brandId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBrand(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting brand by ID", ex);
        }
        return null;
    }

    /**
     * Add a new brand.
     */
    public boolean addBrand(Brand brand) {
        String sql = "INSERT INTO Brands (brandName, logo) VALUES (?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, brand.getBrandName());
            ps.setString(2, brand.getLogo());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error adding brand", ex);
        }
        return false;
    }

    /**
     * Update a brand.
     */
    public boolean updateBrand(Brand brand) {
        String sql = "UPDATE Brands SET brandName = ?, logo = ? WHERE brandId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, brand.getBrandName());
            ps.setString(2, brand.getLogo());
            ps.setInt(3, brand.getBrandId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating brand", ex);
        }
        return false;
    }

    /**
     * Delete a brand.
     */
    public boolean deleteBrand(int brandId) {
        String sql = "DELETE FROM Brands WHERE brandId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, brandId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting brand", ex);
        }
        return false;
    }

    /**
     * Map ResultSet to Brand object.
     */
    private Brand mapResultSetToBrand(ResultSet rs) throws SQLException {
        Brand b = new Brand();
        b.setBrandId(rs.getInt("brandId"));
        b.setBrandName(rs.getString("brandName"));
        b.setLogo(rs.getString("logo"));
        b.setCreatedAt(rs.getTimestamp("createdAt"));
        return b;
    }
}

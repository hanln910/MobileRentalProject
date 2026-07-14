package dao;

import dal.DbContext;
import model.Category;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Category operations.
 * Handles CRUD operations for the Categories table.
 */
public class CategoryDAO {

    private static final Logger LOGGER = Logger.getLogger(CategoryDAO.class.getName());

    /**
     * Get all categories.
     */
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Categories ORDER BY categoryName";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all categories", ex);
        }
        return list;
    }

    /**
     * Get category by ID.
     */
    public Category getCategoryById(int categoryId) {
        String sql = "SELECT * FROM Categories WHERE categoryId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCategory(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting category by ID", ex);
        }
        return null;
    }

    /**
     * Add a new category.
     */
    public boolean addCategory(Category category) {
        String sql = "INSERT INTO Categories (categoryName, description) VALUES (?, ?)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getCategoryName());
            ps.setString(2, category.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error adding category", ex);
        }
        return false;
    }

    /**
     * Update a category.
     */
    public boolean updateCategory(Category category) {
        String sql = "UPDATE Categories SET categoryName = ?, description = ? WHERE categoryId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category.getCategoryName());
            ps.setString(2, category.getDescription());
            ps.setInt(3, category.getCategoryId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating category", ex);
        }
        return false;
    }

    /**
     * Delete a category.
     */
    public boolean deleteCategory(int categoryId) {
        String sql = "DELETE FROM Categories WHERE categoryId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting category", ex);
        }
        return false;
    }

    /**
     * Map ResultSet to Category object.
     */
    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setCategoryId(rs.getInt("categoryId"));
        c.setCategoryName(rs.getString("categoryName"));
        c.setDescription(rs.getString("description"));
        c.setCreatedAt(rs.getTimestamp("createdAt"));
        return c;
    }
}

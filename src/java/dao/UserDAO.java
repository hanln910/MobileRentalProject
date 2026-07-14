package dao;

import dal.DbContext;
import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for User operations.
 * Handles CRUD operations for the Users table.
 */
public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    /**
     * Authenticate user by email and password.
     */
    public User login(String email, String password) {
        String sql = "SELECT u.*, r.roleName FROM Users u "
                + "JOIN Roles r ON u.roleId = r.roleId "
                + "WHERE u.email = ? AND u.password = ? AND u.isActive = 1";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error during login", ex);
        }
        return null;
    }

    /**
     * Register a new customer account.
     */
    public boolean register(User user) {
        String sql = "INSERT INTO Users (fullName, email, phone, password, address, roleId, isActive) "
                + "VALUES (?, ?, ?, ?, ?, 2, 1)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getAddress());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error during registration", ex);
        }
        return false;
    }

    /**
     * Check if an email already exists in the system.
     */
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM Users WHERE email = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking email existence", ex);
        }
        return false;
    }

    /**
     * Get user by ID.
     */
    public User getUserById(int userId) {
        String sql = "SELECT u.*, r.roleName FROM Users u "
                + "JOIN Roles r ON u.roleId = r.roleId "
                + "WHERE u.userId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting user by ID", ex);
        }
        return null;
    }

    /**
     * Get all users with role info (Admin function).
     */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, r.roleName FROM Users u "
                + "JOIN Roles r ON u.roleId = r.roleId "
                + "ORDER BY u.createdAt DESC";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting all users", ex);
        }
        return users;
    }

    /**
     * Update user profile.
     */
    public boolean updateProfile(User user) {
        String sql = "UPDATE Users SET fullName = ?, phone = ?, address = ?, updatedAt = GETDATE() "
                + "WHERE userId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getAddress());
            ps.setInt(4, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating profile", ex);
        }
        return false;
    }

    /**
     * Change user password.
     */
    public boolean changePassword(int userId, String newPassword) {
        String sql = "UPDATE Users SET password = ?, updatedAt = GETDATE() WHERE userId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error changing password", ex);
        }
        return false;
    }

    /**
     * Toggle user active status (lock/unlock).
     */
    public boolean toggleUserStatus(int userId) {
        String sql = "UPDATE Users SET isActive = CASE WHEN isActive = 1 THEN 0 ELSE 1 END, "
                + "updatedAt = GETDATE() WHERE userId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error toggling user status", ex);
        }
        return false;
    }

    /**
     * Delete a user by ID.
     */
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM Users WHERE userId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting user", ex);
        }
        return false;
    }

    /**
     * Create a staff account (Admin function).
     */
    public boolean createStaffAccount(User user) {
        String sql = "INSERT INTO Users (fullName, email, phone, password, address, roleId, isActive) "
                + "VALUES (?, ?, ?, ?, ?, 3, 1)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getAddress());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating staff account", ex);
        }
        return false;
    }

    /**
     * Update user role (Admin function).
     */
    public boolean updateUserRole(int userId, int roleId) {
        String sql = "UPDATE Users SET roleId = ?, updatedAt = GETDATE() WHERE userId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating user role", ex);
        }
        return false;
    }

    /**
     * Get total number of users.
     */
    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM Users";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting users", ex);
        }
        return 0;
    }

    /**
     * Map ResultSet row to User object.
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("userId"));
        user.setFullName(rs.getString("fullName"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setPassword(rs.getString("password"));
        user.setAddress(rs.getString("address"));
        user.setAvatar(rs.getString("avatar"));
        user.setRoleId(rs.getInt("roleId"));
        user.setIsActive(rs.getBoolean("isActive"));
        user.setCreatedAt(rs.getTimestamp("createdAt"));
        user.setUpdatedAt(rs.getTimestamp("updatedAt"));
        try {
            user.setRoleName(rs.getString("roleName"));
        } catch (SQLException e) {
            // roleName column may not exist in all queries
        }
        return user;
    }
}

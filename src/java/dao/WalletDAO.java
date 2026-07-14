package dao;

import dal.DbContext;
import model.Wallet;
import model.WalletTransaction;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Wallet operations.
 */
public class WalletDAO {

    private static final Logger LOGGER = Logger.getLogger(WalletDAO.class.getName());

    /**
     * Get wallet by userId. Creates one if not exists.
     */
    public Wallet getWalletByUserId(int userId) {
        String sql = "SELECT * FROM Wallets WHERE userId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Wallet w = new Wallet();
                    w.setWalletId(rs.getInt("walletId"));
                    w.setUserId(rs.getInt("userId"));
                    w.setBalance(rs.getDouble("balance"));
                    w.setCreatedAt(rs.getTimestamp("createdAt"));
                    w.setUpdatedAt(rs.getTimestamp("updatedAt"));
                    return w;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting wallet", ex);
        }
        // Auto-create wallet if not exists
        return createWallet(userId);
    }

    /**
     * Create a new wallet for a user.
     */
    public Wallet createWallet(int userId) {
        String sql = "INSERT INTO Wallets (userId, balance) VALUES (?, 0.00)";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    Wallet w = new Wallet();
                    w.setWalletId(rs.getInt(1));
                    w.setUserId(userId);
                    w.setBalance(0.0);
                    return w;
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating wallet", ex);
        }
        return null;
    }

    /**
     * Top up wallet balance. Returns true if successful.
     */
    public boolean topUp(int userId, double amount, String description) {
        Connection conn = null;
        try {
            conn = DbContext.getConnection();
            conn.setAutoCommit(false);

            // Update balance
            String sqlUpdate = "UPDATE Wallets SET balance = balance + ?, updatedAt = GETDATE() WHERE userId = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setDouble(1, amount);
                ps.setInt(2, userId);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // Get new balance
            double newBalance = 0;
            String sqlBal = "SELECT balance FROM Wallets WHERE userId = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlBal)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        newBalance = rs.getDouble("balance");
                    }
                }
            }

            // Get walletId
            int walletId = 0;
            String sqlWid = "SELECT walletId FROM Wallets WHERE userId = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlWid)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        walletId = rs.getInt("walletId");
                    }
                }
            }

            // Record transaction
            String sqlTx = "INSERT INTO WalletTransactions (walletId, type, amount, description, balanceAfter) VALUES (?, 'TopUp', ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlTx)) {
                ps.setInt(1, walletId);
                ps.setDouble(2, amount);
                ps.setString(3, description != null ? description : "Wallet top-up");
                ps.setDouble(4, newBalance);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error topping up wallet", ex);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException e) { }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { }
            }
        }
        return false;
    }

    /**
     * Deduct from wallet for an order payment. Returns true if successful.
     */
    public boolean payFromWallet(int userId, double amount, int orderId) {
        Connection conn = null;
        try {
            conn = DbContext.getConnection();
            conn.setAutoCommit(false);

            // Check balance
            double currentBalance = 0;
            int walletId = 0;
            String sqlCheck = "SELECT walletId, balance FROM Wallets WHERE userId = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        walletId = rs.getInt("walletId");
                        currentBalance = rs.getDouble("balance");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if (currentBalance < amount) {
                conn.rollback();
                return false;
            }

            // Deduct balance
            String sqlUpdate = "UPDATE Wallets SET balance = balance - ?, updatedAt = GETDATE() WHERE userId = ? AND balance >= ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setDouble(1, amount);
                ps.setInt(2, userId);
                ps.setDouble(3, amount);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            double newBalance = currentBalance - amount;

            // Record transaction
            String sqlTx = "INSERT INTO WalletTransactions (walletId, type, amount, description, orderId, balanceAfter) VALUES (?, 'Payment', ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlTx)) {
                ps.setInt(1, walletId);
                ps.setDouble(2, amount);
                ps.setString(3, "Payment for Order #ORD-" + String.format("%04d", orderId));
                ps.setInt(4, orderId);
                ps.setDouble(5, newBalance);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error paying from wallet", ex);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException e) { }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { }
            }
        }
        return false;
    }

    /**
     * Deduct from wallet for a damage fine payment. Returns true if successful.
     */
    public boolean payFineFromWallet(int userId, double amount, int orderId) {
        Connection conn = null;
        try {
            conn = DbContext.getConnection();
            conn.setAutoCommit(false);

            double currentBalance = 0;
            int walletId = 0;
            String sqlCheck = "SELECT walletId, balance FROM Wallets WHERE userId = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        walletId = rs.getInt("walletId");
                        currentBalance = rs.getDouble("balance");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if (currentBalance < amount) {
                conn.rollback();
                return false;
            }

            String sqlUpdate = "UPDATE Wallets SET balance = balance - ?, updatedAt = GETDATE() WHERE userId = ? AND balance >= ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setDouble(1, amount);
                ps.setInt(2, userId);
                ps.setDouble(3, amount);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            double newBalance = currentBalance - amount;

            String sqlTx = "INSERT INTO WalletTransactions (walletId, type, amount, description, orderId, balanceAfter) VALUES (?, 'Fine', ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlTx)) {
                ps.setInt(1, walletId);
                ps.setDouble(2, amount);
                ps.setString(3, "Damage fine for Order #ORD-" + String.format("%04d", orderId));
                ps.setInt(4, orderId);
                ps.setDouble(5, newBalance);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error paying fine from wallet", ex);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException e) { }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { }
            }
        }
        return false;
    }

    /**
     * Refund to wallet. Returns true if successful.
     */
    public boolean refundToWallet(int userId, double amount, int orderId) {
        Connection conn = null;
        try {
            conn = DbContext.getConnection();
            conn.setAutoCommit(false);

            String sqlUpdate = "UPDATE Wallets SET balance = balance + ?, updatedAt = GETDATE() WHERE userId = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setDouble(1, amount);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            double newBalance = 0;
            int walletId = 0;
            String sqlBal = "SELECT walletId, balance FROM Wallets WHERE userId = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlBal)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        walletId = rs.getInt("walletId");
                        newBalance = rs.getDouble("balance");
                    }
                }
            }

            String sqlTx = "INSERT INTO WalletTransactions (walletId, type, amount, description, orderId, balanceAfter) VALUES (?, 'Refund', ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlTx)) {
                ps.setInt(1, walletId);
                ps.setDouble(2, amount);
                ps.setString(3, "Refund for cancelled Order #ORD-" + String.format("%04d", orderId));
                ps.setInt(4, orderId);
                ps.setDouble(5, newBalance);
                ps.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error refunding wallet", ex);
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException e) { }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { }
            }
        }
        return false;
    }

    /**
     * Get transaction history for a wallet (newest first) with pagination.
     */
    public List<WalletTransaction> getTransactions(int walletId, int page, int pageSize) {
        List<WalletTransaction> list = new ArrayList<>();
        String sql = "SELECT * FROM WalletTransactions WHERE walletId = ? ORDER BY createdAt DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, walletId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTransaction(rs));
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting transactions", ex);
        }
        return list;
    }

    /**
     * Count total transactions for a wallet.
     */
    public int countTransactions(int walletId) {
        String sql = "SELECT COUNT(*) FROM WalletTransactions WHERE walletId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, walletId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error counting transactions", ex);
        }
        return 0;
    }

    private WalletTransaction mapTransaction(ResultSet rs) throws SQLException {
        WalletTransaction tx = new WalletTransaction();
        tx.setTransactionId(rs.getInt("transactionId"));
        tx.setWalletId(rs.getInt("walletId"));
        tx.setType(rs.getString("type"));
        tx.setAmount(rs.getDouble("amount"));
        tx.setDescription(rs.getString("description"));
        int oid = rs.getInt("orderId");
        tx.setOrderId(rs.wasNull() ? null : oid);
        tx.setBalanceAfter(rs.getDouble("balanceAfter"));
        tx.setCreatedAt(rs.getTimestamp("createdAt"));
        return tx;
    }
}

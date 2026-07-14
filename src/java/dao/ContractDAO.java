package dao;

import dal.DbContext;
import model.RentalContract;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Rental Contract operations.
 */
public class ContractDAO {

    private static final Logger LOGGER = Logger.getLogger(ContractDAO.class.getName());

    /**
     * Create a new draft contract for an order.
     */
    public int createContract(RentalContract contract) {
        String sql = "INSERT INTO RentalContracts (orderId, customerIdCard, customerIdCardImage, customerDOB, emergencyName, emergencyPhone, "
                + "emergencyRelation, depositAmount, terms, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Draft')";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contract.getOrderId());
            ps.setString(2, contract.getCustomerIdCard());
            ps.setString(3, contract.getCustomerIdCardImage());
            ps.setDate(4, contract.getCustomerDOB() != null ? new java.sql.Date(contract.getCustomerDOB().getTime()) : null);
            ps.setString(5, contract.getEmergencyName());
            ps.setString(6, contract.getEmergencyPhone());
            ps.setString(7, contract.getEmergencyRelation());
            ps.setDouble(8, contract.getDepositAmount());
            ps.setString(9, contract.getTerms());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error creating contract", ex);
        }
        return -1;
    }

    /**
     * Get contract by orderId.
     */
    public RentalContract getContractByOrderId(int orderId) {
        String sql = "SELECT c.*, u.fullName AS customerName, u.email AS customerEmail, u.phone AS customerPhone, "
                + "s.fullName AS staffName "
                + "FROM RentalContracts c "
                + "JOIN RentalOrders o ON c.orderId = o.orderId "
                + "JOIN Users u ON o.userId = u.userId "
                + "LEFT JOIN Users s ON c.staffId = s.userId "
                + "WHERE c.orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapContract(rs);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting contract by orderId", ex);
        }
        return null;
    }

    /**
     * Get contract by contractId.
     */
    public RentalContract getContractById(int contractId) {
        String sql = "SELECT c.*, u.fullName AS customerName, u.email AS customerEmail, u.phone AS customerPhone, "
                + "s.fullName AS staffName "
                + "FROM RentalContracts c "
                + "JOIN RentalOrders o ON c.orderId = o.orderId "
                + "JOIN Users u ON o.userId = u.userId "
                + "LEFT JOIN Users s ON c.staffId = s.userId "
                + "WHERE c.contractId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapContract(rs);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error getting contract by id", ex);
        }
        return null;
    }

    /**
     * Customer signs the contract.
     */
    public boolean customerSign(int orderId) {
        String sql = "UPDATE RentalContracts SET customerSigned = 1, customerSignedAt = GETDATE(), "
                + "status = CASE WHEN staffSigned = 1 THEN 'Signed' ELSE status END, "
                + "updatedAt = GETDATE() WHERE orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error customer signing contract", ex);
        }
        return false;
    }

    /**
     * Staff signs the contract.
     */
    public boolean staffSign(int orderId, int staffId) {
        String sql = "UPDATE RentalContracts SET staffSigned = 1, staffSignedAt = GETDATE(), staffId = ?, "
                + "status = CASE WHEN customerSigned = 1 THEN 'Signed' ELSE status END, "
                + "updatedAt = GETDATE() WHERE orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error staff signing contract", ex);
        }
        return false;
    }

    /**
     * Check if contract is fully signed (both parties).
     */
    public boolean isFullySigned(int orderId) {
        String sql = "SELECT customerSigned, staffSigned FROM RentalContracts WHERE orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean("customerSigned") && rs.getBoolean("staffSigned");
                }
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking contract signatures", ex);
        }
        return false;
    }

    /**
     * Complete contract (after rental is returned).
     */
    public boolean completeContract(int orderId) {
        String sql = "UPDATE RentalContracts SET status = 'Completed', updatedAt = GETDATE() WHERE orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error completing contract", ex);
        }
        return false;
    }

    /**
     * Void contract (if order cancelled).
     */
    public boolean voidContract(int orderId) {
        String sql = "UPDATE RentalContracts SET status = 'Voided', updatedAt = GETDATE() WHERE orderId = ?";
        try (Connection conn = DbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error voiding contract", ex);
        }
        return false;
    }

    private RentalContract mapContract(ResultSet rs) throws SQLException {
        RentalContract c = new RentalContract();
        c.setContractId(rs.getInt("contractId"));
        c.setOrderId(rs.getInt("orderId"));
        c.setCustomerIdCard(rs.getString("customerIdCard"));
        try { c.setCustomerIdCardImage(rs.getString("customerIdCardImage")); } catch (SQLException e) { }
        c.setCustomerDOB(rs.getDate("customerDOB"));
        c.setEmergencyName(rs.getString("emergencyName"));
        c.setEmergencyPhone(rs.getString("emergencyPhone"));
        c.setEmergencyRelation(rs.getString("emergencyRelation"));
        c.setDepositAmount(rs.getDouble("depositAmount"));
        c.setTerms(rs.getString("terms"));
        c.setCustomerSigned(rs.getBoolean("customerSigned"));
        c.setCustomerSignedAt(rs.getTimestamp("customerSignedAt"));
        c.setStaffSigned(rs.getBoolean("staffSigned"));
        c.setStaffSignedAt(rs.getTimestamp("staffSignedAt"));
        int sid = rs.getInt("staffId");
        c.setStaffId(rs.wasNull() ? null : sid);
        c.setStatus(rs.getString("status"));
        c.setCreatedAt(rs.getTimestamp("createdAt"));
        c.setUpdatedAt(rs.getTimestamp("updatedAt"));
        try {
            c.setCustomerName(rs.getString("customerName"));
            c.setCustomerEmail(rs.getString("customerEmail"));
            c.setCustomerPhone(rs.getString("customerPhone"));
            c.setStaffName(rs.getString("staffName"));
        } catch (SQLException e) { }
        return c;
    }
}

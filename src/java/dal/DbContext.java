package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Database Connection Utility Class.
 * Provides connection to SQL Server database using JDBC.
 * 
 * @author Hp
 */
public class DbContext {

    // =============================================
    // DATABASE CONFIGURATION - Update these values
    // =============================================
    private static final String SERVER_NAME = "localhost";
    private static final String DB_NAME = "MotoRentDB";
    private static final String PORT_NUMBER = "1433";
    private static final String USER_NAME = "sa";
    private static final String PASSWORD = "123";

    private static final Logger LOGGER = Logger.getLogger(DbContext.class.getName());

    /**
     * Get a connection to the SQL Server database.
     * Uses Microsoft JDBC Driver for SQL Server.
     *
     * @return Connection object or null if connection fails
     */
    public static Connection getConnection() {
        Connection conn = null;
        try {
            // Load SQL Server JDBC Driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // Build connection URL
            String url = "jdbc:sqlserver://" + SERVER_NAME + ":" + PORT_NUMBER
                    + ";databaseName=" + DB_NAME
                    + ";encrypt=true;trustServerCertificate=true";

            // Establish connection
            conn = DriverManager.getConnection(url, USER_NAME, PASSWORD);
            LOGGER.log(Level.INFO, "Database connection established successfully.");
        } catch (ClassNotFoundException ex) {
            LOGGER.log(Level.SEVERE, "SQL Server JDBC Driver not found!", ex);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Failed to connect to database!", ex);
        }
        return conn;
    }

    /**
     * Close a database connection safely.
     *
     * @param conn the connection to close
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                LOGGER.log(Level.INFO, "Database connection closed.");
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error closing database connection!", ex);
            }
        }
    }

    /**
     * Test database connection.
     */
    public static void main(String[] args) {
        Connection conn = getConnection();
        if (conn != null) {
            System.out.println("Connection successful!");
            closeConnection(conn);
        } else {
            System.out.println("Connection failed!");
        }
    }
}

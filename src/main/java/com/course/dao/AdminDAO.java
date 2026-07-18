package com.course.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.course.mode.Admin;
import com.course.util.DBConnection;
import com.course.util.PasswordUtil;

/**
 * AdminDAO — Data Access Object for admin authentication.
 *
 * All queries use PreparedStatement to prevent SQL injection.
 * Passwords are verified via BCrypt — never compared as plain text.
 */
public class AdminDAO {

    private static final Logger LOGGER = Logger.getLogger(AdminDAO.class.getName());

    /**
     * Authenticates an admin by username and password.
     *
     * @param username the submitted username
     * @param password the submitted plain-text password
     * @return Admin object if valid; null otherwise
     */
    public Admin loginAdmin(String username, String password) {

        String sql = "SELECT id, username, password, email, full_name, created_at "
                   + "FROM admins WHERE username = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            // TEMP DEBUG — remove after troubleshooting
            LOGGER.log(Level.SEVERE, "DEBUG: Connected to catalog = " + con.getCatalog()
                    + " | attempting username = [" + username + "]");

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                boolean found = rs.next();
                LOGGER.log(Level.SEVERE, "DEBUG: row found = " + found);
                if (found) {
                    String storedHash = rs.getString("password");
                    LOGGER.log(Level.SEVERE, "DEBUG: stored hash = [" + storedHash + "]");
                    boolean verified = PasswordUtil.verify(password, storedHash);
                    LOGGER.log(Level.SEVERE, "DEBUG: password verify result = " + verified);
                    // BCrypt verification — safe against timing attacks
                    if (verified) {
                        Admin admin = new Admin();
                        admin.setId(rs.getInt("id"));
                        admin.setUsername(rs.getString("username"));
                        admin.setEmail(rs.getString("email"));
                        admin.setFullName(rs.getString("full_name"));
                        return admin;
                    }
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Admin login error for user: " + username
                    + " | exception=" + e.getClass().getName()
                    + " | message=" + e.getMessage()
                    + " | cause=" + (e.getCause() != null ? e.getCause().toString() : "none"));
        }

        return null;
    }
}

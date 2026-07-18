package com.course.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.course.mode.Admin;
import com.course.util.DBConnection;
import com.course.util.PasswordUtil;

public class AdminDAO {

    private static final Logger LOGGER = Logger.getLogger(AdminDAO.class.getName());

    public Admin loginAdmin(String username, String password) {

        String sql = "SELECT id, username, password, email, full_name, created_at "
                   + "FROM admins WHERE username = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");
                    if (PasswordUtil.verify(password, storedHash)) {
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
            LOGGER.log(Level.SEVERE, "Admin login error for user: " + username, e);
        }

        return null;
    }
}

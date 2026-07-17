package com.course.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBConnection — centralised JDBC connection factory.
 *
 * Reads credentials from environment variables first, then falls back
 * to hardcoded defaults for local development.
 *
 * For production, set the environment variables:
 *   DB_URL      = jdbc:mysql://host:3306/course_db
 *   DB_USERNAME = your_user
 *   DB_PASSWORD = your_password
 */
public class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static final String URL =
            System.getenv().getOrDefault("DB_URL",
                    "jdbc:mysql://localhost:3306/course_db?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8&allowPublicKeyRetrieval=true");

    private static final String USERNAME =
            System.getenv().getOrDefault("DB_USERNAME", "root");

    private static final String PASSWORD =
            System.getenv().getOrDefault("DB_PASSWORD", "");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            LOGGER.info("MySQL JDBC Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found!", e);
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    /** Returns a fresh JDBC connection — callers must close it in try-with-resources. */
    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    /** Private constructor — utility class; not meant to be instantiated. */
    private DBConnection() {}
}

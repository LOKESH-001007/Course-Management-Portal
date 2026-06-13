package com.course.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * PasswordUtil — wraps BCrypt for secure password hashing and verification.
 *
 * Never store plain-text passwords. Always hash before persisting.
 */
public final class PasswordUtil {

    /** BCrypt work factor — increase for stronger security (slower hashing). */
    private static final int WORK_FACTOR = 12;

    private PasswordUtil() {}

    /**
     * Hashes a plain-text password using BCrypt.
     *
     * @param plainPassword the raw password entered by the user
     * @return BCrypt hash string (60 characters)
     */
    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(WORK_FACTOR));
    }

    /**
     * Verifies a plain-text password against a BCrypt hash.
     *
     * @param plainPassword the raw password to verify
     * @param hashedPassword the stored BCrypt hash
     * @return true if they match, false otherwise
     */
    public static boolean verify(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }
    public static void main(String[] args) {
        System.out.println(hash("admin123"));
    }
}
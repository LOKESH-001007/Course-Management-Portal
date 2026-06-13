package com.course.util;

import java.util.regex.Pattern;

/**
 * ValidationUtil — centralised server-side input validation.
 *
 * All methods are stateless and thread-safe.
 */
public final class ValidationUtil {

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[6-9]\\d{9}$");

    private static final Pattern NAME_PATTERN =
            Pattern.compile("^[A-Za-z\\s.'-]{2,100}$");

    // At least 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$");

    private ValidationUtil() {}

    public static boolean isNullOrEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPhone(String phone) {
        return phone == null || phone.trim().isEmpty() || PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    public static boolean isValidName(String name) {
        return name != null && NAME_PATTERN.matcher(name.trim()).matches();
    }

    public static boolean isValidPassword(String password) {
        return password != null && PASSWORD_PATTERN.matcher(password).matches();
    }

    public static boolean isPositiveDouble(String value) {
        if (isNullOrEmpty(value)) return false;
        try {
            return Double.parseDouble(value.trim()) >= 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static boolean isPositiveInt(String value) {
        if (isNullOrEmpty(value)) return false;
        try {
            return Integer.parseInt(value.trim()) > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Sanitises a string for safe display (XSS prevention).
     * Use JSTL c:out or fn:escapeXml in JSPs for additional safety.
     */
    public static String sanitise(String input) {
        if (input == null) return "";
        return input.trim()
                .replace("&",  "&amp;")
                .replace("<",  "&lt;")
                .replace(">",  "&gt;")
                .replace("\"", "&quot;")
                .replace("'",  "&#x27;");
    }

    /** Returns trimmed string or empty string if null. */
    public static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
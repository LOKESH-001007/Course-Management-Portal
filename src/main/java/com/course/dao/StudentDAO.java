package com.course.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.course.mode.Student;
import com.course.util.DBConnection;
import com.course.util.PasswordUtil;

/**
 * StudentDAO — Data Access Object for all student-related DB operations.
 *
 * Passwords are hashed with BCrypt before storage.
 * All queries use PreparedStatement — SQL injection safe.
 */
public class StudentDAO {

    private static final Logger LOGGER = Logger.getLogger(StudentDAO.class.getName());

    // ──────────────────────────────────────────────────────────────
    // CREATE
    // ──────────────────────────────────────────────────────────────

    /**
     * Registers a new student. Hashes the password before storage.
     * @return generated student ID or -1 on failure
     */
    public int registerStudent(Student student) {
        String sql = "INSERT INTO students (name, email, password, department, phone) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, student.getName());
            ps.setString(2, student.getEmail());
            ps.setString(3, PasswordUtil.hash(student.getPassword())); // hash!
            ps.setString(4, student.getDepartment());
            ps.setString(5, student.getPhone());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error registering student: " + student.getEmail(), e);
        }
        return -1;
    }

    // ──────────────────────────────────────────────────────────────
    // AUTH
    // ──────────────────────────────────────────────────────────────

    /**
     * Authenticates a student by email + password.
     * @return Student object if valid; null otherwise
     */
    public Student loginStudent(String email, String password) {
        String sql = "SELECT * FROM students WHERE email = ? AND is_active = 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password");
                    if (PasswordUtil.verify(password, storedHash)) {
                        return mapRow(rs);
                    }
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error logging in student: " + email, e);
        }
        return null;
    }

    // ──────────────────────────────────────────────────────────────
    // READ
    // ──────────────────────────────────────────────────────────────

    /** Returns all active students with their enrollment counts. */
    public List<Student> getAllStudents() {
        return searchStudents("", 1, Integer.MAX_VALUE);
    }

    /**
     * Searches students by name/email/department with pagination.
     */
    public List<Student> searchStudents(String keyword, int page, int pageSize) {
        List<Student> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, "
          + "(SELECT COUNT(*) FROM enrollments e WHERE e.student_id = s.id) AS enrollment_count "
          + "FROM students s WHERE s.is_active = 1 ");

        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (s.name LIKE ? OR s.email LIKE ? OR s.department LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        sql.append("ORDER BY s.name ASC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error searching students", e);
        }
        return list;
    }

    public int countStudents(String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM students WHERE is_active = 1 ");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR email LIKE ? OR department LIKE ?) ");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting students", e);
        }
        return 0;
    }

    public Student getStudentById(int id) {
        String sql = "SELECT s.*, "
                   + "(SELECT COUNT(*) FROM enrollments e WHERE e.student_id = s.id) AS enrollment_count "
                   + "FROM students s WHERE s.id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching student id=" + id, e);
        }
        return null;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT id FROM students WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error checking email: " + email, e);
        }
        return false;
    }

    public int getTotalStudents() {
        return querySingleInt("SELECT COUNT(*) FROM students WHERE is_active = 1");
    }

    // ──────────────────────────────────────────────────────────────
    // UPDATE
    // ──────────────────────────────────────────────────────────────

    public boolean updateStudent(Student student) {
        String sql = "UPDATE students SET name=?, department=?, phone=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, student.getName());
            ps.setString(2, student.getDepartment());
            ps.setString(3, student.getPhone());
            ps.setInt(4, student.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating student id=" + student.getId(), e);
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // DELETE (soft-delete)
    // ──────────────────────────────────────────────────────────────

    public boolean deleteStudent(int id) {
        String sql = "UPDATE students SET is_active = 0 WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting student id=" + id, e);
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // Helpers
    // ──────────────────────────────────────────────────────────────

    private Student mapRow(ResultSet rs) throws Exception {
        Student s = new Student();
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        s.setEmail(rs.getString("email"));
        s.setPassword(rs.getString("password"));
        s.setDepartment(rs.getString("department"));
        s.setPhone(rs.getString("phone"));
        s.setActive(rs.getBoolean("is_active"));
        if (rs.getTimestamp("registered_at") != null)
            s.setRegisteredAt(rs.getTimestamp("registered_at").toLocalDateTime());
        try {
            s.setEnrollmentCount(rs.getInt("enrollment_count"));
        } catch (Exception ignored) {}
        return s;
    }

    private int querySingleInt(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in querySingleInt", e);
        }
        return 0;
    }
}
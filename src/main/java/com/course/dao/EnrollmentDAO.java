package com.course.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.course.mode.Enrollment;
import com.course.util.DBConnection;

/**
 * EnrollmentDAO — Data Access Object for enrollment operations.
 *
 * Enforces the UNIQUE constraint on (student_id, course_id)
 * by checking before inserting.
 */
public class EnrollmentDAO {

    private static final Logger LOGGER = Logger.getLogger(EnrollmentDAO.class.getName());

    // ──────────────────────────────────────────────────────────────
    // CREATE
    // ──────────────────────────────────────────────────────────────

    /**
     * Enrolls a student in a course.
     * @return true if enrollment succeeded; false if already enrolled or error
     */
    public boolean enroll(int studentId, int courseId) {
        if (isEnrolled(studentId, courseId)) return false;

        String sql = "INSERT INTO enrollments (student_id, course_id) VALUES (?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error enrolling student=" + studentId + " course=" + courseId, e);
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // READ
    // ──────────────────────────────────────────────────────────────

    public boolean isEnrolled(int studentId, int courseId) {
        String sql = "SELECT id FROM enrollments WHERE student_id = ? AND course_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error checking enrollment", e);
        }
        return false;
    }

    /** Returns all enrollments (admin view) */
    public List<Enrollment> getAllEnrollments() {
        List<Enrollment> list = new ArrayList<>();
        String sql = "SELECT * FROM v_enrollment_details ORDER BY enrolled_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching all enrollments", e);
        }
        return list;
    }

    /** Returns enrollments for a specific student */
    public List<Enrollment> getEnrollmentsByStudent(int studentId) {
        List<Enrollment> list = new ArrayList<>();
        String sql = "SELECT * FROM v_enrollment_details WHERE student_id = ? ORDER BY enrolled_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching enrollments for student=" + studentId, e);
        }
        return list;
    }

    /** Returns enrollments for a specific course */
    public List<Enrollment> getEnrollmentsByCourse(int courseId) {
        List<Enrollment> list = new ArrayList<>();
        String sql = "SELECT * FROM v_enrollment_details WHERE course_id = ? ORDER BY student_name ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching enrollments for course=" + courseId, e);
        }
        return list;
    }

    public int getTotalEnrollments() {
        String sql = "SELECT COUNT(*) FROM enrollments";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting enrollments", e);
        }
        return 0;
    }

    // ──────────────────────────────────────────────────────────────
    // DELETE
    // ──────────────────────────────────────────────────────────────

    public boolean removeEnrollment(int enrollmentId) {
        String sql = "DELETE FROM enrollments WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, enrollmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error removing enrollment id=" + enrollmentId, e);
        }
        return false;
    }

    public boolean removeEnrollment(int studentId, int courseId) {
        String sql = "DELETE FROM enrollments WHERE student_id = ? AND course_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error removing enrollment student=" + studentId, e);
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // Helper
    // ──────────────────────────────────────────────────────────────

    private Enrollment mapRow(ResultSet rs) throws Exception {
        Enrollment e = new Enrollment();
        e.setId(rs.getInt("enrollment_id"));
        e.setStudentId(rs.getInt("student_id"));
        e.setCourseId(rs.getInt("course_id"));
        e.setStudentName(rs.getString("student_name"));
        e.setStudentEmail(rs.getString("student_email"));
        e.setDepartment(rs.getString("department"));
        e.setCourseName(rs.getString("course_name"));
        e.setTrainer(rs.getString("trainer"));
        e.setFees(rs.getDouble("fees"));
        if (rs.getTimestamp("enrolled_at") != null)
            e.setEnrolledAt(rs.getTimestamp("enrolled_at").toLocalDateTime());
        return e;
    }
}
package com.course.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.course.mode.Course;
import com.course.util.DBConnection;

/**
 * CourseDAO — Data Access Object for all course-related DB operations.
 *
 * All queries use PreparedStatement (SQL injection prevention).
 * All resources are closed in try-with-resources blocks (no leaks).
 */
public class CourseDAO {

    private static final Logger LOGGER = Logger.getLogger(CourseDAO.class.getName());

    // ──────────────────────────────────────────────────────────────
    // CREATE
    // ──────────────────────────────────────────────────────────────

    /**
     * Inserts a new course and returns the generated primary key,
     * or -1 on failure.
     */
    public int addCourse(Course course) {
        String sql = "INSERT INTO courses (course_name, trainer, duration, fees, description, category) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, course.getCourseName());
            ps.setString(2, course.getTrainer());
            ps.setString(3, course.getDuration());
            ps.setDouble(4, course.getFees());
            ps.setString(5, course.getDescription());
            ps.setString(6, course.getCategory());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error adding course: " + course.getCourseName(), e);
        }
        return -1;
    }

    // ──────────────────────────────────────────────────────────────
    // READ — All (with optional search + pagination)
    // ──────────────────────────────────────────────────────────────

    /** Returns all active courses ordered by name. */
    public List<Course> getAllCourses() {
        return searchCourses("", "", "", 1, Integer.MAX_VALUE);
    }

    /**
     * Searches courses by name, trainer or category with pagination.
     *
     * @param name     partial course name filter (empty = all)
     * @param trainer  partial trainer name filter (empty = all)
     * @param category category filter (empty = all)
     * @param page     1-based page number
     * @param pageSize records per page
     */
    public List<Course> searchCourses(String name, String trainer,
                                       String category, int page, int pageSize) {

        List<Course> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT c.*, "
          + "       (SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.id) AS enrollment_count "
          + "FROM courses c WHERE c.is_active = 1 ");

        List<Object> params = new ArrayList<>();

        if (name != null && !name.trim().isEmpty()) {
            sql.append("AND c.course_name LIKE ? ");
            params.add("%" + name.trim() + "%");
        }
        if (trainer != null && !trainer.trim().isEmpty()) {
            sql.append("AND c.trainer LIKE ? ");
            params.add("%" + trainer.trim() + "%");
        }
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND c.category = ? ");
            params.add(category.trim());
        }

        sql.append("ORDER BY c.course_name ASC ");
        sql.append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error searching courses", e);
        }

        return list;
    }

    /** Counts total courses matching the given filters (for pagination). */
    public int countCourses(String name, String trainer, String category) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM courses WHERE is_active = 1 ");

        List<Object> params = new ArrayList<>();

        if (name != null && !name.trim().isEmpty()) {
            sql.append("AND course_name LIKE ? ");
            params.add("%" + name.trim() + "%");
        }
        if (trainer != null && !trainer.trim().isEmpty()) {
            sql.append("AND trainer LIKE ? ");
            params.add("%" + trainer.trim() + "%");
        }
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND category = ? ");
            params.add(category.trim());
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting courses", e);
        }
        return 0;
    }

    /** Returns a single course by ID, or null if not found. */
    public Course getCourseById(int id) {
        String sql = "SELECT c.*, "
                   + "(SELECT COUNT(*) FROM enrollments e WHERE e.course_id = c.id) AS enrollment_count "
                   + "FROM courses c WHERE c.id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching course id=" + id, e);
        }
        return null;
    }

    /** Returns total count of active courses. */
    public int getTotalActiveCourses() {
        String sql = "SELECT COUNT(*) FROM courses WHERE is_active = 1";
        return querySingleInt(sql);
    }

    /** Returns total course count. */
    public int getTotalCourses() {
        return querySingleInt("SELECT COUNT(*) FROM courses");
    }

    /** Returns list of distinct categories. */
    public List<String> getCategories() {
        List<String> cats = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM courses WHERE is_active = 1 ORDER BY category";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) cats.add(rs.getString("category"));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching categories", e);
        }
        return cats;
    }

    // ──────────────────────────────────────────────────────────────
    // UPDATE
    // ──────────────────────────────────────────────────────────────

    public boolean updateCourse(Course course) {
        String sql = "UPDATE courses SET course_name=?, trainer=?, duration=?, fees=?, "
                   + "description=?, category=? WHERE id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, course.getCourseName());
            ps.setString(2, course.getTrainer());
            ps.setString(3, course.getDuration());
            ps.setDouble(4, course.getFees());
            ps.setString(5, course.getDescription());
            ps.setString(6, course.getCategory());
            ps.setInt(7, course.getId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating course id=" + course.getId(), e);
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // DELETE (soft-delete via is_active flag)
    // ──────────────────────────────────────────────────────────────

    public boolean deleteCourse(int id) {
        String sql = "UPDATE courses SET is_active = 0 WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting course id=" + id, e);
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // Helper
    // ──────────────────────────────────────────────────────────────

    private Course mapRow(ResultSet rs) throws Exception {
        Course c = new Course();
        c.setId(rs.getInt("id"));
        c.setCourseName(rs.getString("course_name"));
        c.setTrainer(rs.getString("trainer"));
        c.setDuration(rs.getString("duration"));
        c.setFees(rs.getDouble("fees"));
        c.setDescription(rs.getString("description"));
        c.setCategory(rs.getString("category"));
        c.setActive(rs.getBoolean("is_active"));
        if (rs.getTimestamp("created_at") != null)
            c.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        if (rs.getTimestamp("updated_at") != null)
            c.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        try {
            c.setEnrollmentCount(rs.getInt("enrollment_count"));
        } catch (Exception ignored) {}
        return c;
    }

    private int querySingleInt(String sql) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in querySingleInt: " + sql, e);
        }
        return 0;
    }
}
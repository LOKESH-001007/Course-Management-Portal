package com.course.controller;

import java.io.IOException;
import java.util.List;

import com.course.dao.CourseDAO;
import com.course.mode.Course;
import com.course.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * CourseServlet — handles all course-related HTTP requests.
 *
 * URL: /course?action=list|add|edit|update|delete|view
 *
 * Improvements over original:
 *   - Centralised input validation
 *   - Pagination support (page + pageSize params)
 *   - Search by name, trainer, category
 *   - Category and description fields
 *   - Soft-delete (is_active=0) instead of hard DELETE
 *   - Proper error forwarding
 */
public class CourseServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int  PAGE_SIZE        = 8;

    private final CourseDAO dao = new CourseDAO();

    // ── GET ────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = ValidationUtil.trim(request.getParameter("action"));

        switch (action) {
            case "list"   -> listCourses(request, response);
            case "edit"   -> showEditForm(request, response);
            case "delete" -> deleteCourse(request, response);
            case "view"   -> viewCourse(request, response);
            case "add"    -> request.getRequestDispatcher("admin/add-course.jsp").forward(request, response);
            default       -> response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    // ── POST ───────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = ValidationUtil.trim(request.getParameter("action"));

        switch (action) {
            case "add"    -> addCourse(request, response);
            case "update" -> updateCourse(request, response);
            default       -> response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    // ── LIST ───────────────────────────────────────────────────────

    private void listCourses(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name     = ValidationUtil.trim(request.getParameter("name"));
        String trainer  = ValidationUtil.trim(request.getParameter("trainer"));
        String category = ValidationUtil.trim(request.getParameter("category"));
        int    page     = parsePageParam(request.getParameter("page"));

        List<Course> courses  = dao.searchCourses(name, trainer, category, page, PAGE_SIZE);
        int          total    = dao.countCourses(name, trainer, category);
        int          pages    = (int) Math.ceil((double) total / PAGE_SIZE);
        List<String> cats     = dao.getCategories();

        request.setAttribute("courseList",      courses);
        request.setAttribute("totalCount",      total);
        request.setAttribute("currentPage",     page);
        request.setAttribute("totalPages",      pages);
        request.setAttribute("categories",      cats);
        request.setAttribute("searchName",      name);
        request.setAttribute("searchTrainer",   trainer);
        request.setAttribute("searchCategory",  category);

        request.getRequestDispatcher("admin/view-courses.jsp").forward(request, response);
    }

    // ── VIEW DETAIL ────────────────────────────────────────────────

    private void viewCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = parseId(request.getParameter("id"));
        if (id <= 0) { response.sendRedirect(request.getContextPath() + "/course?action=list"); return; }

        Course course = dao.getCourseById(id);
        if (course == null) { response.sendRedirect(request.getContextPath() + "/course?action=list"); return; }

        request.setAttribute("course", course);
        request.getRequestDispatcher("admin/course-detail.jsp").forward(request, response);
    }

    // ── ADD ────────────────────────────────────────────────────────

    private void addCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name        = ValidationUtil.trim(request.getParameter("courseName"));
        String trainer     = ValidationUtil.trim(request.getParameter("trainer"));
        String duration    = ValidationUtil.trim(request.getParameter("duration"));
        String feesStr     = ValidationUtil.trim(request.getParameter("fees"));
        String description = ValidationUtil.trim(request.getParameter("description"));
        String category    = ValidationUtil.trim(request.getParameter("category"));

        // Validation
        if (ValidationUtil.isNullOrEmpty(name) || ValidationUtil.isNullOrEmpty(trainer)
                || ValidationUtil.isNullOrEmpty(duration)) {
            request.setAttribute("error", "Course name, trainer, and duration are required.");
            request.getRequestDispatcher("admin/add-course.jsp").forward(request, response);
            return;
        }
        if (!ValidationUtil.isPositiveDouble(feesStr)) {
            request.setAttribute("error", "Please enter a valid fee amount.");
            request.getRequestDispatcher("admin/add-course.jsp").forward(request, response);
            return;
        }

        Course c = new Course();
        c.setCourseName(name);
        c.setTrainer(trainer);
        c.setDuration(duration);
        c.setFees(Double.parseDouble(feesStr));
        c.setDescription(description);
        c.setCategory(ValidationUtil.isNullOrEmpty(category) ? "General" : category);

        int newId = dao.addCourse(c);

        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/course?action=list&msg=added");
        } else {
            request.setAttribute("error", "Failed to add course. Please try again.");
            request.getRequestDispatcher("admin/add-course.jsp").forward(request, response);
        }
    }

    // ── EDIT FORM ──────────────────────────────────────────────────

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = parseId(request.getParameter("id"));
        if (id <= 0) { response.sendRedirect(request.getContextPath() + "/course?action=list"); return; }

        Course course = dao.getCourseById(id);
        if (course == null) { response.sendRedirect(request.getContextPath() + "/course?action=list"); return; }

        List<String> cats = dao.getCategories();
        request.setAttribute("course",     course);
        request.setAttribute("categories", cats);
        request.getRequestDispatcher("admin/edit-course.jsp").forward(request, response);
    }

    // ── UPDATE ─────────────────────────────────────────────────────

    private void updateCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = parseId(request.getParameter("id"));
        if (id <= 0) { response.sendRedirect(request.getContextPath() + "/course?action=list"); return; }

        String name        = ValidationUtil.trim(request.getParameter("courseName"));
        String trainer     = ValidationUtil.trim(request.getParameter("trainer"));
        String duration    = ValidationUtil.trim(request.getParameter("duration"));
        String feesStr     = ValidationUtil.trim(request.getParameter("fees"));
        String description = ValidationUtil.trim(request.getParameter("description"));
        String category    = ValidationUtil.trim(request.getParameter("category"));

        if (ValidationUtil.isNullOrEmpty(name) || ValidationUtil.isNullOrEmpty(trainer)
                || ValidationUtil.isNullOrEmpty(duration)) {
            Course existing = dao.getCourseById(id);
            request.setAttribute("course", existing);
            request.setAttribute("error",  "Course name, trainer, and duration are required.");
            request.getRequestDispatcher("admin/edit-course.jsp").forward(request, response);
            return;
        }
        if (!ValidationUtil.isPositiveDouble(feesStr)) {
            Course existing = dao.getCourseById(id);
            request.setAttribute("course", existing);
            request.setAttribute("error",  "Please enter a valid fee amount.");
            request.getRequestDispatcher("admin/edit-course.jsp").forward(request, response);
            return;
        }

        Course c = new Course();
        c.setId(id);
        c.setCourseName(name);
        c.setTrainer(trainer);
        c.setDuration(duration);
        c.setFees(Double.parseDouble(feesStr));
        c.setDescription(description);
        c.setCategory(ValidationUtil.isNullOrEmpty(category) ? "General" : category);

        if (dao.updateCourse(c)) {
            response.sendRedirect(request.getContextPath() + "/course?action=list&msg=updated");
        } else {
            request.setAttribute("course", c);
            request.setAttribute("error",  "Failed to update course. Please try again.");
            request.getRequestDispatcher("admin/edit-course.jsp").forward(request, response);
        }
    }

    // ── DELETE ─────────────────────────────────────────────────────

    private void deleteCourse(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = parseId(request.getParameter("id"));
        if (id > 0) dao.deleteCourse(id);
        response.sendRedirect(request.getContextPath() + "/course?action=list&msg=deleted");
    }

    // ── Helpers ────────────────────────────────────────────────────

    private int parseId(String value) {
        try { return Integer.parseInt(value); }
        catch (Exception e) { return -1; }
    }

    private int parsePageParam(String value) {
        try {
            int p = Integer.parseInt(value);
            return p < 1 ? 1 : p;
        } catch (Exception e) { return 1; }
    }
}
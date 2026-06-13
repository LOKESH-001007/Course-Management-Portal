package com.course.controller;

import java.io.IOException;
import java.util.List;

import com.course.dao.CourseDAO;
import com.course.dao.EnrollmentDAO;
import com.course.dao.StudentDAO;
import com.course.mode.Course;
import com.course.mode.Enrollment;
import com.course.mode.Student;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * EnrollmentServlet — handles enrollment operations.
 *
 * Admin actions : list | remove
 * Student actions: enroll | my-courses | unenroll
 *
 * New functionality not present in the original project.
 */
public class EnrollmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final CourseDAO     courseDAO     = new CourseDAO();
    private final StudentDAO    studentDAO    = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String role   = getRole(request);

        if ("admin".equals(role)) {
            handleAdminGet(action, request, response);
        } else if ("student".equals(role)) {
            handleStudentGet(action, request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String role   = getRole(request);

        if ("student".equals(role) && "enroll".equals(action)) {
            studentEnroll(request, response);
        } else if ("admin".equals(role) && "remove".equals(action)) {
            adminRemove(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    // ── ADMIN ──────────────────────────────────────────────────────

    private void handleAdminGet(String action, HttpServletRequest request,
                                 HttpServletResponse response)
            throws ServletException, IOException {

        if ("list".equals(action)) {
            List<Enrollment> list = enrollmentDAO.getAllEnrollments();
            request.setAttribute("enrollmentList", list);
            request.getRequestDispatcher("admin/view-enrollments.jsp").forward(request, response);

        } else if ("by-course".equals(action)) {
            int courseId = parseId(request.getParameter("courseId"));
            Course course = courseDAO.getCourseById(courseId);
            List<Enrollment> list = enrollmentDAO.getEnrollmentsByCourse(courseId);
            request.setAttribute("course",         course);
            request.setAttribute("enrollmentList", list);
            request.getRequestDispatcher("admin/course-detail.jsp").forward(request, response);

        } else {
            response.sendRedirect(request.getContextPath() + "/enrollment?action=list");
        }
    }

    private void adminRemove(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = parseId(request.getParameter("id"));
        if (id > 0) enrollmentDAO.removeEnrollment(id);
        response.sendRedirect(request.getContextPath() + "/enrollment?action=list&msg=removed");
    }

    // ── STUDENT ────────────────────────────────────────────────────

    private void handleStudentGet(String action, HttpServletRequest request,
                                   HttpServletResponse response)
            throws ServletException, IOException {

        if ("my-courses".equals(action) || action == null || action.isEmpty()) {
            Student student = getStudent(request);
            if (student == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

            List<Enrollment> myEnrollments = enrollmentDAO.getEnrollmentsByStudent(student.getId());
            List<Course>     allCourses    = courseDAO.getAllCourses();

            request.setAttribute("myEnrollments", myEnrollments);
            request.setAttribute("allCourses",    allCourses);
            request.getRequestDispatcher("student/my-courses.jsp").forward(request, response);

        } else {
            response.sendRedirect(request.getContextPath() + "/enrollment?action=my-courses");
        }
    }

    private void studentEnroll(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Student student = getStudent(request);
        if (student == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

        int courseId = parseId(request.getParameter("courseId"));
        if (courseId <= 0) {
            response.sendRedirect(request.getContextPath() + "/enrollment?action=my-courses&error=invalid");
            return;
        }

        boolean ok = enrollmentDAO.enroll(student.getId(), courseId);
        String  msg = ok ? "enrolled" : "alreadyEnrolled";
        response.sendRedirect(request.getContextPath() + "/enrollment?action=my-courses&msg=" + msg);
    }

    // ── Helpers ────────────────────────────────────────────────────

    private String getRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (String) session.getAttribute("role") : null;
    }

    private Student getStudent(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? (Student) session.getAttribute("student") : null;
    }

    private int parseId(String val) {
        try { return Integer.parseInt(val); } catch (Exception e) { return -1; }
    }
}
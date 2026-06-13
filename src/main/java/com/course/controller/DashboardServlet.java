package com.course.controller;

import java.io.IOException;

import com.course.dao.CourseDAO;
import com.course.dao.EnrollmentDAO;
import com.course.dao.StudentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * DashboardServlet — loads aggregate statistics for the admin dashboard.
 *
 * Loads: total courses, active courses, total students, total enrollments.
 * Forwards to admin/dashboard.jsp.
 *
 * New component — original project had a static dashboard JSP.
 */
public class DashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final CourseDAO     courseDAO     = new CourseDAO();
    private final StudentDAO    studentDAO    = new StudentDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Load stats
        request.setAttribute("totalCourses",     courseDAO.getTotalCourses());
        request.setAttribute("activeCourses",     courseDAO.getTotalActiveCourses());
        request.setAttribute("totalStudents",     studentDAO.getTotalStudents());
        request.setAttribute("totalEnrollments",  enrollmentDAO.getTotalEnrollments());

        request.getRequestDispatcher("admin/dashboard.jsp").forward(request, response);
    }
}
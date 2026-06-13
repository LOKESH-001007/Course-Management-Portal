package com.course.controller;

import java.io.IOException;

import com.course.dao.AdminDAO;
import com.course.dao.StudentDAO;
import com.course.mode.Admin;
import com.course.mode.Student;
import com.course.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * AuthServlet — handles login, registration, and logout.
 *
 * Security improvements over original:
 *   - BCrypt password verification via DAO (no plain-text comparison)
 *   - Input validation before any DB access
 *   - Session fixation prevention (invalidate + new session on login)
 *   - Session timeout configured in web.xml
 *   - XSS-safe error messages (no reflected user input)
 */
public class AuthServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final AdminDAO   adminDAO   = new AdminDAO();
    private final StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        switch (action == null ? "" : action) {
            case "login"    -> handleLogin(request, response);
            case "register" -> handleRegister(request, response);
            case "logout"   -> handleLogout(request, response);
            default         -> response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            handleLogout(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    // ── LOGIN ──────────────────────────────────────────────────────

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String role     = ValidationUtil.trim(request.getParameter("role"));
        String password = request.getParameter("password");

        if (ValidationUtil.isNullOrEmpty(password)) {
            forward(request, response, "login.jsp", "Password cannot be empty.", null);
            return;
        }

        if ("admin".equals(role)) {
            String username = ValidationUtil.trim(request.getParameter("username"));

            if (ValidationUtil.isNullOrEmpty(username)) {
                forward(request, response, "login.jsp", "Username is required.", null);
                return;
            }

            Admin admin = adminDAO.loginAdmin(username, password);
            if (admin != null) {
                // Prevent session fixation: invalidate old session, create new one
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) oldSession.invalidate();

                HttpSession session = request.getSession(true);
                session.setAttribute("adminUser", admin.getUsername());
                session.setAttribute("adminFullName", admin.getFullName());
                session.setAttribute("role", "admin");
                response.sendRedirect(request.getContextPath() + "/dashboard");
            } else {
                forward(request, response, "login.jsp", "Invalid admin credentials. Please try again.", null);
            }

        } else {
            // Student login
            String email = ValidationUtil.trim(request.getParameter("email"));

            if (!ValidationUtil.isValidEmail(email)) {
                forward(request, response, "login.jsp", "Please enter a valid email address.", null);
                return;
            }

            Student student = studentDAO.loginStudent(email, password);
            if (student != null) {
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) oldSession.invalidate();

                HttpSession session = request.getSession(true);
                session.setAttribute("student", student);
                session.setAttribute("role", "student");
                response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp");
            } else {
                forward(request, response, "login.jsp", "Invalid email or password. Please try again.", null);
            }
        }
    }

    // ── REGISTER ───────────────────────────────────────────────────

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String name       = ValidationUtil.trim(request.getParameter("name"));
        String email      = ValidationUtil.trim(request.getParameter("email"));
        String password   = request.getParameter("password");
        String confirm    = request.getParameter("confirmPassword");
        String department = ValidationUtil.trim(request.getParameter("department"));
        String phone      = ValidationUtil.trim(request.getParameter("phone"));

        // ── Validation chain ──────────────────────────────────────
        if (!ValidationUtil.isValidName(name)) {
            forward(request, response, "register.jsp", "Please enter a valid full name (2–100 letters).", null);
            return;
        }
        if (!ValidationUtil.isValidEmail(email)) {
            forward(request, response, "register.jsp", "Please enter a valid email address.", null);
            return;
        }
        if (ValidationUtil.isNullOrEmpty(department)) {
            forward(request, response, "register.jsp", "Please select your department.", null);
            return;
        }
        if (!ValidationUtil.isValidPassword(password)) {
            forward(request, response, "register.jsp",
                "Password must be at least 8 characters with uppercase, lowercase, digit, and special character.", null);
            return;
        }
        if (!password.equals(confirm)) {
            forward(request, response, "register.jsp", "Passwords do not match.", null);
            return;
        }
        if (!ValidationUtil.isValidPhone(phone)) {
            forward(request, response, "register.jsp", "Please enter a valid 10-digit Indian mobile number.", null);
            return;
        }
        if (studentDAO.emailExists(email)) {
            forward(request, response, "register.jsp", "This email is already registered. Please login.", null);
            return;
        }

        // ── Persist ───────────────────────────────────────────────
        Student student = new Student();
        student.setName(name);
        student.setEmail(email);
        student.setPassword(password); // DAO will hash it
        student.setDepartment(department);
        student.setPhone(phone);

        int newId = studentDAO.registerStudent(student);

        if (newId > 0) {
            forward(request, response, "login.jsp", null, "Registration successful! Please login.");
        } else {
            forward(request, response, "register.jsp", "Registration failed. Please try again.", null);
        }
    }

    // ── LOGOUT ─────────────────────────────────────────────────────

    private void handleLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) session.invalidate();
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    // ── Helper ─────────────────────────────────────────────────────

    private void forward(HttpServletRequest req, HttpServletResponse res,
                         String page, String error, String success)
            throws ServletException, IOException {
        if (error   != null) req.setAttribute("error",   error);
        if (success != null) req.setAttribute("success", success);
        req.getRequestDispatcher(page).forward(req, res);
    }
}
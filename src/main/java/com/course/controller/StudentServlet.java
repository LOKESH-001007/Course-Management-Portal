package com.course.controller;

import java.io.IOException;
import java.util.List;

import com.course.dao.StudentDAO;
import com.course.mode.Student;
import com.course.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * StudentServlet — handles admin-side student management.
 *
 * URL: /student?action=list|view|edit|update|delete
 *
 * New functionality (not present in original project):
 *   - Full CRUD for students (admin manages them)
 *   - Search with pagination
 *   - Student detail view
 *   - Soft-delete
 */
public class StudentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int  PAGE_SIZE        = 8;

    private final StudentDAO dao = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = ValidationUtil.trim(request.getParameter("action"));

        switch (action) {
            case "list"   -> listStudents(request, response);
            case "view"   -> viewStudent(request, response);
            case "edit"   -> showEditForm(request, response);
            case "delete" -> deleteStudent(request, response);
            default       -> response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = ValidationUtil.trim(request.getParameter("action"));
        if ("update".equals(action)) {
            updateStudent(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    // ── LIST ───────────────────────────────────────────────────────

    private void listStudents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = ValidationUtil.trim(request.getParameter("q"));
        int    page    = parsePageParam(request.getParameter("page"));

        List<Student> students = dao.searchStudents(keyword, page, PAGE_SIZE);
        int           total    = dao.countStudents(keyword);
        int           pages    = (int) Math.ceil((double) total / PAGE_SIZE);

        request.setAttribute("studentList",  students);
        request.setAttribute("totalCount",   total);
        request.setAttribute("currentPage",  page);
        request.setAttribute("totalPages",   pages);
        request.setAttribute("searchQuery",  keyword);

        request.getRequestDispatcher("admin/view-students.jsp").forward(request, response);
    }

    // ── VIEW ───────────────────────────────────────────────────────

    private void viewStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = parseId(request.getParameter("id"));
        if (id <= 0) { response.sendRedirect(request.getContextPath() + "/students?action=list"); return; }

        Student student = dao.getStudentById(id);
        if (student == null) { response.sendRedirect(request.getContextPath() + "/students?action=list"); return; }

        request.setAttribute("student", student);
        request.getRequestDispatcher("admin/student-detail.jsp").forward(request, response);
    }

    // ── EDIT FORM ──────────────────────────────────────────────────

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = parseId(request.getParameter("id"));
        if (id <= 0) { response.sendRedirect(request.getContextPath() + "/students?action=list"); return; }

        Student student = dao.getStudentById(id);
        if (student == null) { response.sendRedirect(request.getContextPath() + "/students?action=list"); return; }

        request.setAttribute("student", student);
        request.getRequestDispatcher("admin/edit-student.jsp").forward(request, response);
    }

    // ── UPDATE ─────────────────────────────────────────────────────

    private void updateStudent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int    id         = parseId(request.getParameter("id"));
        String name       = ValidationUtil.trim(request.getParameter("name"));
        String department = ValidationUtil.trim(request.getParameter("department"));
        String phone      = ValidationUtil.trim(request.getParameter("phone"));

        if (id <= 0 || ValidationUtil.isNullOrEmpty(name) || ValidationUtil.isNullOrEmpty(department)) {
            Student s = dao.getStudentById(id);
            request.setAttribute("student", s);
            request.setAttribute("error",   "Name and department are required.");
            request.getRequestDispatcher("admin/edit-student.jsp").forward(request, response);
            return;
        }
        if (!ValidationUtil.isValidPhone(phone)) {
            Student s = dao.getStudentById(id);
            request.setAttribute("student", s);
            request.setAttribute("error",   "Please enter a valid phone number.");
            request.getRequestDispatcher("admin/edit-student.jsp").forward(request, response);
            return;
        }

        Student student = new Student();
        student.setId(id);
        student.setName(name);
        student.setDepartment(department);
        student.setPhone(phone);

        if (dao.updateStudent(student)) {
            response.sendRedirect(request.getContextPath() + "/students?action=list&msg=updated");
        } else {
            request.setAttribute("student", student);
            request.setAttribute("error",   "Update failed. Please try again.");
            request.getRequestDispatcher("admin/edit-student.jsp").forward(request, response);
        }
    }

    // ── DELETE ─────────────────────────────────────────────────────

    private void deleteStudent(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = parseId(request.getParameter("id"));
        if (id > 0) dao.deleteStudent(id);
        response.sendRedirect(request.getContextPath() + "/students?action=list&msg=deleted");
    }

    // ── Helpers ────────────────────────────────────────────────────

    private int parseId(String val) {
        try { return Integer.parseInt(val); } catch (Exception e) { return -1; }
    }

    private int parsePageParam(String val) {
        try { int p = Integer.parseInt(val); return p < 1 ? 1 : p; }
        catch (Exception e) { return 1; }
    }
}
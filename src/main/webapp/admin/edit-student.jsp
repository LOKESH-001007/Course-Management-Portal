<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.course.mode.Student" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Student student = (Student) request.getAttribute("student");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/students?action=list");
        return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Student — Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/main.css" rel="stylesheet">
</head>
<body>

<nav class="navbar navbar-admin navbar-expand-lg">
    <div class="container-fluid">
        <a class="navbar-brand text-white" href="${pageContext.request.contextPath}/dashboard">🎓 Admin Panel</a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#adminNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="adminNav">
            <ul class="navbar-nav me-auto ms-3 gap-1">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/dashboard">🏠 Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/course?action=list">📚 Courses</a></li>
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/students?action=list">👥 Students</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/enrollment?action=list">📋 Enrollments</a></li>
            </ul>
            <div class="navbar-user-badge me-3"><div class="avatar">🛡</div><span><%= adminUser %></span></div>
            <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div class="container page-wrapper" style="max-width:600px;">

    <div class="page-header">
        <div>
            <h1 class="page-title">✏️ Edit Student</h1>
            <p class="page-subtitle">Updating: <strong><%= student.getName() %></strong></p>
        </div>
        <a href="${pageContext.request.contextPath}/students?action=list" class="btn btn-outline-secondary btn-sm">← Back</a>
    </div>

    <% if (error != null) { %>
    <div class="alert alert-danger alert-dismissible fade show">
        ❌ <%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="form-card">
        <!-- Read-only info -->
        <div class="mb-4 p-3 rounded" style="background:#f8f9fa;">
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="fw-semibold text-muted" style="font-size:.8rem;">EMAIL (cannot be changed)</span>
            </div>
            <p class="mb-0 fw-semibold"><%= student.getEmail() %></p>
        </div>

        <form action="${pageContext.request.contextPath}/students" method="post" data-validate>
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= student.getId() %>">

            <div class="row g-3">

                <div class="col-12">
                    <label class="form-label" for="name">Full Name <span class="text-danger">*</span></label>
                    <input type="text" id="name" name="name" class="form-control"
                           value="<%= student.getName() %>" required maxlength="150">
                    <div class="invalid-feedback">Name is required.</div>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="department">Department <span class="text-danger">*</span></label>
                    <select id="department" name="department" class="form-select" required>
                        <%
                            String[] depts = {"Computer Science","Information Technology","Electronics","Mechanical","Civil","Other"};
                            for (String dept : depts) {
                                String sel = dept.equals(student.getDepartment()) ? " selected" : "";
                        %>
                        <option value="<%= dept %>"<%= sel %>><%= dept %></option>
                        <%  } %>
                    </select>
                    <div class="invalid-feedback">Please select a department.</div>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="phone">Phone Number</label>
                    <input type="text" id="phone" name="phone" class="form-control"
                           value="<%= student.getPhone() != null ? student.getPhone() : "" %>"
                           placeholder="10-digit mobile number" maxlength="10" pattern="[6-9]\d{9}">
                    <div class="invalid-feedback">Enter a valid 10-digit mobile number.</div>
                </div>

            </div>

            <hr class="my-4">
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">💾 Save Changes</button>
                <a href="${pageContext.request.contextPath}/students?action=view&id=<%= student.getId() %>" class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

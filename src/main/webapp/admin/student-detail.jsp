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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= student.getName() %> — Student Detail</title>
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

<div class="container page-wrapper" style="max-width:700px;">

    <div class="page-header">
        <div>
            <h1 class="page-title">👤 Student Profile</h1>
            <p class="page-subtitle">ID #<%= student.getId() %></p>
        </div>
        <a href="${pageContext.request.contextPath}/students?action=list" class="btn btn-outline-secondary btn-sm">← Back to Students</a>
    </div>

    <div class="card mb-4">
        <div class="card-body p-4">
            <!-- Avatar Row -->
            <div class="d-flex align-items-center gap-3 mb-4">
                <div style="width:64px;height:64px;border-radius:50%;background:linear-gradient(135deg,#667eea,#764ba2);
                            display:flex;align-items:center;justify-content:center;font-size:1.75rem;color:#fff;">
                    👤
                </div>
                <div>
                    <h4 class="fw-bold mb-0"><%= student.getName() %></h4>
                    <p class="text-muted mb-0 small"><%= student.getEmail() %></p>
                    <span class="badge-dept mt-1 d-inline-block"><%= student.getDepartment() %></span>
                </div>
            </div>

            <hr>

            <dl class="row mb-0" style="font-size:.9rem;">
                <dt class="col-sm-4 text-muted">Student ID</dt>
                <dd class="col-sm-8">#<%= student.getId() %></dd>

                <dt class="col-sm-4 text-muted">Full Name</dt>
                <dd class="col-sm-8"><strong><%= student.getName() %></strong></dd>

                <dt class="col-sm-4 text-muted">Email</dt>
                <dd class="col-sm-8"><%= student.getEmail() %></dd>

                <dt class="col-sm-4 text-muted">Department</dt>
                <dd class="col-sm-8"><%= student.getDepartment() %></dd>

                <dt class="col-sm-4 text-muted">Phone</dt>
                <dd class="col-sm-8"><%= student.getPhone() != null ? student.getPhone() : "—" %></dd>

                <dt class="col-sm-4 text-muted">Status</dt>
                <dd class="col-sm-8">
                    <% if (student.isActive()) { %>
                    <span class="badge bg-success">Active</span>
                    <% } else { %>
                    <span class="badge bg-secondary">Inactive</span>
                    <% } %>
                </dd>

                <dt class="col-sm-4 text-muted">Enrollments</dt>
                <dd class="col-sm-8"><span class="badge bg-primary"><%= student.getEnrollmentCount() %> courses</span></dd>

                <% if (student.getRegisteredAt() != null) { %>
                <dt class="col-sm-4 text-muted">Registered On</dt>
                <dd class="col-sm-8"><%= student.getRegisteredAt().toLocalDate() %></dd>
                <% } %>
            </dl>
        </div>
    </div>

    <div class="d-flex gap-2">
        <a href="${pageContext.request.contextPath}/students?action=edit&id=<%= student.getId() %>" class="btn btn-primary">✏️ Edit Student</a>
        <a href="#" class="btn btn-outline-danger"
           data-delete-url="${pageContext.request.contextPath}/students?action=delete&id=<%= student.getId() %>"
           data-delete-label="<%= student.getName() %>">🗑 Delete</a>
    </div>

</div>

<!-- Delete Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header border-0 pb-0">
                <h6 class="modal-title fw-bold">Confirm Delete</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body"><p id="deleteModalMessage" class="text-muted small"></p></div>
            <div class="modal-footer border-0 pt-0">
                <button class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                <button id="confirmDeleteBtn" class="btn btn-sm btn-danger">Delete</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

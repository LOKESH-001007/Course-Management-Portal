<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.course.mode.Student" %>
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard — Course Management Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/main.css" rel="stylesheet">
</head>
<body>

<nav class="navbar navbar-student navbar-expand-lg">
    <div class="container-fluid">
        <a class="navbar-brand text-white" href="dashboard.jsp">🎓 Course Portal</a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#studentNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="studentNav">
            <ul class="navbar-nav me-auto ms-3 gap-1">
                <li class="nav-item"><a class="nav-link active" href="dashboard.jsp">🏠 Home</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/enrollment?action=my-courses">📚 My Courses</a></li>
            </ul>
            <div class="navbar-user-badge me-3">
                <div class="avatar">👤</div>
                <span><%= student.getName() %></span>
            </div>
            <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3"></div>

<div class="container page-wrapper" style="max-width:960px;">

    <!-- Welcome Banner -->
    <div class="welcome-banner">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div>
                <h4>Welcome back, <%= student.getName() %>! 👋</h4>
                <p>
                    <span class="me-3">📧 <%= student.getEmail() %></span>
                    <span class="me-3">🏫 <%= student.getDepartment() %></span>
                    <% if (student.getPhone() != null && !student.getPhone().isEmpty()) { %>
                    <span>📞 <%= student.getPhone() %></span>
                    <% } %>
                </p>
            </div>
            <div class="text-end">
                <div style="font-size:.8rem;opacity:.75;">Student ID</div>
                <div class="fw-bold">#<%= student.getId() %></div>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <h5 class="fw-bold mb-3 text-muted" style="font-size:.8rem;text-transform:uppercase;letter-spacing:.06em;">Quick Actions</h5>
    <div class="row g-3">
        <div class="col-sm-6 col-md-4">
            <div class="quick-action-card">
                <div class="qac-icon">📚</div>
                <h5>Browse Courses</h5>
                <p>Explore and enroll in available courses</p>
                <a href="${pageContext.request.contextPath}/enrollment?action=my-courses" class="btn btn-primary btn-sm w-100">Browse Courses</a>
            </div>
        </div>
        <div class="col-sm-6 col-md-4">
            <div class="quick-action-card">
                <div class="qac-icon">📋</div>
                <h5>My Enrollments</h5>
                <p>View courses you're enrolled in</p>
                <a href="${pageContext.request.contextPath}/enrollment?action=my-courses" class="btn btn-outline-primary btn-sm w-100">View Enrollments</a>
            </div>
        </div>
        <div class="col-sm-6 col-md-4">
            <div class="quick-action-card">
                <div class="qac-icon">👤</div>
                <h5>My Profile</h5>
                <p><strong><%= student.getName() %></strong><br>
                   <span class="text-muted small"><%= student.getDepartment() %></span>
                </p>
                <span class="badge bg-success">Active</span>
            </div>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

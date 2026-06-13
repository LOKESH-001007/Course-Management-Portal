<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.course.mode.Enrollment" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    List<Enrollment> enrollmentList = (List<Enrollment>) request.getAttribute("enrollmentList");
    if (enrollmentList == null) enrollmentList = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enrollments — Admin</title>
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
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/students?action=list">👥 Students</a></li>
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/enrollment?action=list">📋 Enrollments</a></li>
            </ul>
            <div class="navbar-user-badge me-3"><div class="avatar">🛡</div><span><%= adminUser %></span></div>
            <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3"></div>

<div class="container-fluid page-wrapper px-4">

    <div class="page-header">
        <div>
            <h1 class="page-title">📋 All Enrollments</h1>
            <p class="page-subtitle"><%= enrollmentList.size() %> total enrollments</p>
        </div>
        <!-- Client-side quick filter -->
        <div style="min-width:220px;">
            <input type="text" id="tableSearch" class="form-control" placeholder="🔍 Filter enrollments…">
        </div>
    </div>

    <div class="table-card">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student Name</th>
                        <th>Email</th>
                        <th>Department</th>
                        <th>Course</th>
                        <th>Trainer</th>
                        <th>Fees (₹)</th>
                        <th>Enrolled On</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% if (enrollmentList.isEmpty()) { %>
                    <tr>
                        <td colspan="9" class="text-center py-5 text-muted">
                            <div class="empty-state">
                                <div class="empty-icon">📭</div>
                                <p>No enrollments yet.</p>
                            </div>
                        </td>
                    </tr>
                <% } else {
                       int sno = 1;
                       for (Enrollment e : enrollmentList) { %>
                    <tr>
                        <td class="text-muted"><%= sno++ %></td>
                        <td class="fw-semibold"><%= e.getStudentName() %></td>
                        <td class="text-muted small"><%= e.getStudentEmail() %></td>
                        <td><span class="badge-dept"><%= e.getDepartment() %></span></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/course?action=view&id=<%= e.getCourseId() %>" class="text-decoration-none fw-semibold">
                                <%= e.getCourseName() %>
                            </a>
                        </td>
                        <td><%= e.getTrainer() %></td>
                        <td>₹<%= String.format("%,.2f", e.getFees()) %></td>
                        <td class="text-muted small"><%= e.getEnrolledAt() != null ? e.getEnrolledAt().toLocalDate() : "—" %></td>
                        <td class="text-center">
                            <form action="${pageContext.request.contextPath}/enrollment" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="remove">
                                <input type="hidden" name="id" value="<%= e.getId() %>">
                                <button type="submit" class="btn-action delete" title="Remove Enrollment"
                                        onclick="return confirm('Remove this enrollment?')">🗑</button>
                            </form>
                        </td>
                    </tr>
                <%  } } %>
                </tbody>
            </table>
        </div>
        <div id="tableEmpty" class="empty-state" style="display:none;">
            <div class="empty-icon">🔍</div>
            <p>No enrollments match your search.</p>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

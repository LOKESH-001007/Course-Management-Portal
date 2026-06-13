<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String adminUser     = (String) session.getAttribute("adminUser");
    String adminFullName = (String) session.getAttribute("adminFullName");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String displayName = (adminFullName != null && !adminFullName.isEmpty()) ? adminFullName : adminUser;

    Integer totalCourses    = (Integer) request.getAttribute("totalCourses");
    Integer activeCourses   = (Integer) request.getAttribute("activeCourses");
    Integer totalStudents   = (Integer) request.getAttribute("totalStudents");
    Integer totalEnrollments = (Integer) request.getAttribute("totalEnrollments");

    // Defaults when accessed directly (not through DashboardServlet)
    if (totalCourses    == null) totalCourses    = 0;
    if (activeCourses   == null) activeCourses   = 0;
    if (totalStudents   == null) totalStudents   = 0;
    if (totalEnrollments == null) totalEnrollments = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Course Management Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/main.css" rel="stylesheet">
</head>
<body>

<!-- ── Navbar ───────────────────────────────────────────── -->
<nav class="navbar navbar-admin navbar-expand-lg">
    <div class="container-fluid">
        <a class="navbar-brand text-white" href="${pageContext.request.contextPath}/dashboard">🎓 Admin Panel</a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#adminNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="adminNav">
            <ul class="navbar-nav me-auto ms-3 gap-1">
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/dashboard">🏠 Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/course?action=list">📚 Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/students?action=list">👥 Students</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/enrollment?action=list">📋 Enrollments</a></li>
            </ul>
            <div class="navbar-user-badge me-3">
                <div class="avatar">🛡</div>
                <span><%= displayName %></span>
            </div>
            <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<!-- ── Toast Container ──────────────────────────────────── -->
<div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3"></div>

<div class="container-fluid page-wrapper px-4">

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <h1 class="page-title">Dashboard</h1>
            <p class="page-subtitle">Welcome back, <%= displayName %>! Here's what's happening.</p>
        </div>
        <a href="${pageContext.request.contextPath}/course?action=add" class="btn btn-primary">➕ Add Course</a>
    </div>

    <!-- ── Stat Cards ──────────────────────────────────── -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="stat-card stat-blue">
                <div class="stat-icon">📚</div>
                <div class="stat-value"><%= totalCourses %></div>
                <div class="stat-label">Total Courses</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="stat-card stat-green">
                <div class="stat-icon">✅</div>
                <div class="stat-value"><%= activeCourses %></div>
                <div class="stat-label">Active Courses</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="stat-card stat-orange">
                <div class="stat-icon">👥</div>
                <div class="stat-value"><%= totalStudents %></div>
                <div class="stat-label">Registered Students</div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="stat-card stat-purple">
                <div class="stat-icon">📋</div>
                <div class="stat-value"><%= totalEnrollments %></div>
                <div class="stat-label">Total Enrollments</div>
            </div>
        </div>
    </div>

    <!-- ── Quick Actions ───────────────────────────────── -->
    <h5 class="fw-bold mb-3 text-muted" style="font-size:.85rem;text-transform:uppercase;letter-spacing:.06em;">Quick Actions</h5>
    <div class="row g-3">
        <div class="col-sm-6 col-xl-3">
            <div class="quick-action-card">
                <div class="qac-icon">➕</div>
                <h5>Add Course</h5>
                <p>Create a new training course</p>
                <a href="${pageContext.request.contextPath}/course?action=add" class="btn btn-primary btn-sm w-100">Add Course</a>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="quick-action-card">
                <div class="qac-icon">📚</div>
                <h5>Manage Courses</h5>
                <p>View, edit or delete courses</p>
                <a href="${pageContext.request.contextPath}/course?action=list" class="btn btn-outline-primary btn-sm w-100">View Courses</a>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="quick-action-card">
                <div class="qac-icon">👥</div>
                <h5>Manage Students</h5>
                <p>View and manage student accounts</p>
                <a href="${pageContext.request.contextPath}/students?action=list" class="btn btn-outline-primary btn-sm w-100">View Students</a>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="quick-action-card">
                <div class="qac-icon">📋</div>
                <h5>Enrollments</h5>
                <p>View all course enrollments</p>
                <a href="${pageContext.request.contextPath}/enrollment?action=list" class="btn btn-outline-primary btn-sm w-100">View Enrollments</a>
            </div>
        </div>
    </div>

</div>

<!-- Delete Confirm Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header border-0 pb-0">
                <h6 class="modal-title fw-bold">Confirm Delete</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p id="deleteModalMessage" class="text-muted small">Are you sure you want to delete this record?</p>
            </div>
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

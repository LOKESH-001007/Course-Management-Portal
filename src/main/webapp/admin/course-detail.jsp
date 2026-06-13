<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.course.mode.Course, com.course.mode.Enrollment, java.util.List" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Course course = (Course) request.getAttribute("course");
    if (course == null) {
        response.sendRedirect(request.getContextPath() + "/course?action=list");
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
    <title><%= course.getCourseName() %> — Course Detail</title>
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
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/course?action=list">📚 Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/students?action=list">👥 Students</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/enrollment?action=list">📋 Enrollments</a></li>
            </ul>
            <div class="navbar-user-badge me-3"><div class="avatar">🛡</div><span><%= adminUser %></span></div>
            <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3"></div>

<div class="container page-wrapper" style="max-width:900px;">

    <!-- Header Banner -->
    <div class="course-detail-header">
        <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
            <div>
                <span class="badge bg-light text-dark mb-2"><%= course.getCategory() %></span>
                <h2 class="fw-bold mb-1"><%= course.getCourseName() %></h2>
                <div class="detail-meta">
                    <span>👨‍🏫 <%= course.getTrainer() %></span>
                    <span>⏱ <%= course.getDuration() %></span>
                    <span>👥 <%= course.getEnrollmentCount() %> enrolled</span>
                </div>
            </div>
            <div class="text-end">
                <div class="text-white opacity-75 mb-1" style="font-size:.85rem;">Course Fee</div>
                <div class="fw-bold" style="font-size:1.75rem;">₹<%= String.format("%,.2f", course.getFees()) %></div>
            </div>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <!-- Description -->
        <div class="col-md-8">
            <div class="card h-100">
                <div class="card-body p-4">
                    <h6 class="fw-bold mb-3">📄 Description</h6>
                    <% if (course.getDescription() != null && !course.getDescription().isEmpty()) { %>
                        <p class="text-muted" style="line-height:1.7;"><%= course.getDescription() %></p>
                    <% } else { %>
                        <p class="text-muted fst-italic">No description provided.</p>
                    <% } %>
                </div>
            </div>
        </div>
        <!-- Quick Info -->
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-body p-4">
                    <h6 class="fw-bold mb-3">📊 Course Info</h6>
                    <dl class="mb-0" style="font-size:.875rem;">
                        <dt class="text-muted">Course ID</dt>
                        <dd class="mb-2 fw-semibold">#<%= course.getId() %></dd>
                        <dt class="text-muted">Status</dt>
                        <dd class="mb-2">
                            <% if (course.isActive()) { %>
                            <span class="badge bg-success">Active</span>
                            <% } else { %>
                            <span class="badge bg-secondary">Inactive</span>
                            <% } %>
                        </dd>
                        <% if (course.getCreatedAt() != null) { %>
                        <dt class="text-muted">Created</dt>
                        <dd class="mb-2"><%= course.getCreatedAt().toLocalDate() %></dd>
                        <% } %>
                        <dt class="text-muted">Enrollments</dt>
                        <dd class="mb-0 fw-bold text-primary"><%= course.getEnrollmentCount() %></dd>
                    </dl>
                </div>
            </div>
        </div>
    </div>

    <!-- Actions -->
    <div class="d-flex gap-2 mb-4">
        <a href="${pageContext.request.contextPath}/course?action=edit&id=<%= course.getId() %>" class="btn btn-primary">✏️ Edit Course</a>
        <a href="#" class="btn btn-outline-danger"
           data-delete-url="${pageContext.request.contextPath}/course?action=delete&id=<%= course.getId() %>"
           data-delete-label="<%= course.getCourseName() %>">🗑 Delete</a>
        <a href="${pageContext.request.contextPath}/course?action=list" class="btn btn-outline-secondary ms-auto">← Back to Courses</a>
    </div>

    <!-- Enrolled Students -->
    <div class="card-header-custom mb-0 rounded-top">
        <span>👥 Enrolled Students (<%= enrollmentList.size() %>)</span>
    </div>
    <div class="table-card rounded-top-0">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student Name</th>
                        <th>Email</th>
                        <th>Department</th>
                        <th>Enrolled On</th>
                    </tr>
                </thead>
                <tbody>
                <% if (enrollmentList.isEmpty()) { %>
                    <tr>
                        <td colspan="5" class="text-center py-4 text-muted">No students enrolled in this course yet.</td>
                    </tr>
                <% } else {
                       int sno = 1;
                       for (Enrollment e : enrollmentList) { %>
                    <tr>
                        <td><%= sno++ %></td>
                        <td class="fw-semibold"><%= e.getStudentName() %></td>
                        <td><%= e.getStudentEmail() %></td>
                        <td><span class="badge-dept"><%= e.getDepartment() %></span></td>
                        <td><%= e.getEnrolledAt() != null ? e.getEnrolledAt().toLocalDate() : "—" %></td>
                    </tr>
                <%  } } %>
                </tbody>
            </table>
        </div>
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

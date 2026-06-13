<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.course.mode.Student" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    @SuppressWarnings("unchecked")
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    Integer currentPage       = (Integer) request.getAttribute("currentPage");
    Integer totalPages        = (Integer) request.getAttribute("totalPages");
    Integer totalCount        = (Integer) request.getAttribute("totalCount");
    String  searchQuery       = (String)  request.getAttribute("searchQuery");

    if (studentList  == null) studentList  = new java.util.ArrayList<>();
    if (currentPage  == null) currentPage  = 1;
    if (totalPages   == null) totalPages   = 1;
    if (totalCount   == null) totalCount   = 0;
    if (searchQuery  == null) searchQuery  = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Students — Admin</title>
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

<div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3"></div>

<div class="container-fluid page-wrapper px-4">

    <div class="page-header">
        <div>
            <h1 class="page-title">👥 Students</h1>
            <p class="page-subtitle"><%= totalCount %> registered students</p>
        </div>
    </div>

    <!-- Search Bar -->
    <form method="get" action="${pageContext.request.contextPath}/students" class="filter-bar">
        <input type="hidden" name="action" value="list">
        <div style="flex:1;min-width:200px;">
            <label class="form-label mb-1">Search</label>
            <input type="text" name="q" class="form-control" placeholder="Name, email, or department…" value="<%= searchQuery %>">
        </div>
        <div class="d-flex gap-2 align-items-end">
            <button type="submit" class="btn btn-primary">🔍 Search</button>
            <a href="${pageContext.request.contextPath}/students?action=list" class="btn btn-outline-secondary">✕ Clear</a>
        </div>
    </form>

    <!-- Table -->
    <div class="table-card">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Department</th>
                        <th>Phone</th>
                        <th>Enrolled</th>
                        <th>Registered</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% if (studentList.isEmpty()) { %>
                    <tr>
                        <td colspan="8" class="text-center py-5 text-muted">
                            <div class="empty-state">
                                <div class="empty-icon">👤</div>
                                <p>No students found matching your search.</p>
                            </div>
                        </td>
                    </tr>
                <% } else {
                       int sno = (currentPage - 1) * 8 + 1;
                       for (Student s : studentList) { %>
                    <tr>
                        <td class="text-muted"><%= sno++ %></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/students?action=view&id=<%= s.getId() %>" class="fw-semibold text-decoration-none">
                                <%= s.getName() %>
                            </a>
                        </td>
                        <td><span class="text-muted"><%= s.getEmail() %></span></td>
                        <td><span class="badge-dept"><%= s.getDepartment() %></span></td>
                        <td><%= s.getPhone() != null ? s.getPhone() : "—" %></td>
                        <td><span class="badge bg-light text-dark"><%= s.getEnrollmentCount() %></span></td>
                        <td><%= s.getRegisteredAt() != null ? s.getRegisteredAt().toLocalDate() : "—" %></td>
                        <td class="text-center">
                            <div class="d-flex justify-content-center gap-1">
                                <a href="${pageContext.request.contextPath}/students?action=view&id=<%= s.getId() %>" class="btn-action view" title="View">👁</a>
                                <a href="${pageContext.request.contextPath}/students?action=edit&id=<%= s.getId() %>" class="btn-action edit" title="Edit">✏️</a>
                                <a href="#" class="btn-action delete" title="Delete"
                                   data-delete-url="${pageContext.request.contextPath}/students?action=delete&id=<%= s.getId() %>"
                                   data-delete-label="<%= s.getName() %>">🗑</a>
                            </div>
                        </td>
                    </tr>
                <%  } } %>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <% if (totalPages > 1) { %>
        <div class="d-flex justify-content-center py-3">
            <nav>
                <ul class="pagination mb-0">
                    <li class="page-item <%= (currentPage == 1) ? "disabled" : "" %>">
                        <a class="page-link" href="${pageContext.request.contextPath}/students?action=list&page=<%= currentPage-1 %>&q=<%= searchQuery %>">‹ Prev</a>
                    </li>
                    <% for (int p = 1; p <= totalPages; p++) {
                           String active = (p == currentPage) ? " active" : ""; %>
                    <li class="page-item<%= active %>">
                        <a class="page-link" href="${pageContext.request.contextPath}/students?action=list&page=<%= p %>&q=<%= searchQuery %>"><%= p %></a>
                    </li>
                    <% } %>
                    <li class="page-item <%= (currentPage >= totalPages) ? "disabled" : "" %>">
                        <a class="page-link" href="${pageContext.request.contextPath}/students?action=list&page=<%= currentPage+1 %>&q=<%= searchQuery %>">Next ›</a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>
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

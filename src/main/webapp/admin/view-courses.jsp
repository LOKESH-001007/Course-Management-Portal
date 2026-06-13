<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.course.mode.Course" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Course> courseList   = (List<Course>) request.getAttribute("courseList");
    @SuppressWarnings("unchecked")
    List<String> categories   = (List<String>) request.getAttribute("categories");
    Integer currentPage       = (Integer) request.getAttribute("currentPage");
    Integer totalPages        = (Integer) request.getAttribute("totalPages");
    Integer totalCount        = (Integer) request.getAttribute("totalCount");
    String  searchName        = (String)  request.getAttribute("searchName");
    String  searchTrainer     = (String)  request.getAttribute("searchTrainer");
    String  searchCategory    = (String)  request.getAttribute("searchCategory");

    if (courseList  == null) courseList  = new java.util.ArrayList<>();
    if (currentPage == null) currentPage = 1;
    if (totalPages  == null) totalPages  = 1;
    if (totalCount  == null) totalCount  = 0;
    if (searchName     == null) searchName     = "";
    if (searchTrainer  == null) searchTrainer  = "";
    if (searchCategory == null) searchCategory = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Courses — Admin</title>
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
            <div class="navbar-user-badge me-3">
                <div class="avatar">🛡</div>
                <span><%= adminUser %></span>
            </div>
            <a href="${pageContext.request.contextPath}/auth?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div id="toastContainer" class="toast-container position-fixed top-0 end-0 p-3"></div>

<div class="container-fluid page-wrapper px-4">

    <div class="page-header">
        <div>
            <h1 class="page-title">📚 Courses</h1>
            <p class="page-subtitle"><%= totalCount %> courses found</p>
        </div>
        <a href="${pageContext.request.contextPath}/course?action=add" class="btn btn-primary">➕ Add Course</a>
    </div>

    <!-- Filter Bar -->
    <form method="get" action="${pageContext.request.contextPath}/course" class="filter-bar">
        <input type="hidden" name="action" value="list">
        <div style="flex:1;min-width:160px;">
            <label class="form-label mb-1">Course Name</label>
            <input type="text" name="name" class="form-control" placeholder="Search name…" value="<%= searchName %>">
        </div>
        <div style="flex:1;min-width:140px;">
            <label class="form-label mb-1">Trainer</label>
            <input type="text" name="trainer" class="form-control" placeholder="Search trainer…" value="<%= searchTrainer %>">
        </div>
        <div style="min-width:150px;">
            <label class="form-label mb-1">Category</label>
            <select name="category" class="form-select">
                <option value="">All Categories</option>
                <%
                    if (categories != null) {
                        for (String cat : categories) {
                            String sel = cat.equals(searchCategory) ? " selected" : "";
                %>
                <option value="<%= cat %>"<%= sel %>><%= cat %></option>
                <%      }
                    }
                %>
            </select>
        </div>
        <div class="d-flex gap-2 align-items-end">
            <button type="submit" class="btn btn-primary">🔍 Search</button>
            <a href="${pageContext.request.contextPath}/course?action=list" class="btn btn-outline-secondary">✕ Clear</a>
        </div>
    </form>

    <!-- Table Card -->
    <div class="table-card">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Course Name</th>
                        <th>Trainer</th>
                        <th>Duration</th>
                        <th>Fees (₹)</th>
                        <th>Category</th>
                        <th>Enrolled</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (courseList.isEmpty()) {
                %>
                    <tr>
                        <td colspan="8" class="text-center py-5 text-muted">
                            <div class="empty-state">
                                <div class="empty-icon">📭</div>
                                <p>No courses found. <a href="${pageContext.request.contextPath}/course?action=add">Add one!</a></p>
                            </div>
                        </td>
                    </tr>
                <%
                    } else {
                        int sno = (currentPage - 1) * 8 + 1;
                        for (Course c : courseList) {
                %>
                    <tr>
                        <td class="text-muted"><%= sno++ %></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/course?action=view&id=<%= c.getId() %>" class="fw-semibold text-decoration-none">
                                <%= c.getCourseName() %>
                            </a>
                        </td>
                        <td><%= c.getTrainer() %></td>
                        <td><%= c.getDuration() %></td>
                        <td>₹<%= String.format("%,.2f", c.getFees()) %></td>
                        <td><span class="badge-category"><%= c.getCategory() %></span></td>
                        <td><span class="badge bg-light text-dark"><%= c.getEnrollmentCount() %></span></td>
                        <td class="text-center">
                            <div class="d-flex justify-content-center gap-1">
                                <a href="${pageContext.request.contextPath}/course?action=view&id=<%= c.getId() %>" class="btn-action view" title="View">👁</a>
                                <a href="${pageContext.request.contextPath}/course?action=edit&id=<%= c.getId() %>" class="btn-action edit" title="Edit">✏️</a>
                                <a href="#" class="btn-action delete" title="Delete"
                                   data-delete-url="${pageContext.request.contextPath}/course?action=delete&id=<%= c.getId() %>"
                                   data-delete-label="<%= c.getCourseName() %>">🗑</a>
                            </div>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <% if (totalPages > 1) { %>
        <div class="d-flex justify-content-center py-3">
            <nav>
                <ul class="pagination mb-0">
                    <li class="page-item <%= (currentPage == 1) ? "disabled" : "" %>">
                        <a class="page-link" href="${pageContext.request.contextPath}/course?action=list&page=<%= currentPage - 1 %>&name=<%= searchName %>&trainer=<%= searchTrainer %>&category=<%= searchCategory %>">‹ Prev</a>
                    </li>
                    <%
                        for (int p = 1; p <= totalPages; p++) {
                            String active = (p == currentPage) ? " active" : "";
                    %>
                    <li class="page-item<%= active %>">
                        <a class="page-link" href="${pageContext.request.contextPath}/course?action=list&page=<%= p %>&name=<%= searchName %>&trainer=<%= searchTrainer %>&category=<%= searchCategory %>"><%= p %></a>
                    </li>
                    <%  } %>
                    <li class="page-item <%= (currentPage >= totalPages) ? "disabled" : "" %>">
                        <a class="page-link" href="${pageContext.request.contextPath}/course?action=list&page=<%= currentPage + 1 %>&name=<%= searchName %>&trainer=<%= searchTrainer %>&category=<%= searchCategory %>">Next ›</a>
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
            <div class="modal-body">
                <p id="deleteModalMessage" class="text-muted small"></p>
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

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.course.mode.Course, java.util.List" %>
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
    List<String> categories = (List<String>) request.getAttribute("categories");
    String error = (String) request.getAttribute("error");

    String[] defaultCats = {"General","Programming","Web Development","Data Science",
                             "Cloud Computing","Cybersecurity","Database","Design","DevOps","Mobile Development"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Course — Admin</title>
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

<div class="container page-wrapper" style="max-width:700px;">

    <div class="page-header">
        <div>
            <h1 class="page-title">✏️ Edit Course</h1>
            <p class="page-subtitle">Update details for: <strong><%= course.getCourseName() %></strong></p>
        </div>
        <a href="${pageContext.request.contextPath}/course?action=list" class="btn btn-outline-secondary btn-sm">← Back to Courses</a>
    </div>

    <% if (error != null) { %>
    <div class="alert alert-danger alert-dismissible fade show">
        ❌ <%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="form-card">
        <form action="${pageContext.request.contextPath}/course" method="post" data-validate>
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= course.getId() %>">

            <div class="row g-3">

                <div class="col-12">
                    <label class="form-label" for="courseName">Course Name <span class="text-danger">*</span></label>
                    <input type="text" id="courseName" name="courseName" class="form-control"
                           value="<%= course.getCourseName() %>" required maxlength="200">
                    <div class="invalid-feedback">Course name is required.</div>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="trainer">Trainer Name <span class="text-danger">*</span></label>
                    <input type="text" id="trainer" name="trainer" class="form-control"
                           value="<%= course.getTrainer() %>" required maxlength="150">
                    <div class="invalid-feedback">Trainer name is required.</div>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="category">Category</label>
                    <select id="category" name="category" class="form-select">
                        <%
                            // Build the list of options using defaultCats, merging any DB categories
                            java.util.Set<String> allCats = new java.util.LinkedHashSet<>();
                            for (String dc : defaultCats) allCats.add(dc);
                            if (categories != null) allCats.addAll(categories);

                            for (String cat : allCats) {
                                String sel = cat.equals(course.getCategory()) ? " selected" : "";
                        %>
                        <option value="<%= cat %>"<%= sel %>><%= cat %></option>
                        <%  } %>
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="duration">Duration <span class="text-danger">*</span></label>
                    <input type="text" id="duration" name="duration" class="form-control"
                           value="<%= course.getDuration() %>" required maxlength="100">
                    <div class="invalid-feedback">Duration is required.</div>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="feesInput">Fees (₹) <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text">₹</span>
                        <input type="number" id="feesInput" name="fees" class="form-control"
                               value="<%= course.getFees() %>" required min="0" step="0.01">
                    </div>
                    <div class="invalid-feedback">Valid fee is required.</div>
                </div>

                <div class="col-12">
                    <label class="form-label" for="description">Description</label>
                    <textarea id="description" name="description" class="form-control" rows="4" maxlength="2000"><%= course.getDescription() != null ? course.getDescription() : "" %></textarea>
                </div>

            </div>

            <hr class="my-4">
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">💾 Save Changes</button>
                <a href="${pageContext.request.contextPath}/course?action=view&id=<%= course.getId() %>" class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

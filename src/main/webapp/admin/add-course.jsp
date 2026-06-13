<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Course — Admin</title>
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

<div class="container page-wrapper" style="max-width:700px;">

    <div class="page-header">
        <div>
            <h1 class="page-title">➕ Add New Course</h1>
            <p class="page-subtitle">Fill in the details to create a new course.</p>
        </div>
        <a href="${pageContext.request.contextPath}/course?action=list" class="btn btn-outline-secondary btn-sm">← Back to Courses</a>
    </div>

    <% if (error != null) { %>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        ❌ <%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="form-card">
        <form action="${pageContext.request.contextPath}/course" method="post" data-validate>
            <input type="hidden" name="action" value="add">

            <div class="row g-3">

                <div class="col-12">
                    <label class="form-label" for="courseName">Course Name <span class="text-danger">*</span></label>
                    <input type="text" id="courseName" name="courseName" class="form-control"
                           placeholder="e.g. Java Full Stack Development" required maxlength="200">
                    <div class="invalid-feedback">Please enter a course name.</div>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="trainer">Trainer Name <span class="text-danger">*</span></label>
                    <input type="text" id="trainer" name="trainer" class="form-control"
                           placeholder="e.g. Dr. Arun Kumar" required maxlength="150">
                    <div class="invalid-feedback">Please enter a trainer name.</div>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="category">Category</label>
                    <select id="category" name="category" class="form-select">
                        <option value="General">General</option>
                        <option value="Programming">Programming</option>
                        <option value="Web Development">Web Development</option>
                        <option value="Data Science">Data Science</option>
                        <option value="Cloud Computing">Cloud Computing</option>
                        <option value="Cybersecurity">Cybersecurity</option>
                        <option value="Database">Database</option>
                        <option value="Design">Design</option>
                        <option value="DevOps">DevOps</option>
                        <option value="Mobile Development">Mobile Development</option>
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="duration">Duration <span class="text-danger">*</span></label>
                    <input type="text" id="duration" name="duration" class="form-control"
                           placeholder="e.g. 3 Months / 45 Hours" required maxlength="100">
                    <div class="invalid-feedback">Please enter duration.</div>
                </div>

                <div class="col-md-6">
                    <label class="form-label" for="feesInput">Fees (₹) <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text">₹</span>
                        <input type="number" id="feesInput" name="fees" class="form-control"
                               placeholder="0.00" required min="0" step="0.01" max="999999">
                    </div>
                    <div class="invalid-feedback">Please enter a valid fee amount.</div>
                </div>

                <div class="col-12">
                    <label class="form-label" for="description">Description</label>
                    <textarea id="description" name="description" class="form-control" rows="4"
                              placeholder="Brief description of the course content and objectives…" maxlength="2000"></textarea>
                </div>

            </div>

            <hr class="my-4">
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-primary px-4">✅ Add Course</button>
                <a href="${pageContext.request.contextPath}/course?action=list" class="btn btn-outline-secondary">Cancel</a>
            </div>
        </form>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

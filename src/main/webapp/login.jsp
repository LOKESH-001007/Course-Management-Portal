<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Course Management Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/main.css" rel="stylesheet">
</head>
<body class="auth-page">

<div style="width:100%;max-width:460px;">

    <!-- Logo -->
    <div class="auth-logo">
        🎓 Course Management Portal
        <br><span>Enterprise Learning Platform</span>
    </div>

    <div class="auth-card">
        <h5 class="text-center fw-bold mb-1">Welcome Back</h5>
        <p class="text-center text-muted small mb-4">Sign in to continue to your portal</p>

        <!-- Alerts -->
        <%
            String error   = (String) request.getAttribute("error");
            String success = (String) request.getAttribute("success");
        %>
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show py-2 small" role="alert">
            ❌ <%= error %>
            <button type="button" class="btn-close btn-close-sm" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        <% if (success != null) { %>
        <div class="alert alert-success alert-dismissible fade show py-2 small" role="alert">
            ✅ <%= success %>
            <button type="button" class="btn-close btn-close-sm" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Role Tabs -->
        <ul class="nav nav-pills nav-fill mb-4" id="roleTab">
            <li class="nav-item">
                <a class="nav-link active" id="student-tab" href="#" onclick="switchRole('student'); return false;">
                    🎓 Student
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="admin-tab" href="#" onclick="switchRole('admin'); return false;">
                    🛡 Admin
                </a>
            </li>
        </ul>

        <form action="auth" method="post">
            <input type="hidden" name="action" value="login">
            <input type="hidden" name="role" id="roleInput" value="student">

            <!-- Student Fields -->
            <div id="studentFields">
                <div class="mb-3">
                    <label class="form-label">Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="student@example.com" autocomplete="email">
                </div>
            </div>

            <!-- Admin Fields (hidden by default) -->
            <div id="adminFields" style="display:none;">
                <div class="mb-3">
                    <label class="form-label">Username</label>
                    <input type="text" name="username" class="form-control" placeholder="admin" autocomplete="username">
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label">Password</label>
                <input type="password" name="password" class="form-control" placeholder="••••••••" autocomplete="current-password">
            </div>

            <button type="submit" class="btn btn-primary w-100 mb-3 py-2">Sign In →</button>
        </form>

        <div class="text-center" id="registerLink">
            <span class="text-muted small">Don't have an account?</span>
            <a href="register.jsp" class="text-decoration-none ms-1 small fw-semibold">Register here</a>
        </div>
    </div>
</div>

<style>
.nav-pills .nav-link { color: var(--primary); border-radius: var(--radius-sm); }
.nav-pills .nav-link.active { background: var(--primary); color: #fff; }
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/main.js"></script>
</body>
</html>

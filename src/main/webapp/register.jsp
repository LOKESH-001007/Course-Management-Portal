<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register — Course Management Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="css/main.css" rel="stylesheet">
</head>
<body class="auth-page">

<div style="width:100%;max-width:500px;">

    <div class="auth-logo">
        🎓 Course Management Portal
        <br><span>Create your student account</span>
    </div>

    <div class="auth-card">
        <h5 class="text-center fw-bold mb-1">Student Registration</h5>
        <p class="text-center text-muted small mb-4">Fill in your details to get started</p>

        <%
            String error = (String) request.getAttribute("error");
        %>
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show py-2 small">
            ❌ <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <form action="auth" method="post" data-validate>
            <input type="hidden" name="action" value="register">

            <div class="mb-3">
                <label class="form-label" for="regName">Full Name <span class="text-danger">*</span></label>
                <input type="text" id="regName" name="name" class="form-control"
                       required placeholder="John Doe" minlength="2" maxlength="100">
                <div class="invalid-feedback">Please enter your full name (2–100 letters).</div>
            </div>

            <div class="mb-3">
                <label class="form-label" for="regEmail">Email Address <span class="text-danger">*</span></label>
                <input type="email" id="regEmail" name="email" class="form-control"
                       required placeholder="john@email.com">
                <div class="invalid-feedback">Please enter a valid email address.</div>
            </div>

            <div class="mb-3">
                <label class="form-label" for="regDept">Department <span class="text-danger">*</span></label>
                <select id="regDept" name="department" class="form-select" required>
                    <option value="">— Select your department —</option>
                    <option>Computer Science</option>
                    <option>Information Technology</option>
                    <option>Electronics</option>
                    <option>Mechanical</option>
                    <option>Civil</option>
                    <option>Other</option>
                </select>
                <div class="invalid-feedback">Please select your department.</div>
            </div>

            <div class="mb-3">
                <label class="form-label" for="regPhone">Mobile Number <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text">+91</span>
                    <input type="tel" id="regPhone" name="phone" class="form-control"
                           required placeholder="9876543210" pattern="[6-9]\d{9}" maxlength="10">
                </div>
                <div class="invalid-feedback">Please enter a valid 10-digit Indian mobile number.</div>
            </div>

            <div class="mb-3">
                <label class="form-label" for="password">Password <span class="text-danger">*</span></label>
                <input type="password" id="password" name="password" class="form-control"
                       required placeholder="Min. 8 chars, with upper, lower, number & symbol"
                       minlength="8">
                <div class="form-text small text-muted">At least 8 chars: uppercase, lowercase, digit, and special character.</div>
                <div class="invalid-feedback">Password must meet the requirements above.</div>
            </div>

            <div class="mb-4">
                <label class="form-label" for="confirmPassword">Confirm Password <span class="text-danger">*</span></label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                       required placeholder="Repeat password" minlength="8">
                <div class="invalid-feedback">Passwords do not match.</div>
            </div>

            <button type="submit" class="btn btn-primary w-100 mb-3 py-2">Create Account →</button>
        </form>

        <div class="text-center">
            <span class="text-muted small">Already have an account?</span>
            <a href="login.jsp" class="text-decoration-none ms-1 small fw-semibold">Login here</a>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/main.js"></script>
</body>
</html>

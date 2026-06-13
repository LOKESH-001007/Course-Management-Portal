<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.course.mode.Student, com.course.mode.Course, com.course.mode.Enrollment, java.util.List, java.util.Set, java.util.HashSet" %>
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Enrollment> myEnrollments = (List<Enrollment>) request.getAttribute("myEnrollments");
    @SuppressWarnings("unchecked")
    List<Course> allCourses = (List<Course>) request.getAttribute("allCourses");

    if (myEnrollments == null) myEnrollments = new java.util.ArrayList<>();
    if (allCourses    == null) allCourses    = new java.util.ArrayList<>();

    // Build enrolled course IDs for quick lookup
    Set<Integer> enrolledIds = new HashSet<>();
    for (Enrollment e : myEnrollments) enrolledIds.add(e.getCourseId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses — Student Portal</title>
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
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp">🏠 Home</a></li>
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/enrollment?action=my-courses">📚 My Courses</a></li>
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

<div class="container page-wrapper" style="max-width:1100px;">

    <!-- ── My Enrollments ─────────────────────────────── -->
    <div class="page-header">
        <div>
            <h1 class="page-title">📋 My Enrollments</h1>
            <p class="page-subtitle"><%= myEnrollments.size() %> courses enrolled</p>
        </div>
    </div>

    <% if (myEnrollments.isEmpty()) { %>
    <div class="card mb-4">
        <div class="empty-state py-5">
            <div class="empty-icon">📚</div>
            <p>You haven't enrolled in any courses yet. Browse the courses below!</p>
        </div>
    </div>
    <% } else { %>
    <div class="row g-3 mb-5">
        <% for (Enrollment e : myEnrollments) { %>
        <div class="col-sm-6 col-lg-4">
            <div class="card h-100 p-0">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span class="badge-category"><%= e.getCourseName().length() > 2 ? "📚" : "" %></span>
                        <span class="enrolled-badge">✅ Enrolled</span>
                    </div>
                    <h6 class="fw-bold mb-1"><%= e.getCourseName() %></h6>
                    <p class="text-muted small mb-2">👨‍🏫 <%= e.getTrainer() %></p>
                    <p class="mb-1 fw-semibold text-primary">₹<%= String.format("%,.2f", e.getFees()) %></p>
                    <p class="text-muted small mb-0">
                        Enrolled: <%= e.getEnrolledAt() != null ? e.getEnrolledAt().toLocalDate() : "—" %>
                    </p>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>

    <!-- ── All Available Courses ──────────────────────── -->
    <div class="page-header">
        <div>
            <h1 class="page-title">🌐 Available Courses</h1>
            <p class="page-subtitle">Browse and enroll in courses</p>
        </div>
        <div style="min-width:220px;">
            <input type="text" id="tableSearch" class="form-control" placeholder="🔍 Search courses…">
        </div>
    </div>

    <div class="table-card">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Course Name</th>
                        <th>Trainer</th>
                        <th>Duration</th>
                        <th>Fees</th>
                        <th>Category</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                <% if (allCourses.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="text-center py-4 text-muted">No courses available at the moment.</td>
                    </tr>
                <% } else {
                       int sno = 1;
                       for (Course c : allCourses) {
                           boolean enrolled = enrolledIds.contains(c.getId());
                %>
                    <tr>
                        <td class="text-muted"><%= sno++ %></td>
                        <td class="fw-semibold"><%= c.getCourseName() %></td>
                        <td><%= c.getTrainer() %></td>
                        <td><%= c.getDuration() %></td>
                        <td class="fw-semibold">₹<%= String.format("%,.2f", c.getFees()) %></td>
                        <td><span class="badge-category"><%= c.getCategory() %></span></td>
                        <td class="text-center">
                            <% if (enrolled) { %>
                            <span class="enrolled-badge">✅ Enrolled</span>
                            <% } else { %>
                            <form action="${pageContext.request.contextPath}/enrollment" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="enroll">
                                <input type="hidden" name="courseId" value="<%= c.getId() %>">
                                <button type="submit" class="btn btn-sm btn-outline-primary"
                                        onclick="return confirm('Enroll in \'<%= c.getCourseName() %>\'?')">
                                    Enroll
                                </button>
                            </form>
                            <% } %>
                        </td>
                    </tr>
                <%  } } %>
                </tbody>
            </table>
        </div>
        <div id="tableEmpty" class="empty-state" style="display:none;">
            <div class="empty-icon">🔍</div>
            <p>No courses match your search.</p>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

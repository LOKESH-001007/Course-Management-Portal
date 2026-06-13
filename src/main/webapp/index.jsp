<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String role = (String) session.getAttribute("role");
if ("admin".equals(role)) {
    response.sendRedirect(request.getContextPath() + "/dashboard");
} else if ("student".equals(role)) {
    response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp");
} else {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
}
%>

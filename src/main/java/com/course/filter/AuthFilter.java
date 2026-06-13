package com.course.filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * AuthFilter — enterprise authentication and authorisation filter.
 *
 * Responsibilities:
 *   1. Block unauthenticated access to protected resources.
 *   2. Enforce role-based access (admin vs student areas).
 *   3. Set security response headers (XSS, clickjacking, content sniffing).
 *   4. Add no-cache headers to prevent back-button access after logout.
 */
public class AuthFilter implements Filter {

    /** Resources accessible without authentication. */
    private static final Set<String> PUBLIC_PATHS = new HashSet<>(Arrays.asList(
        "/login.jsp", "/register.jsp", "/auth", "/index.jsp",
        "/css/", "/js/", "/images/", "/favicon.ico"
    ));

    /** Paths that require ADMIN role specifically. */
    private static final Set<String> ADMIN_PATHS = new HashSet<>(Arrays.asList(
        "/admin/", "/course", "/students"
    ));

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        // ── Security headers (applied to every response) ───────────
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options",         "SAMEORIGIN");
        response.setHeader("X-XSS-Protection",        "1; mode=block");
        response.setHeader("Referrer-Policy",          "strict-origin-when-cross-origin");

        // ── No-cache (prevents back-button access after logout) ─────
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma",        "no-cache");
        response.setDateHeader("Expires",   0);

        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = requestURI.substring(contextPath.length());

        // ── Allow public resources ──────────────────────────────────
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        String role         = (session != null) ? (String) session.getAttribute("role") : null;

        // ── Not logged in → redirect to login ───────────────────────
        if (role == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // ── Admin-only paths: block students ────────────────────────
        if (isAdminPath(path) && !"admin".equals(role)) {
            response.sendRedirect(contextPath + "/student/dashboard.jsp");
            return;
        }

        // ── Student dashboard: block admins ─────────────────────────
        if (path.startsWith("/student/") && !"student".equals(role)) {
            response.sendRedirect(contextPath + "/dashboard");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}

    // ──────────────────────────────────────────────────────────────

    private boolean isPublicPath(String path) {
        for (String pub : PUBLIC_PATHS) {
            if (path.equals(pub) || path.startsWith(pub)) return true;
        }
        return false;
    }

    private boolean isAdminPath(String path) {
        for (String admin : ADMIN_PATHS) {
            if (path.startsWith(admin)) return true;
        }
        return false;
    }
}
-- ════════════════════════════════════════════════════════════════
--  Course Management Portal — Database Setup Script
--  Engine: MySQL 8.x
--  Run this entire script once in MySQL Workbench / CLI to create
--  the database, tables, view, and a default admin account.
-- ════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS course_db
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE course_db;

-- ────────────────────────────────────────────────────────────────
-- TABLE: admins
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admins (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,   -- BCrypt hash
    email       VARCHAR(100) NOT NULL UNIQUE,
    full_name   VARCHAR(100) NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────────────────────────────
-- TABLE: students
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS students (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,  -- BCrypt hash
    department    VARCHAR(100) NOT NULL,
    phone         VARCHAR(15)  NOT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    registered_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────────────────────────────
-- TABLE: courses
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS courses (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    course_name  VARCHAR(150)  NOT NULL,
    trainer      VARCHAR(100)  NOT NULL,
    duration     VARCHAR(50)   NOT NULL,
    fees         DECIMAL(10,2) NOT NULL DEFAULT 0,
    description  TEXT,
    category     VARCHAR(100)  NOT NULL,
    is_active    TINYINT(1)    NOT NULL DEFAULT 1,
    created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP
);

-- ────────────────────────────────────────────────────────────────
-- TABLE: enrollments
-- ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS enrollments (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    student_id  INT NOT NULL,
    course_id   INT NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_student_course UNIQUE (student_id, course_id)
);

-- ────────────────────────────────────────────────────────────────
-- VIEW: v_enrollment_details
-- Joins enrollments with student & course info for easy display.
-- ────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_enrollment_details AS
SELECT
    e.id          AS enrollment_id,
    e.student_id,
    e.course_id,
    s.name        AS student_name,
    s.email       AS student_email,
    s.department,
    c.course_name,
    c.trainer,
    c.fees,
    e.enrolled_at
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses  c ON e.course_id  = c.id;

-- ────────────────────────────────────────────────────────────────
-- SEED DATA: default admin account
-- Username: admin   |   Password: Admin@123
-- (BCrypt $2a$ hash below is verified compatible with jBCrypt 0.4)
-- ────────────────────────────────────────────────────────────────
INSERT INTO admins (username, password, email, full_name)
VALUES (
    'admin',
    '$2a$10$MHhjtvfPEQqb8.JjQ0pArOiQW02rTl2hcqEEBgFY620Xq5tGk6v46',
    'admin@coursemanagement.com',
    'System Administrator'
)
ON DUPLICATE KEY UPDATE
    password  = '$2a$10$MHhjtvfPEQqb8.JjQ0pArOiQW02rTl2hcqEEBgFY620Xq5tGk6v46',
    email     = 'admin@coursemanagement.com',
    full_name = 'System Administrator';

-- ────────────────────────────────────────────────────────────────
-- SEED DATA: sample courses (optional — remove if not needed)
-- ────────────────────────────────────────────────────────────────
INSERT INTO courses (course_name, trainer, duration, fees, description, category)
VALUES
('Full Stack Java Development', 'Rajesh Kumar', '3 Months', 15000.00,
 'Comprehensive course covering Core Java, Servlets, JSP, Spring Boot, and MySQL.', 'Programming'),
('Python for Data Science', 'Anitha Sharma', '2 Months', 12000.00,
 'Learn Python, Pandas, NumPy, and Matplotlib for real-world data analysis.', 'Data Science'),
('Web Design with HTML, CSS & JavaScript', 'Vikram Patel', '6 Weeks', 8000.00,
 'Hands-on training in modern responsive web design.', 'Web Development')
ON DUPLICATE KEY UPDATE course_name = course_name;

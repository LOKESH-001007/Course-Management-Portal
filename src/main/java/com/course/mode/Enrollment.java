package com.course.mode;

import java.time.LocalDateTime;

/**
 * Enrollment — represents a student's enrollment in a course.
 */
public class Enrollment {

    private int           id;
    private int           studentId;
    private int           courseId;
    private LocalDateTime enrolledAt;

    // Joined fields — populated from v_enrollment_details view
    private String studentName;
    private String studentEmail;
    private String department;
    private String courseName;
    private String trainer;
    private double fees;

    public Enrollment() {}

    // ── Getters & Setters ─────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public LocalDateTime getEnrolledAt() { return enrolledAt; }
    public void setEnrolledAt(LocalDateTime enrolledAt) { this.enrolledAt = enrolledAt; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public String getTrainer() { return trainer; }
    public void setTrainer(String trainer) { this.trainer = trainer; }

    public double getFees() { return fees; }
    public void setFees(double fees) { this.fees = fees; }
}
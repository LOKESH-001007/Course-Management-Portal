package com.course.mode;

import java.time.LocalDateTime;

/**
 * Course — domain model representing a training course.
 *
 * Upgraded from the original model with additional fields:
 *   description, category, isActive, createdAt, updatedAt
 */
public class Course {

    private int           id;
    private String        courseName;
    private String        trainer;
    private String        duration;
    private double        fees;
    private String        description;
    private String        category;
    private boolean       isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private int           enrollmentCount; // transient — loaded by JOINs

    public Course() {
        this.isActive = true;
        this.category = "General";
    }

    public Course(int id, String courseName, String trainer,
                  String duration, double fees) {
        this.id         = id;
        this.courseName = courseName;
        this.trainer    = trainer;
        this.duration   = duration;
        this.fees       = fees;
        this.isActive   = true;
        this.category   = "General";
    }

    // ── Getters & Setters ─────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public String getTrainer() { return trainer; }
    public void setTrainer(String trainer) { this.trainer = trainer; }

    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }

    public double getFees() { return fees; }
    public void setFees(double fees) { this.fees = fees; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public int getEnrollmentCount() { return enrollmentCount; }
    public void setEnrollmentCount(int enrollmentCount) { this.enrollmentCount = enrollmentCount; }

    @Override
    public String toString() {
        return "Course{id=" + id + ", courseName='" + courseName + "', trainer='" + trainer + "'}";
    }
}
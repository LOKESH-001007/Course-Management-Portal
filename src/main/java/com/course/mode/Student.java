package com.course.mode;

import java.time.LocalDateTime;

/**
 * Student — domain model representing a registered student.
 *
 * Upgraded from original with: phone, isActive, registeredAt,
 * enrollmentCount (transient).
 */
public class Student {

    private int           id;
    private String        name;
    private String        email;
    private String        password; // BCrypt hash — never expose in views
    private String        department;
    private String        phone;
    private boolean       isActive;
    private LocalDateTime registeredAt;
    private int           enrollmentCount; // transient

    public Student() {
        this.isActive = true;
    }

    public Student(int id, String name, String email,
                   String password, String department) {
        this.id         = id;
        this.name       = name;
        this.email      = email;
        this.password   = password;
        this.department = department;
        this.isActive   = true;
    }

    // ── Getters & Setters ─────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getRegisteredAt() { return registeredAt; }
    public void setRegisteredAt(LocalDateTime registeredAt) { this.registeredAt = registeredAt; }

    public int getEnrollmentCount() { return enrollmentCount; }
    public void setEnrollmentCount(int enrollmentCount) { this.enrollmentCount = enrollmentCount; }

    @Override
    public String toString() {
        return "Student{id=" + id + ", name='" + name + "', email='" + email + "'}";
    }
}
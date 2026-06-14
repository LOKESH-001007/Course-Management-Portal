# Course Management Portal

A full-stack Java web application for managing courses, students, and enrollments — built with Servlets, JSP, and MySQL.

## 🔗 Live Demo
https://course-management-portal-production.up.railway.app

## Features

**Admin**
- Dashboard with live stats (total courses, active courses, registered students, total enrollments)
- Add, edit, view, and manage courses
- View and manage registered students
- View all enrollments across the platform

**Student**
- Personal dashboard
- Browse available courses
- Enroll in courses and view "My Enrollments"

## Tech Stack
- **Backend:** Java Servlets (Jakarta EE 10 / Servlet 6.0)
- **Frontend:** JSP, Bootstrap
- **Database:** MySQL
- **Security:** BCrypt password hashing, session-based auth with a custom `AuthFilter`
- **Build:** Maven
- **Server:** Apache Tomcat 10.1

## Architecture
- `controller/` — Servlets handling HTTP requests (Auth, Course, Student, Enrollment, Dashboard)
- `dao/` — Data access layer (JDBC)
- `mode/` — Model/POJO classes
- `filter/` — `AuthFilter` for role-based route protection
- `util/` — DB connection factory, password hashing, validation helpers
- `webapp/admin/` & `webapp/student/` — JSP views per role

## Local Setup

### Prerequisites
- Java 17+
- Maven
- MySQL 8+
- Apache Tomcat 10.1+

### Steps
1. Clone the repo
2. Run the database setup script:
   ```bash
   mysql -u root -p < database/course_db_setup.sql
   ```
3. Set environment variables (or edit `DBConnection.java` defaults):
   ```
   DB_URL=jdbc:mysql://localhost:3306/course_db?useSSL=false&serverTimezone=UTC
   DB_USERNAME=root
   DB_PASSWORD=yourpassword
   ```
4. Build and deploy:
   ```bash
   mvn clean package
   ```
   Deploy the resulting `.war` to Tomcat's `webapps/` folder.

### Default Admin Login
- Username: `admin`
- Password: `Admin@123`

## Docker
A `Dockerfile` is included for containerized deployment (multi-stage Maven build → Tomcat runtime).

```bash
docker build -t course-management-portal .
docker run -p 8080:8080 \
  -e DB_URL=jdbc:mysql://<host>:3306/course_db?useSSL=false \
  -e DB_USERNAME=<user> \
  -e DB_PASSWORD=<password> \
  course-management-portal
```

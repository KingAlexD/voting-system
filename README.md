# Online Voting System

Jakarta Servlet + JSP + JPA (Hibernate) + MySQL online voting application.

## Stack

- Java 21
- Jakarta Servlet 6 / JSP
- JPA 3.1 with Hibernate 6
- MySQL 8
- Bootstrap 5

## Setup

1. Create database:
   - `CREATE DATABASE voting_system_db;`
2. Update DB credentials in [persistence.xml](/c:/Users/Lenovo E14/Desktop/Online_Voting_System/voting-system/src/main/resources/META-INF/persistence.xml).
3. Update SMTP credentials in [web.xml](/c:/Users/Lenovo E14/Desktop/Online_Voting_System/voting-system/src/main/webapp/WEB-INF/web.xml):
   - `mail.smtp.username`
   - `mail.smtp.password` (for Gmail use an App Password, not your normal password)
   - `mail.smtp.from`
   - Recommended: set env vars instead:
     - `MAIL_SMTP_HOST`, `MAIL_SMTP_PORT`, `MAIL_SMTP_USERNAME`, `MAIL_SMTP_PASSWORD`, `MAIL_SMTP_FROM`
     - `MAIL_SMTP_AUTH`, `MAIL_SMTP_STARTTLS`, `MAIL_SMTP_SSL`
4. Optional env config:
   - `ELECTION_PHASE` (`DRAFT`, `OPEN`, `CLOSED`, `RESULTS`)
   - `VOTING_DEADLINE`
   - `APP_BASE_URL`
5. Build and deploy WAR to a Jakarta-compatible server (Tomcat 10.1+).
6. Open app root URL.

## Default Admin

- Email: `admin@votely.local`
- Password: `Admin@123`

The admin user is auto-seeded on app startup.

## Implemented Features

- Voter registration with:
  - first name, last name, email, password, confirm password, birth year, state, country
- BCrypt password hashing
- Email verification code generation and verification gate before login
- Real SMTP email sending for verification codes
- Session-based authentication and protected routes
- CSRF protection for POST requests
- One vote per voter (enforced in DB + backend)
- Under-18 users can register/login but cannot vote or contest
- Approved contester listing with live vote counts
- Candidate manifesto support
- Candidate profile page
- Contester application and admin approval/denial
- Max 3 approved contesters per position enforcement
- Election phase + deadline controls
- Admin dashboard:
  - users list
  - pending contester approvals
  - contester status + vote counts
  - vote audit table
- Admin action audit logs
- Admin search + pagination in dashboard tables
- CSV and PDF exports for reports
- Forgot-password reset flow using secure tokens
- Voter profile update + password change

## Main Routes

- Public:
  - `/index.jsp`
  - `/about.jsp`
  - `/contact.jsp`
  - `/register-view`
  - `/login-view`
  - `/verify-view`
- Voter/Contester:
  - `/dashboard`
  - `/vote` (POST)
  - `/contester/apply` (POST)
  - `/profile`
- Admin:
  - `/admin/dashboard`
  - `/admin/contester/decision` (POST)

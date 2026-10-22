# BasaVaraa 🏠

A house rental management web app that connects **house owners (Bariwala)** with **tenants (Varatia)**, with an admin panel for moderation. Built with classic JSP, Oracle Database and no frameworks.

## Features
- **Owners (Bariwala):** add, edit, delete and manage property listings; review tenant requests; private chat; submit complaints
- **Tenants (Varatia):** browse available properties, send rental requests, track request status, chat with owners, submit complaints
- **Admin:** manage all users, properties and tenant requests; toggle property status (Available / Rented); ban and unban users; resolve complaints with notes
- **Private messaging** per rental request (phone numbers are never exposed)
- **Notification system** with unread-count bell (request updates, new messages, complaint updates, bans)
- Passwords hashed with SHA-256, `PreparedStatement` for all queries, XSS sanitising, role-based session guard that also checks ban status on every request

## Tech Stack
JSP / Java (JDK 17+) · Apache Tomcat · Oracle Database 21c XE (JDBC thin driver) · HTML, CSS, vanilla JavaScript

## Project Structure
```
BasaVaraa/
├── Admin/      admin dashboard, users, properties, requests, complaints, bans
├── BariWala/   owner pages
├── Varatia/    tenant pages
├── User/       login, register, logout
├── includes/   db, session guard, chat, notifications, styles, scripts
└── sql/        schema.sql
```

## Getting Started
1. Install Oracle Database 21c XE and run `sql/schema.sql`.
2. Put the Oracle JDBC driver (`ojdbc8.jar` or `ojdbc11.jar`) in `WEB-INF/lib/` or Tomcat's `lib/`.
3. Set your database URL, user and password in `includes/db.jsp`.
4. Deploy the folder to Tomcat's `webapps/` and open `http://localhost:8080/BasaVaraa/User/Login.jsp`.

> ⚠️ The admin panel has no login screen by default. Add authentication before any real deployment.

## Related
[NexShohor](../nexshohor) is the extended smart-city version of this project.

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>About &mdash; VoCho</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/about.css">
</head>
<body>

  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <main class="about-page">

    <!-- ═══ HERO ══════════════════════════════════════════ -->
    <section class="about-hero">
      <div class="about-hero__left">
        <p class="about-eyebrow">About VoCho</p>
        <h1 class="about-hero__heading">
          Built to<br>
          make <em>every</em><br>
          vote count.
        </h1>
        <p class="about-hero__body">
          VoCho is an end-to-end secure election platform built on Jakarta Servlet,
          JSP, JPA (Hibernate), and MySQL under a clean MVC architecture.
          Every decision &mdash; from hashed credentials to admin audit logs &mdash;
          exists to keep the democratic process honest, verifiable, and tamper-resistant.
        </p>
      </div>

      <div class="about-hero__stat-col">
        <div class="about-stat">
          <div class="about-stat__num">3</div>
          <div class="about-stat__label">Distinct Roles</div>
        </div>
        <div class="about-stat">
          <div class="about-stat__num">1</div>
          <div class="about-stat__label">Vote per voter</div>
        </div>
        <div class="about-stat">
          <div class="about-stat__num">100%</div>
          <div class="about-stat__label">Audit-logged</div>
        </div>
      </div>
    </section>
    <section class="about-pillars">
      <div class="pillar">
        <span class="pillar__icon">&#9673;</span>
        <p class="pillar__title">Role Separation</p>
        <h3 class="pillar__heading">Who can do what &mdash; and nothing more.</h3>
        <p class="pillar__body">
          Voters, contesters, and admins each inhabit a strictly gated session space.
          No action bleeds across role boundaries. Access is checked on every
          request, not assumed from the previous one.
        </p>
      </div>

      <div class="pillar">
        <span class="pillar__icon">&#9878;</span>
        <p class="pillar__title">Election Integrity</p>
        <h3 class="pillar__heading">One voter. One ballot. No exceptions.</h3>
        <p class="pillar__body">
          Only admin-approved contesters can receive votes.
          A database-level constraint makes double-voting structurally impossible &mdash;
          not just policy, but enforced architecture.
        </p>
      </div>

      <div class="pillar">
        <span class="pillar__icon">&#9741;</span>
        <p class="pillar__title">Operational Controls</p>
        <h3 class="pillar__heading">Governance baked in, not bolted on.</h3>
        <p class="pillar__body">
          Admin dashboards, full audit logs, configurable voting deadlines,
          contester suspension, and position-change approvals keep every
          phase of the election under deliberate, traceable control.
        </p>
      </div>
    </section>

    <!-- ═══ STACK ══════════════════════════════════════════ -->
    <section class="about-stack">
      <h2 class="about-stack__heading">The stack<br><em style="font-style:italic;color:#c1440e;">underneath</em></h2>
      <div class="stack-grid">
        <div class="stack-item">
          <p class="stack-item__tag">Backend</p>
          <p class="stack-item__name">Jakarta Servlet</p>
          <p class="stack-item__desc">Request handling, session management, and MVC routing without a heavyweight framework.</p>
        </div>
        <div class="stack-item">
          <p class="stack-item__tag">Persistence</p>
          <p class="stack-item__name">JPA &amp; Hibernate</p>
          <p class="stack-item__desc">Entity mapping, JPQL queries, and transactional integrity over a MySQL 8 database.</p>
        </div>
        <div class="stack-item">
          <p class="stack-item__tag">View Layer</p>
          <p class="stack-item__name">JSP &amp; JSTL</p>
          <p class="stack-item__desc">Server-rendered templates with taglib-driven conditional rendering and no framework dependency.</p>
        </div>
        <div class="stack-item">
          <p class="stack-item__tag">Security</p>
          <p class="stack-item__name">BCrypt + CSRF</p>
          <p class="stack-item__desc">Passwords hashed with BCrypt. Every state-mutating form protected by a per-session CSRF token.</p>
        </div>
      </div>
    </section>

  </main>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

</body>
</html>

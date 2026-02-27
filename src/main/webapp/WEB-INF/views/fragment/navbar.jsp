<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
  <div class="container">
    <a class="navbar-brand fw-bold" href="<%=request.getContextPath()%>/index.jsp">
        <i class="bi bi-check2-square me-2"></i>VoteSystem
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav ms-auto align-items-center">
        <li class="nav-item">
            <a class="nav-link" href="<%=request.getContextPath()%>/index.jsp">Home</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="<%=request.getContextPath()%>/about.jsp">About</a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="<%=request.getContextPath()%>/contact.jsp">Contact</a>
        </li>
        <li class="nav-item ms-lg-3">
            <a class="nav-link" href="<%=request.getContextPath()%>/login-view">Login</a>
        </li>
        <li class="nav-item ms-lg-2">
            <a class="btn btn-primary btn-sm px-3" href="<%=request.getContextPath()%>/register-view">Register</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
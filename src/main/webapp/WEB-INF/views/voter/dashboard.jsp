<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
    <style>
        .stats-card { border-left: 5px solid #0d6efd; transition: transform 0.2s; }
        .stats-card:hover { transform: scale(1.02); }
        .candidate-img { width: 50px; height: 50px; background: #e9ecef; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; color: #6c757d; }
    </style>
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>

    <div class="container py-5">
        <div class="row align-items-center mb-5">
            <div class="col-md-8">
                <h1 class="fw-bold">Voter Dashboard</h1>
                <p class="text-muted lead">Hello Mystery, welcome to the secure voting portal. Exercise your right to vote today.</p>
            </div>
            <div class="col-md-4 text-md-end">
                <span class="badge rounded-pill bg-success px-3 py-2">Account Verified</span>
            </div>
        </div>

        <div class="row g-4 mb-5">
            <div class="col-md-4">
                <div class="card shadow-sm border-0 stats-card p-4">
                    <h6 class="text-muted text-uppercase fw-bold small">Total Candidates</h6>
                    <h2 class="mb-0">08</h2>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card shadow-sm border-0 stats-card p-4" style="border-left-color: #198754;">
                    <h6 class="text-muted text-uppercase fw-bold small">Total Votes Cast</h6>
                    <h2 class="mb-0">3,412</h2>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card shadow-sm border-0 stats-card p-4" style="border-left-color: #ffc107;">
                    <h6 class="text-muted text-uppercase fw-bold small">Days Remaining</h6>
                    <h2 class="mb-0">03</h2>
                </div>
            </div>
        </div>

        <div class="card shadow-sm border-0 overflow-hidden">
            <div class="card-header bg-white py-3 border-bottom">
                <h5 class="mb-0 fw-bold"><i class="bi bi-person-lines-fill me-2"></i>Official Election Candidates</h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4">Candidate Name</th>
                                <th>Position</th>
                                <th class="text-center">Live Count</th>
                                <th class="text-end pe-4">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="ps-4">
                                    <div class="d-flex align-items-center">
                                        <div class="candidate-img me-3"><i class="bi bi-person"></i></div>
                                        <div>
                                            <div class="fw-bold">Abubakar Bello</div>
                                            <small class="text-muted">Kano State</small>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="badge bg-primary-subtle text-primary border border-primary-subtle">PRESIDENT</span></td>
                                <td class="text-center fw-bold">1,205</td>
                                <td class="text-end pe-4">
                                    <form action="<%=request.getContextPath()%>/cast-vote" method="POST">
                                        <button type="submit" class="btn btn-primary btn-sm px-4">Vote</button>
                                    </form>
                                </td>
                            </tr>
                            <tr>
                                <td class="ps-4">
                                    <div class="d-flex align-items-center">
                                        <div class="candidate-img me-3"><i class="bi bi-person"></i></div>
                                        <div>
                                            <div class="fw-bold">Chinwe Egwu</div>
                                            <small class="text-muted">Enugu State</small>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="badge bg-info-subtle text-info border border-info-subtle">VICE_PRESIDENT</span></td>
                                <td class="text-center fw-bold">894</td>
                                <td class="text-end pe-4">
                                    <form action="<%=request.getContextPath()%>/cast-vote" method="POST">
                                        <button type="submit" class="btn btn-primary btn-sm px-4">Vote</button>
                                    </form>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Contact | Online Voting System</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <main class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body p-4 p-md-5">
                        <h2 class="mb-2">Contact Support</h2>
                        <p class="text-muted mb-4">Need help with registration, verification, voting, or admin access? Send a message.</p>
                        <form action="${pageContext.request.contextPath}/contact" method="POST" class="row g-3">
                            <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                            <div class="col-md-6">
                                <label class="form-label">Full Name</label>
                                <input type="text" name="senderName" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="senderEmail" class="form-control" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Subject</label>
                                <select name="subject" class="form-select">
                                    <option value="Registration Issue">Registration Issue</option>
                                    <option value="Vote Confirmation">Vote Confirmation</option>
                                    <option value="Candidate Application">Candidate Application</option>
                                    <option value="Technical Issue">Technical Issue</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Message</label>
                                <textarea name="message" class="form-control" rows="5" required></textarea>
                            </div>
                            <div class="col-12 d-grid d-md-flex justify-content-md-end">
                                <button type="submit" class="btn btn-primary px-4">Send Message</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>

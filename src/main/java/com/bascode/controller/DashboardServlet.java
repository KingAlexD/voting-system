package com.bascode.controller;

import java.io.IOException;
import java.util.Optional;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.UserRepository;
import com.bascode.repository.VoteRepository;
import com.bascode.util.AppConfigUtil;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final VoteRepository voteRepository = new VoteRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepository);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            request.setAttribute("currentUser", currentUser);
            request.setAttribute("approvedContesters", contesterRepository.findApproved(em));
            Map<Long, Long> voteCounts = voteRepository.voteCountByContester(em);
            request.setAttribute("voteCounts", voteCounts);
            request.setAttribute("hasVoted", voteRepository.hasUserVoted(em, currentUser.getId()));
            int age = LocalDate.now().getYear() - currentUser.getBirthYear();
            request.setAttribute("isAdult", age >= 18);
            LocalDate deadline = AppConfigUtil.getVotingDeadline(getServletContext());
            request.setAttribute("votingDeadline", deadline);
            request.setAttribute("votingClosed", LocalDate.now().isAfter(deadline));
            request.setAttribute("electionPhase", AppConfigUtil.getElectionPhase(getServletContext()).name());
            long totalVotes = 0L;
            for (Long count : voteCounts.values()) {
                totalVotes += count;
            }
            request.setAttribute("totalVotes", totalVotes);
            Optional<Contester> application = contesterRepository.findByUserId(em, currentUser.getId());
            request.setAttribute("myContesterApplication", application.orElse(null));
            request.setAttribute("positions", com.bascode.model.enums.Position.values());
            request.getRequestDispatcher("/WEB-INF/views/voter/dashboard.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }
}

package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.entity.Vote;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.NotificationRepository;
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
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/vote")
public class VoteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final VoteRepository voteRepository = new VoteRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contesterIdParam = request.getParameter("contesterId");
        if (contesterIdParam == null || contesterIdParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/dashboard?error=no_selection");
            return;
        }

        Long contesterId;
        try {
            contesterId = Long.valueOf(contesterIdParam);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/dashboard?error=invalid_contester");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            if (!AppConfigUtil.isElectionOpen(getServletContext())) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=election_not_open");
                return;
            }
            LocalDate votingDeadline = AppConfigUtil.getVotingDeadline(getServletContext());
            if (LocalDate.now().isAfter(votingDeadline)) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=voting_closed");
                return;
            }
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepository);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }
            int age = LocalDate.now().getYear() - currentUser.getBirthYear();
            if (age < 18) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=underage");
                return;
            }
            if (voteRepository.hasUserVoted(em, currentUser.getId())) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=already_voted");
                return;
            }

            Contester contester = contesterRepository.findById(em, contesterId).orElse(null);
            if (contester == null || contester.getStatus() != com.bascode.model.enums.ContesterStatus.APPROVED) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=contester_unavailable");
                return;
            }

            em.getTransaction().begin();
            Vote vote = new Vote();
            vote.setVoter(currentUser);
            vote.setContester(contester);
            voteRepository.save(em, vote);
            notificationRepository.create(em, currentUser, "Vote Recorded",
                    "Your vote for " + contester.getUser().getFirstName() + " " + contester.getUser().getLastName()
                            + " has been recorded.",
                    "/dashboard");
            em.getTransaction().commit();
            response.sendRedirect(request.getContextPath() + "/vote-success.jsp");
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }
}

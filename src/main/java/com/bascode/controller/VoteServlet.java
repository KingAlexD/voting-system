package com.bascode.controller;

import java.io.IOException;
import java.time.LocalDate;
import com.bascode.util.CsrfUtil;
import jakarta.servlet.http.HttpSession;

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

@WebServlet("/vote")
public class VoteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final VoteRepository voteRepository = new VoteRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        
        try {
            // **✅ FIXED CSRF - COMPARE DIRECTLY (don't call getToken()!)**
            String submittedToken = request.getParameter(CsrfUtil.PARAM);
            HttpSession session = request.getSession(false);
            if (submittedToken == null || session == null) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=csrf_invalid");
                return;
            }
            String sessionToken = (String) session.getAttribute(CsrfUtil.SESSION_KEY);
            if (sessionToken == null || !submittedToken.equals(sessionToken)) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=csrf_invalid");
                return;
            }

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

            // Election checks
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

            Contester contester = contesterRepository.findById(em, contesterId).orElse(null);
            if (contester == null || contester.getStatus() != com.bascode.model.enums.ContesterStatus.APPROVED) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=contester_unavailable");
                return;
            }

          
            if (voteRepository.hasUserVotedForPosition(em, currentUser.getId(), contester.getPosition())) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=already_voted_position");
                return;
            }

        
            em.getTransaction().begin();
            Vote vote = new Vote();
            vote.setVoter(currentUser);
            vote.setContester(contester);
            vote.setContesterPosition(contester.getPosition());
            voteRepository.save(em, vote);
            
            notificationRepository.create(em, currentUser, "Vote Recorded",
                    "Your vote for " + contester.getUser().getFirstName() + " " + contester.getUser().getLastName() +
                    " (" + contester.getPosition() + ") has been recorded.", "/dashboard");
            
            em.getTransaction().commit();
            
            request.getSession().setAttribute("success", 
                "Vote recorded for " + contester.getPosition() + ". No take-backs 😈");
            response.sendRedirect(request.getContextPath() + "/dashboard");
            
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            ex.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard?error=server_error");
        } finally {
            em.close();
        }
    }
}
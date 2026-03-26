package com.bascode.controller;

import java.io.IOException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import jakarta.servlet.http.HttpSession;
import com.bascode.util.CsrfUtil;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.entity.Vote;
import com.bascode.model.enums.Position;
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

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final VoteRepository voteRepository = new VoteRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepository);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            request.setAttribute("currentUser", currentUser);
            List<Contester> approvedContesters = contesterRepository.findApproved(em);
            request.setAttribute("approvedContesters", approvedContesters);

            Map<Long, Long> voteCounts = voteRepository.voteCountByContester(em);
            request.setAttribute("voteCounts", voteCounts);

            // **POSITION-SPECIFIC VOTING STATUS**
            Map<Position, Boolean> userVotesByPosition = new HashMap<>();
            Map<Position, Vote> userVotes = new HashMap<>();
            boolean hasVotedAny = false;
            
            for (Position pos : Position.values()) {
                Optional<Vote> vote = voteRepository.findByVoterIdAndPosition(em, currentUser.getId(), pos);
                boolean hasVotedPos = vote.isPresent();
                userVotesByPosition.put(pos, hasVotedPos);
                if (hasVotedPos) {
                    userVotes.put(pos, vote.get());
                    hasVotedAny = true;
                }
            }
            
            request.setAttribute("hasVoted", hasVotedAny);
            request.setAttribute("userVotesByPosition", userVotesByPosition);
            request.setAttribute("userVotes", userVotes);

            // **CONTESTERS BY POSITION**
            Map<Position, List<Contester>> contestersByPosition = new HashMap<>();
            for (Position pos : Position.values()) {
                List<Contester> positionContesters = approvedContesters.stream()
                    .filter(c -> c.getPosition() == pos)
                    .collect(Collectors.toList());
                contestersByPosition.put(pos, positionContesters);
            }
            request.setAttribute("contestersByPosition", contestersByPosition);

            int age = LocalDate.now().getYear() - currentUser.getBirthYear();
            request.setAttribute("isAdult", age >= 18);

            LocalDate deadline = AppConfigUtil.getVotingDeadline(getServletContext());
            request.setAttribute("votingDeadline", deadline);
            request.setAttribute("votingClosed", LocalDate.now().isAfter(deadline));
            request.setAttribute("electionPhase", AppConfigUtil.getElectionPhase(getServletContext()).name());

            long totalVotes = 0L;
            for (Long count : voteCounts.values()) totalVotes += count;
            request.setAttribute("totalVotes", totalVotes);

            Optional<Contester> application = contesterRepository.findByUserId(em, currentUser.getId());
            request.setAttribute("myContesterApplication", application.orElse(null));
            request.setAttribute("positions", Position.values());
            HttpSession session = request.getSession(true);
            request.setAttribute("csrfToken", CsrfUtil.getToken(session));
            request.getRequestDispatcher("/WEB-INF/views/voter/dashboard.jsp").forward(request, response);

        } finally {
            em.close();
        }
    }
}
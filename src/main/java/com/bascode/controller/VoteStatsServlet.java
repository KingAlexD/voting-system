package com.bascode.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.bascode.model.entity.Contester;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.VoteRepository;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


@WebServlet("/api/vote-stats")
public class VoteStatsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final VoteRepository voteRepository = new VoteRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        if (ServletUtil.getSessionUserId(request) == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            List<Contester> approved = contesterRepository.findApproved(em);
            Map<Long, Long> voteCounts = voteRepository.voteCountByContester(em);

            StringBuilder json = new StringBuilder("{\"labels\":[");
            StringBuilder votes = new StringBuilder("],\"votes\":[");

            for (int i = 0; i < approved.size(); i++) {
                Contester c = approved.get(i);
                String name = c.getUser().getFirstName() + " " + c.getUser().getLastName()
                        + " (" + c.getPosition() + ")";
                long count = voteCounts.getOrDefault(c.getId(), 0L);
                if (i > 0) {
                    json.append(",");
                    votes.append(",");
                }
                json.append("\"").append(escapeJson(name)).append("\"");
                votes.append(count);
            }

            json.append(votes).append("]}");

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setHeader("Cache-Control", "no-store");
            response.getWriter().write(json.toString());
        } finally {
            em.close();
        }
    }

    private String escapeJson(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}

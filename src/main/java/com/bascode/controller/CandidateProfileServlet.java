package com.bascode.controller;

import java.io.IOException;
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

@WebServlet("/candidate-profile")
public class CandidateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final VoteRepository voteRepository = new VoteRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Long id;
        try {
            id = Long.valueOf(request.getParameter("id"));
        } catch (Exception ex) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            Contester contester = contesterRepository.findById(em, id).orElse(null);
            if (contester == null) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
            Map<Long, Long> voteCounts = voteRepository.voteCountByContester(em);
            request.setAttribute("contester", contester);
            request.setAttribute("votes", voteCounts.getOrDefault(contester.getId(), 0L));
            request.getRequestDispatcher("/WEB-INF/views/voter/candidate-profile.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }
}

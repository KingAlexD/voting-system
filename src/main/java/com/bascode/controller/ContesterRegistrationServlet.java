package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.NotificationRepository;
import com.bascode.repository.UserRepository;
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

@WebServlet("/contester/apply")
public class ContesterRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String positionParam = request.getParameter("position");
        String manifesto = request.getParameter("manifesto");
        if (positionParam == null || positionParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/dashboard?error=invalid_position");
            return;
        }
        if (manifesto == null || manifesto.trim().length() < 20) {
            response.sendRedirect(request.getContextPath() + "/dashboard?error=manifesto_required");
            return;
        }

        Position position;
        try {
            position = Position.valueOf(positionParam);
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/dashboard?error=invalid_position");
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

            if (contesterRepository.findByUserId(em, currentUser.getId()).isPresent()) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=application_exists");
                return;
            }

            long approvedCount = contesterRepository.countApprovedByPosition(em, position);
            if (approvedCount >= 3) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=position_full");
                return;
            }
            

            em.getTransaction().begin();
            Contester contester = new Contester();
            contester.setUser(currentUser);
            contester.setPosition(position);
            contester.setStatus(ContesterStatus.PENDING);
            contester.setManifesto(manifesto.trim());
            contesterRepository.save(em, contester);
            notificationRepository.create(em, currentUser, "Contester Application Submitted",
                    "Your application for " + position + " has been submitted and is pending admin review.",
                    "/dashboard");
            em.getTransaction().commit();
            response.sendRedirect(request.getContextPath() + "/dashboard?status=application_submitted");
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

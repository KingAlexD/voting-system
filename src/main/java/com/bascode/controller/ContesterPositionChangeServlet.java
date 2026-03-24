package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.NotificationRepository;
import com.bascode.repository.UserRepository;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/contester/request-position-change")
public class ContesterPositionChangeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String positionParam = request.getParameter("requestedPosition");
        if (positionParam == null || positionParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/dashboard?error=invalid_position");
            return;
        }

        Position newPosition;
        try {
            newPosition = Position.valueOf(positionParam);
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/dashboard?error=invalid_position");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepository);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            Contester contester = contesterRepository.findByUserId(em, currentUser.getId()).orElse(null);
            if (contester == null || contester.getStatus() != ContesterStatus.APPROVED) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=not_approved_contester");
                return;
            }

            if (newPosition == contester.getPosition()) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=same_position");
                return;
            }

            if (contester.getRequestedPosition() != null) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=change_already_pending");
                return;
            }

           
            long approvedCount = contesterRepository.countApprovedByPosition(em, newPosition);
            if (approvedCount >= 3) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=position_full");
                return;
            }

            em.getTransaction().begin();
            contester.setRequestedPosition(newPosition);
            contesterRepository.update(em, contester);

                       notificationRepository.create(em, currentUser, "Position Change Requested",
                    "Your request to change position to " + newPosition + " has been submitted and is pending admin approval.",
                    "/dashboard");
            em.getTransaction().commit();

            response.sendRedirect(request.getContextPath() + "/dashboard?status=position_change_requested");
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }
    }
}

package com.bascode.util;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;
import com.bascode.repository.UserRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;


@WebListener
public class JPAInitializer implements ServletContextListener {
    private static EntityManagerFactory emf;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        emf = Persistence.createEntityManagerFactory("VotingPU");
        seedDefaultAdmin();
        sce.getServletContext().setAttribute("emf", emf);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (emf != null && emf.isOpen()) {
            emf.close(); 
        }
    }

    private void seedDefaultAdmin() {
        EntityManager em = emf.createEntityManager();
        UserRepository userRepository = new UserRepository();
        try {
            if (userRepository.findByEmail(em, "admin@votely.local").isPresent()) {
                return;
            }
            em.getTransaction().begin();
            User admin = new User();
            admin.setFirstName("System");
            admin.setLastName("Admin");
            admin.setEmail("admin@votely.local");
            admin.setPasswordHash(SecurityUtil.hashPassword("Admin@123"));
            admin.setBirthYear(1990);
            admin.setState("N/A");
            admin.setCountry("N/A");
            admin.setRole(Role.ADMIN);
            admin.setEmailVerified(true);
            admin.setVerificationCode(null);
            userRepository.save(em, admin);
            em.getTransaction().commit();
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

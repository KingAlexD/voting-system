package com.bascode.util;

import com.bascode.model.entity.User;
import com.bascode.repository.UserRepository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class ServletUtil {

    private ServletUtil() {
    }

    public static EntityManagerFactory getEntityManagerFactory(ServletContext context) {
        return (EntityManagerFactory) context.getAttribute("emf");
    }

    public static Long getSessionUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object id = session == null ? null : session.getAttribute("userId");
        return id instanceof Long ? (Long) id : null;
    }

    public static User getCurrentUser(HttpServletRequest request, EntityManager em, UserRepository userRepository) {
        Long userId = getSessionUserId(request);
        if (userId == null) {
            return null;
        }
        return userRepository.findById(em, userId).orElse(null);
    }
}

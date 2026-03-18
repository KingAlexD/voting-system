package com.bascode.repository;

import java.time.LocalDateTime;
import java.util.List;

import com.bascode.model.entity.Notification;
import com.bascode.model.entity.User;

import jakarta.persistence.EntityManager;

public class NotificationRepository {

    public void create(EntityManager em, User user, String title, String message, String link) {
        Notification notification = new Notification();
        notification.setUser(user);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setLink(link);
        notification.setRead(false);
        notification.setCreatedAt(LocalDateTime.now());
        em.persist(notification);
    }

    public long countUnread(EntityManager em, Long userId) {
        return em.createQuery(
                "select count(n.id) from Notification n where n.user.id = :userId and n.read = false",
                Long.class)
                .setParameter("userId", userId)
                .getSingleResult();
    }

    public List<Notification> findRecentByUser(EntityManager em, Long userId, int limit) {
        return em.createQuery(
                "select n from Notification n where n.user.id = :userId order by n.createdAt desc",
                Notification.class)
                .setParameter("userId", userId)
                .setMaxResults(limit)
                .getResultList();
    }

    public int markAllAsRead(EntityManager em, Long userId) {
        return em.createQuery(
                "update Notification n set n.read = true where n.user.id = :userId and n.read = false")
                .setParameter("userId", userId)
                .executeUpdate();
    }

    /**
     * Marks a single notification as read, but only if it belongs to the given user.
     * This prevents users from marking other people's notifications as read.
     */
    public int markOneAsRead(EntityManager em, Long notificationId, Long userId) {
        return em.createQuery(
                "update Notification n set n.read = true where n.id = :id and n.user.id = :userId and n.read = false")
                .setParameter("id", notificationId)
                .setParameter("userId", userId)
                .executeUpdate();
    }
}

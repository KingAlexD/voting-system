package com.bascode.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import com.bascode.model.entity.PasswordResetToken;

import jakarta.persistence.EntityManager;

public class PasswordResetTokenRepository {

    public void save(EntityManager em, PasswordResetToken token) {
        em.persist(token);
    }

    public PasswordResetToken update(EntityManager em, PasswordResetToken token) {
        return em.merge(token);
    }

    public Optional<PasswordResetToken> findActiveByToken(EntityManager em, String tokenValue) {
        List<PasswordResetToken> results = em
                .createQuery(
                        "select t from PasswordResetToken t join fetch t.user where t.token = :token and t.used = false and t.expiresAt > :now",
                        PasswordResetToken.class)
                .setParameter("token", tokenValue).setParameter("now", LocalDateTime.now()).getResultList();
        return results.stream().findFirst();
    }

    public int invalidateUserTokens(EntityManager em, Long userId) {
        return em.createQuery("update PasswordResetToken t set t.used = true where t.user.id = :userId and t.used = false")
                .setParameter("userId", userId).executeUpdate();
    }
}

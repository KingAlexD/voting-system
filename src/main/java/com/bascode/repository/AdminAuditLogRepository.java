package com.bascode.repository;

import java.util.List;

import com.bascode.model.entity.AdminAuditLog;
import com.bascode.model.entity.User;

import jakarta.persistence.EntityManager;

public class AdminAuditLogRepository {

    public void log(EntityManager em, User adminUser, String actionType, String actionDetail) {
        AdminAuditLog log = new AdminAuditLog();
        log.setAdminUser(adminUser);
        log.setActionType(actionType);
        log.setActionDetail(actionDetail);
        log.setCreatedAt(java.time.LocalDateTime.now());
        em.persist(log);
    }

    public List<AdminAuditLog> findRecent(EntityManager em, int limit) {
        return em.createQuery("select l from AdminAuditLog l join fetch l.adminUser order by l.createdAt desc",
                AdminAuditLog.class).setMaxResults(limit).getResultList();
    }
}

package com.bascode.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import com.bascode.model.entity.ContactMessage;
import com.bascode.model.entity.User;
import jakarta.persistence.EntityManager;

public class ContactMessageRepository {

    public void save(EntityManager em, ContactMessage msg) {
        em.persist(msg);
    }

    public Optional<ContactMessage> findById(EntityManager em, Long id) {
        return Optional.ofNullable(em.find(ContactMessage.class, id));
    }


    public List<ContactMessage> findAllIncoming(EntityManager em) {
        return em.createQuery(
            "select m from ContactMessage m left join fetch m.sender " +
            "where m.fromAdmin = false order by m.createdAt desc",
            ContactMessage.class).getResultList();
    }

    /** Thread: original message + all its replies */
    public List<ContactMessage> findThread(EntityManager em, Long parentId) {
        return em.createQuery(
            "select m from ContactMessage m where m.parent.id = :pid order by m.createdAt asc",
            ContactMessage.class).setParameter("pid", parentId).getResultList();
    }

    /** Messages sent BY a specific user to admin (top-level only, not replies) */
    public List<ContactMessage> findByUser(EntityManager em, Long userId) {
        return em.createQuery(
            "select m from ContactMessage m left join fetch m.recipient " +
            "where (m.sender.id = :uid and m.fromAdmin = false) " +
            "or (m.fromAdmin = true and m.recipient.id = :uid) " +
            "order by m.createdAt desc",
            ContactMessage.class).setParameter("uid", userId).getResultList();
    }

    /** Count unread admin replies for a user (fromAdmin=true, userRead=false) */
    public long countUnreadForUser(EntityManager em, Long userId) {
        return em.createQuery(
            "select count(m.id) from ContactMessage m " +
            "where m.fromAdmin = true and m.recipient.id = :uid and m.userRead = false",
            Long.class).setParameter("uid", userId).getSingleResult();
    }

    /** Count unread incoming messages for admin (fromAdmin=false, adminRead=false) */
    public long countUnreadForAdmin(EntityManager em) {
        return em.createQuery(
            "select count(m.id) from ContactMessage m " +
            "where m.fromAdmin = false and m.adminRead = false",
            Long.class).getSingleResult();
    }

    public int markUserRead(EntityManager em, Long messageId, Long userId) {
        return em.createQuery(
            "update ContactMessage m set m.userRead = true " +
            "where m.id = :id and m.recipient.id = :uid and m.userRead = false")
            .setParameter("id", messageId).setParameter("uid", userId).executeUpdate();
    }

    public int markAdminRead(EntityManager em, Long messageId) {
        return em.createQuery(
            "update ContactMessage m set m.adminRead = true where m.id = :id and m.adminRead = false")
            .setParameter("id", messageId).executeUpdate();
    }

    /** Search incoming messages by sender name or email */
    public List<ContactMessage> searchIncoming(EntityManager em, String query) {
        String q = "%" + query.toLowerCase() + "%";
        return em.createQuery(
            "select m from ContactMessage m left join fetch m.sender " +
            "where m.fromAdmin = false and " +
            "(lower(m.senderName) like :q or lower(m.senderEmail) like :q or lower(m.subject) like :q) " +
            "order by m.createdAt desc",
            ContactMessage.class).setParameter("q", q).getResultList();
    }

    public ContactMessage build(User sender, String name, String email,
                                 String subject, String body,
                                 boolean fromAdmin, User recipient,
                                 ContactMessage parent) {
        ContactMessage m = new ContactMessage();
        m.setSender(sender);
        m.setSenderName(name);
        m.setSenderEmail(email);
        m.setSubject(subject);
        m.setBody(body);
        m.setFromAdmin(fromAdmin);
        m.setRecipient(recipient);
        m.setParent(parent);
        m.setCreatedAt(LocalDateTime.now());
        return m;
    }
}
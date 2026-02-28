package com.bascode.repository;

import java.util.List;
import java.util.Optional;

import com.bascode.model.entity.Contester;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

public class ContesterRepository {

    public void save(EntityManager em, Contester contester) {
        em.persist(contester);
    }

    public Contester update(EntityManager em, Contester contester) {
        return em.merge(contester);
    }

    public Optional<Contester> findById(EntityManager em, Long id) {
        return Optional.ofNullable(em.find(Contester.class, id));
    }

    public Optional<Contester> findByUserId(EntityManager em, Long userId) {
        TypedQuery<Contester> query = em.createQuery("select c from Contester c where c.user.id = :userId", Contester.class);
        query.setParameter("userId", userId);
        return query.getResultList().stream().findFirst();
    }

    public long countApprovedByPosition(EntityManager em, Position position) {
        return em.createQuery("select count(c.id) from Contester c where c.position = :position and c.status = :status",
                Long.class).setParameter("position", position).setParameter("status", ContesterStatus.APPROVED)
                .getSingleResult();
    }

    public List<Contester> findApproved(EntityManager em) {
        return em.createQuery("select c from Contester c join fetch c.user where c.status = :status order by c.position",
                Contester.class).setParameter("status", ContesterStatus.APPROVED).getResultList();
    }

    public List<Contester> findPending(EntityManager em) {
        return em.createQuery("select c from Contester c join fetch c.user where c.status = :status order by c.id desc",
                Contester.class).setParameter("status", ContesterStatus.PENDING).getResultList();
    }

    public List<Contester> findAll(EntityManager em) {
        return em.createQuery("select c from Contester c join fetch c.user order by c.id desc", Contester.class)
                .getResultList();
    }
}

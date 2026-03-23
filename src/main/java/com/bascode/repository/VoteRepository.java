package com.bascode.repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.bascode.model.entity.Vote;

import jakarta.persistence.EntityManager;

public class VoteRepository {

    public boolean hasUserVoted(EntityManager em, Long userId) {
        Long count = em.createQuery("select count(v.id) from Vote v where v.voter.id = :userId", Long.class)
                .setParameter("userId", userId).getSingleResult();
        return count != null && count > 0;
    }

    public void save(EntityManager em, Vote vote) {
        em.persist(vote);
    }

    public Map<Long, Long> voteCountByContester(EntityManager em) {
        List<Object[]> rows = em.createQuery("select v.contester.id, count(v.id) from Vote v group by v.contester.id",
                Object[].class).getResultList();
        Map<Long, Long> counts = new HashMap<>();
        for (Object[] row : rows) {
            counts.put((Long) row[0], (Long) row[1]);
        }
        return counts;
    }

    public List<Vote> findAll(EntityManager em) {
        return em.createQuery("select v from Vote v join fetch v.voter join fetch v.contester c join fetch c.user order by v.id desc",
                Vote.class).getResultList();
    }
}

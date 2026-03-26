package com.bascode.repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import com.bascode.model.entity.Vote;
import com.bascode.model.enums.Position;

import jakarta.persistence.EntityManager;

public class VoteRepository {

    public void save(EntityManager em, Vote vote) {
        em.persist(vote);
    }

    public boolean hasUserVoted(EntityManager em, Long userId) {
        Long count = em.createQuery(
                "select count(v.id) from Vote v where v.voter.id = :userId", Long.class)
                .setParameter("userId", userId)
                .getSingleResult();
        return count > 0;
    }

    public Optional<Vote> findByVoterId(EntityManager em, Long userId) {
        return em.createQuery(
                "select v from Vote v join fetch v.contester c join fetch c.user where v.voter.id = :userId",
                Vote.class)
                .setParameter("userId", userId)
                .getResultList()
                .stream()
                .findFirst();
    }

    public List<Vote> findAll(EntityManager em) {
        return em.createQuery(
                "select v from Vote v join fetch v.voter join fetch v.contester c join fetch c.user order by v.id desc",
                Vote.class).getResultList();
    }

    public Map<Long, Long> voteCountByContester(EntityManager em) {
        List<Object[]> rows = em.createQuery(
                "select v.contester.id, count(v.id) from Vote v group by v.contester.id",
                Object[].class).getResultList();
        return rows.stream().collect(Collectors.toMap(
                r -> (Long) r[0],
                r -> (Long) r[1]));
    }
    public int deleteVotesByContesterId(EntityManager em, Long contesterId) {
        return em.createQuery(
                "delete from Vote v where v.contester.id = :cid")
              .setParameter("cid", contesterId)
                .executeUpdate();
    }
    public Map<Position, Boolean> userVotesByPosition(EntityManager em, Long userId) {
        List<Vote> votes = em.createQuery(
            "select v from Vote v join v.contester c where v.voter.id = :uid", Vote.class
        ).setParameter("uid", userId).getResultList();

        return votes.stream().collect(
            Collectors.toMap(v -> v.getContester().getPosition(), v -> true)
        );
    
    }

    public boolean hasUserVotedForPosition(EntityManager em, Long userId, Position position) {
        Long count = em.createQuery(
                "select count(v.id) from Vote v where v.voter.id = :userId and v.contester.position = :position", 
                Long.class)
                .setParameter("userId", userId)
                .setParameter("position", position)
                .getSingleResult();
        return count > 0;
    }

    public Optional<Vote> findByVoterIdAndPosition(EntityManager em, Long userId, Position position) {
        return em.createQuery(
                "select v from Vote v join fetch v.contester c join fetch c.user " +
                "where v.voter.id = :userId and c.position = :position",
                Vote.class)
                .setParameter("userId", userId)
                .setParameter("position", position)
                .getResultList()
                .stream()
                .findFirst();
    }


}

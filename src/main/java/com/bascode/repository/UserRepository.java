package com.bascode.repository;

import java.util.List;
import java.util.Optional;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

public class UserRepository {

    public Optional<User> findByEmail(EntityManager em, String email) {
        TypedQuery<User> query = em.createQuery("select u from User u where lower(u.email) = :email", User.class);
        query.setParameter("email", email.toLowerCase());
        List<User> results = query.getResultList();
        return results.stream().findFirst();
    }

    public Optional<User> findById(EntityManager em, Long id) {
        return Optional.ofNullable(em.find(User.class, id));
    }

    public void save(EntityManager em, User user) {
        em.persist(user);
    }

    public User update(EntityManager em, User user) {
        return em.merge(user);
    }

    public List<User> findAllVotersAndContesters(EntityManager em) {
        return em.createQuery("select u from User u where u.role <> :role order by u.id desc", User.class)
                .setParameter("role", Role.ADMIN).getResultList();
    }
    public List<User> findAllAdmins(EntityManager em) {
        return em.createQuery(
            "select u from User u where u.role = com.bascode.model.enums.Role.ADMIN",
            User.class).getResultList();
    }
}

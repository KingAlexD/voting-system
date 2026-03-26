package com.bascode.model.entity;

import com.bascode.model.enums.Position;
import jakarta.persistence.*;

@Entity
@Table(name = "votes", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"voter_id", "contester_position"}))
public class Vote {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne 
    @JoinColumn(name = "voter_id", nullable = false)
    private User voter;

    @ManyToOne
    @JoinColumn(name = "contester_id")
    private Contester contester;

    // **KEEP ONLY ONE - the @Column field**
    @Enumerated(EnumType.STRING)
    @Column(name = "contester_position", insertable = false, updatable = false)
    private Position contesterPosition;

    // **REMOVE THIS DUPLICATE:**
    // @Enumerated(EnumType.STRING)
    // @Column(name = "contester_position", insertable = false, updatable = false)
    // private Position contesterPosition;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getVoter() { return voter; }
    public void setVoter(User voter) { this.voter = voter; }

    public Contester getContester() { return contester; }
    public void setContester(Contester contester) { this.contester = contester; }

    public Position getContesterPosition() {
        return contesterPosition != null ? contesterPosition : 
               (contester != null ? contester.getPosition() : null);
    }
    
    public void setContesterPosition(Position position) {
        this.contesterPosition = position;
    }
}
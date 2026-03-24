package com.bascode.model.entity;

import com.bascode.model.enums.Position;
import jakarta.persistence.*;

@Entity
@Table(
    name = "votes",
    uniqueConstraints = @UniqueConstraint(columnNames = {"voter_id", "position"})
)
public class Vote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Use OneToOne if a user can only cast one vote total across the system
    // Use ManyToOne if they can vote for multiple positions
    @ManyToOne 
    @JoinColumn(name = "voter_id", nullable = false)
    private User voter;

    @ManyToOne
    @JoinColumn(name = "contester_id")
    private Contester contester;

    // FIX: Map the Enum as a String column, not a relationship
    @Enumerated(EnumType.STRING)
    @Column(name = "position", length = 50, nullable = false)
    private Position position;

    // --- Getters and Setters ---

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getVoter() { return voter; }
    public void setVoter(User voter) { this.voter = voter; }

    public Contester getContester() { return contester; }
    public void setContester(Contester contester) { this.contester = contester; }

    public Position getPosition() { return position; }
    public void setPosition(Position position) { this.position = position; }
}

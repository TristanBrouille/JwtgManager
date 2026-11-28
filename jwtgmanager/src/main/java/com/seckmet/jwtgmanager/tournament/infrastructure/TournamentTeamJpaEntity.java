package com.seckmet.jwtgmanager.tournament.infrastructure;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Embeddable;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OrderBy;
import jakarta.persistence.Table;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "tournament_team")
public class TournamentTeamJpaEntity {

    /** Un dino du trio ; slot 1 et 2 pour la paire, 3 pour le dino seul. */
    @Embeddable
    public record Member(@Column(name = "slot") short slot,
                         @Column(name = "species_id") int speciesId,
                         @Column(name = "level") short level,
                         @Column(name = "health") int health,
                         @Column(name = "attack") int attack,
                         @Column(name = "ferocity") int ferocity,
                         @Column(name = "profile") String profile) {
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "user_id", nullable = false)
    private UUID userId;
    @Column(nullable = false)
    private String tournament;
    @Column(nullable = false)
    private String league;
    @Column(nullable = false)
    private short rank;
    @Column(name = "pair_class", nullable = false)
    private String pairClass;
    @Column(name = "single_class", nullable = false)
    private String singleClass;
    @Column(name = "total_ferocity", nullable = false)
    private int totalFerocity;
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "tournament_team_member", joinColumns = @JoinColumn(name = "team_id"))
    @OrderBy("slot")
    private List<Member> members = new ArrayList<>();

    protected TournamentTeamJpaEntity() {
    }

    TournamentTeamJpaEntity(UUID userId, String tournament, String league, short rank, String pairClass,
                            String singleClass, int totalFerocity, List<Member> members) {
        this.userId = userId;
        this.tournament = tournament;
        this.league = league;
        this.rank = rank;
        this.pairClass = pairClass;
        this.singleClass = singleClass;
        this.totalFerocity = totalFerocity;
        this.members = new ArrayList<>(members);
    }

    public Long getId() { return id; }
    public UUID getUserId() { return userId; }
    public String getTournament() { return tournament; }
    public String getLeague() { return league; }
    public short getRank() { return rank; }
    public String getPairClass() { return pairClass; }
    public String getSingleClass() { return singleClass; }
    public int getTotalFerocity() { return totalFerocity; }
    public List<Member> getMembers() { return members; }
}

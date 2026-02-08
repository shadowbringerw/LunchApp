package com.kunlunlunch.decision;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "decision_records")
public class DecisionRecordEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, length = 200)
  private String choice;

  @Column(nullable = false)
  private Instant decidedAt;

  protected DecisionRecordEntity() {}

  public DecisionRecordEntity(String choice, Instant decidedAt) {
    this.choice = choice;
    this.decidedAt = decidedAt;
  }

  public Long getId() {
    return id;
  }

  public String getChoice() {
    return choice;
  }

  public Instant getDecidedAt() {
    return decidedAt;
  }
}


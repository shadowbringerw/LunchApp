package com.kunlunlunch.decision;

import java.util.List;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DecisionRecordRepository extends JpaRepository<DecisionRecordEntity, Long> {

  List<DecisionRecordEntity> findAllByOrderByDecidedAtDesc(Pageable pageable);
}


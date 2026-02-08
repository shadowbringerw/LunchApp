package com.kunlunlunch.decision;

import java.time.Instant;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DecisionService {

  private final DecisionRecordRepository repository;
  private final Random random;

  public DecisionService(DecisionRecordRepository repository) {
    this.repository = repository;
    this.random = new Random();
  }

  @Transactional
  public DecideResult decide(List<String> rawOptions) {
    final List<String> options = rawOptions.stream()
        .map(String::trim)
        .filter(s -> !s.isEmpty())
        .distinct()
        .toList();
    if (options.isEmpty()) {
      throw new IllegalArgumentException("options must not be empty");
    }

    final List<DecisionRecordEntity> last3 = repository.findAllByOrderByDecidedAtDesc(PageRequest.of(0, 3));
    final List<String> recent3 = last3.stream().map(DecisionRecordEntity::getChoice).toList();
    final Set<String> penalized = repeatedChoices(recent3);
    final String choice = weightedPick(options, penalized);

    final DecisionRecordEntity saved = repository.save(new DecisionRecordEntity(choice, Instant.now()));
    return new DecideResult(saved, recent3, penalized);
  }

  @Transactional(readOnly = true)
  public List<DecisionRecordEntity> history(int limit) {
    final int safeLimit = Math.max(1, Math.min(limit, 2000));
    return repository.findAllByOrderByDecidedAtDesc(PageRequest.of(0, safeLimit));
  }

  @Transactional
  public void clearHistory() {
    repository.deleteAllInBatch();
  }

  private String weightedPick(List<String> options, Set<String> penalizedChoices) {
    double total = 0;
    final double[] weights = new double[options.size()];
    for (int i = 0; i < options.size(); i++) {
      final String option = options.get(i);
      final double w = penalizedChoices.contains(option) ? 0.5 : 1.0;
      weights[i] = w;
      total += w;
    }
    if (total <= 0) {
      return options.get(random.nextInt(options.size()));
    }
    double r = random.nextDouble() * total;
    for (int i = 0; i < options.size(); i++) {
      r -= weights[i];
      if (r <= 0) {
        return options.get(i);
      }
    }
    return options.get(options.size() - 1);
  }

  private static Set<String> repeatedChoices(List<String> recent3) {
    final HashMap<String, Integer> counts = new HashMap<>();
    for (final String c : recent3) {
      counts.put(c, counts.getOrDefault(c, 0) + 1);
    }
    final HashSet<String> repeated = new HashSet<>();
    for (final var e : counts.entrySet()) {
      if (e.getValue() >= 2) {
        repeated.add(e.getKey());
      }
    }
    return repeated;
  }

  public record DecideResult(DecisionRecordEntity savedRecord, List<String> recent3, Set<String> penalizedChoices) {}
}


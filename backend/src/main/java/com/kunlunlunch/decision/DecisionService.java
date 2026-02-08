package com.kunlunlunch.decision;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
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

    final ZoneId zoneId = ZoneId.systemDefault();
    final List<DecisionRecordEntity> recentRecords =
        repository.findAllByOrderByDecidedAtDesc(PageRequest.of(0, 200));
    final List<String> recent3DaysBefore = recentChoicesByDay(recentRecords, 3, zoneId);
    final Set<String> penalized = repeatedChoices(recent3DaysBefore);
    final String choice = weightedPick(options, penalized);

    final DecisionRecordEntity saved = repository.save(new DecisionRecordEntity(choice, Instant.now()));
    final ArrayList<DecisionRecordEntity> afterRecords = new ArrayList<>(recentRecords.size() + 1);
    afterRecords.add(saved);
    afterRecords.addAll(recentRecords);
    final List<String> recent3DaysAfter = recentChoicesByDay(afterRecords, 3, zoneId);
    return new DecideResult(saved, recent3DaysBefore, recent3DaysAfter, penalized);
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

  @Transactional
  public void resetHistoryToDemo() {
    repository.deleteAllInBatch();

    final ZoneId zoneId = ZoneId.systemDefault();
    final List<DecisionRecordEntity> demo = List.of(
        new DecisionRecordEntity("重庆小面", LocalDate.of(2026, 2, 5).atTime(LocalTime.NOON).atZone(zoneId).toInstant()),
        new DecisionRecordEntity("肯德基", LocalDate.of(2026, 2, 6).atTime(LocalTime.NOON).atZone(zoneId).toInstant()),
        new DecisionRecordEntity("卢布朗咖喱", LocalDate.of(2026, 2, 7).atTime(LocalTime.NOON).atZone(zoneId).toInstant())
    );
    repository.saveAll(demo);
  }

  @Transactional
  public void seedHistory(String choice, Instant decidedAt) {
    repository.save(new DecisionRecordEntity(choice, decidedAt));
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

  static List<String> recentChoicesByDay(
      List<DecisionRecordEntity> records,
      int days,
      ZoneId zoneId) {
    final int safeDays = Math.max(1, Math.min(days, 30));
    final LinkedHashMap<LocalDate, String> byDay = new LinkedHashMap<>();
    for (final DecisionRecordEntity r : records) {
      final LocalDate day = r.getDecidedAt().atZone(zoneId).toLocalDate();
      byDay.putIfAbsent(day, r.getChoice());
      if (byDay.size() >= safeDays) break;
    }
    return List.copyOf(byDay.values());
  }

  public record DecideResult(
      DecisionRecordEntity savedRecord,
      List<String> recent3DaysBefore,
      List<String> recent3DaysAfter,
      Set<String> penalizedChoices) {}
}

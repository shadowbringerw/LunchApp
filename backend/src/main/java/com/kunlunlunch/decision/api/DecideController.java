package com.kunlunlunch.decision.api;

import com.kunlunlunch.decision.DecisionRecordEntity;
import com.kunlunlunch.decision.DecisionService;
import com.kunlunlunch.decision.api.dto.DecideRequest;
import com.kunlunlunch.decision.api.dto.DecideResponse;
import com.kunlunlunch.decision.api.dto.HistoryItem;
import com.kunlunlunch.decision.api.dto.SeedHistoryRequest;
import jakarta.validation.Valid;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api")
public class DecideController {

  private static final Logger log = LoggerFactory.getLogger(DecideController.class);

  private final DecisionService decisionService;

  public DecideController(DecisionService decisionService) {
    this.decisionService = decisionService;
  }

  @PostMapping(value = "/decide", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
  public DecideResponse decide(@Valid @RequestBody DecideRequest request) {
    final var result = decisionService.decide(request.options());
    final DecisionRecordEntity saved = result.savedRecord();
    log.info(
        "DECIDE options={} recent3DaysBefore={} recent3DaysAfter={} penalized={} choice=\"{}\" at={}",
        request.options().size(),
        result.recent3DaysBefore(),
        result.recent3DaysAfter(),
        result.penalizedChoices(),
        saved.getChoice(),
        saved.getDecidedAt());

    return new DecideResponse(
        saved.getChoice(),
        saved.getDecidedAt().toEpochMilli(),
        result.recent3DaysAfter(),
        result.penalizedChoices(),
        result.recent3DaysBefore());
  }

  @GetMapping(value = "/history", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<HistoryItem> history(@RequestParam(name = "limit", defaultValue = "200") int limit) {
    final List<DecisionRecordEntity> items = decisionService.history(limit);
    log.info("HISTORY limit={} returned={}", limit, items.size());
    return items.stream()
        .map(e -> new HistoryItem(e.getChoice(), e.getDecidedAt().toEpochMilli()))
        .toList();
  }

  @DeleteMapping("/history")
  public void clearHistory() {
    decisionService.clearHistory();
    log.info("HISTORY cleared at={}", Instant.now());
  }

  @PostMapping("/history/demo")
  public void resetHistoryToDemo() {
    decisionService.resetHistoryToDemo();
    log.info("HISTORY demo reset at={}", Instant.now());
  }

  @PostMapping(value = "/history/seed", consumes = MediaType.APPLICATION_JSON_VALUE)
  public void seedHistory(@Valid @RequestBody SeedHistoryRequest request) {
    final ZoneId zoneId = ZoneId.systemDefault();
    final LocalDate date;
    try {
      date = LocalDate.parse(request.date());
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "invalid date: " + request.date(), e);
    }
    final Instant decidedAt = date.atTime(LocalTime.NOON).atZone(zoneId).toInstant();
    decisionService.seedHistory(request.choice().trim(), decidedAt);
    log.info("HISTORY seeded choice=\"{}\" date={} at={}", request.choice(), request.date(), decidedAt);
  }
}

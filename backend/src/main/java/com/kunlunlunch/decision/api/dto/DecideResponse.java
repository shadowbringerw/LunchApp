package com.kunlunlunch.decision.api.dto;

import java.util.List;
import java.util.Set;

public record DecideResponse(
    String choice,
    long timestampMs,
    List<String> recent3,
    Set<String> penalizedChoices,
    List<String> recent3DaysBefore) {}

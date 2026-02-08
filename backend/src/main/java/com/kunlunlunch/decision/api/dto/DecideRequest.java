package com.kunlunlunch.decision.api.dto;

import jakarta.validation.constraints.NotEmpty;
import java.util.List;

public record DecideRequest(@NotEmpty List<String> options) {}


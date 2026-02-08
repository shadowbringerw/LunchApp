package com.kunlunlunch.decision.api;

import static org.hamcrest.Matchers.hasKey;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class DecideControllerTest {

  @Autowired private MockMvc mvc;

  @Test
  void decide_then_history_should_work() throws Exception {
    mvc.perform(delete("/api/history")).andExpect(status().isOk());

    mvc.perform(
            post("/api/decide")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"options\":[\"A\",\"B\",\"C\"]}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.choice").exists())
        .andExpect(jsonPath("$.timestampMs").exists())
        .andExpect(jsonPath("$", hasKey("recent3")))
        .andExpect(jsonPath("$", hasKey("penalizedChoices")));

    mvc.perform(get("/api/history?limit=10"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].choice").exists())
        .andExpect(jsonPath("$[0].timestampMs").exists());
  }

  @Test
  void cors_preflight_should_allow_localhost_5175() throws Exception {
    mvc.perform(
            org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options("/api/history")
                .header("Origin", "http://localhost:5175")
                .header("Access-Control-Request-Method", "GET"))
        .andExpect(status().isOk());
  }
}

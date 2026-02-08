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

@SpringBootTest(
    properties = {
      "spring.datasource.url=jdbc:h2:mem:kunlun-lunch-test;MODE=PostgreSQL;DB_CLOSE_DELAY=-1",
      "spring.datasource.username=sa",
      "spring.datasource.password=",
      "spring.jpa.hibernate.ddl-auto=create-drop"
    })
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
        .andExpect(jsonPath("$", hasKey("penalizedChoices")))
        .andExpect(jsonPath("$", hasKey("recent3DaysBefore")));

    mvc.perform(get("/api/history?limit=10"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].choice").exists())
        .andExpect(jsonPath("$[0].timestampMs").exists());
  }

  @Test
  void demo_reset_should_seed_3_days() throws Exception {
    mvc.perform(post("/api/history/demo")).andExpect(status().isOk());

    mvc.perform(get("/api/history?limit=10"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].choice", is("卢布朗咖喱")))
        .andExpect(jsonPath("$[1].choice", is("肯德基")))
        .andExpect(jsonPath("$[2].choice", is("重庆小面")));
  }

  @Test
  void seed_should_insert_specific_day_without_clearing() throws Exception {
    mvc.perform(post("/api/history/demo")).andExpect(status().isOk());

    mvc.perform(
            post("/api/history/seed")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"choice\":\"赛百味\",\"date\":\"2026-02-08\"}"))
        .andExpect(status().isOk());

    mvc.perform(get("/api/history?limit=10"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].choice", is("赛百味")))
        .andExpect(jsonPath("$[1].choice", is("卢布朗咖喱")));
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

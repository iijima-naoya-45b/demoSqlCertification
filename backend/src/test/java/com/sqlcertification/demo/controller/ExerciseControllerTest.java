package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.Exercise;
import com.sqlcertification.demo.model.ExerciseQuestion;
import com.sqlcertification.demo.model.ExerciseSummary;
import com.sqlcertification.demo.service.ExerciseService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ExerciseController.class)
class ExerciseControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ExerciseService exerciseService;

    @Test
    void getExercises_shouldReturnList() throws Exception {
        when(exerciseService.getExerciseSummaries()).thenReturn(List.of(
                new ExerciseSummary("01", "基本SELECT", 1, 5)
        ));

        mockMvc.perform(get("/api/exercises"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].exerciseId").value("01"))
                .andExpect(jsonPath("$[0].questionCount").value(5));
    }

    @Test
    void getExercise_shouldReturnDetail() throws Exception {
        Exercise exercise = new Exercise();
        exercise.setExerciseId("01");
        exercise.setTitle("基本SELECT");
        ExerciseQuestion question = new ExerciseQuestion();
        question.setQuestionId("Q1");
        question.setText("全商品を取得");
        exercise.setQuestions(List.of(question));

        when(exerciseService.getExerciseById("01")).thenReturn(exercise);

        mockMvc.perform(get("/api/exercises/01"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("基本SELECT"))
                .andExpect(jsonPath("$.questions[0].questionId").value("Q1"));
    }
}

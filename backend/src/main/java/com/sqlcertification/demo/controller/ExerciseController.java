package com.sqlcertification.demo.controller;

import com.sqlcertification.demo.model.Exercise;
import com.sqlcertification.demo.model.ExerciseSummary;
import com.sqlcertification.demo.service.ExerciseService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/exercises")
public class ExerciseController {

    private final ExerciseService exerciseService;

    public ExerciseController(ExerciseService exerciseService) {
        this.exerciseService = exerciseService;
    }

    @GetMapping
    public List<ExerciseSummary> getExercises() {
        return exerciseService.getExerciseSummaries();
    }

    @GetMapping("/{exerciseId}")
    public Exercise getExercise(@PathVariable String exerciseId) {
        return exerciseService.getExerciseById(exerciseId);
    }
}

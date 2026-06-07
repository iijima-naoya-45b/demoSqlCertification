package com.sqlcertification.demo.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sqlcertification.demo.exception.ResourceNotFoundException;
import com.sqlcertification.demo.model.Exercise;
import com.sqlcertification.demo.model.ExerciseSummary;
import jakarta.annotation.PostConstruct;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
public class ExerciseService {

    private final ObjectMapper objectMapper;
    private List<Exercise> exercises = new ArrayList<>();

    public ExerciseService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @PostConstruct
    void loadExercises() throws IOException {
        ClassPathResource resource = new ClassPathResource("exercises/exercises.json");
        try (InputStream inputStream = resource.getInputStream()) {
            this.exercises = objectMapper.readValue(inputStream, new TypeReference<List<Exercise>>() {});
        }
    }

    public List<ExerciseSummary> getExerciseSummaries() {
        return exercises.stream()
                .sorted(Comparator.comparing(Exercise::getExerciseId))
                .map(exercise -> new ExerciseSummary(
                        exercise.getExerciseId(),
                        exercise.getTitle(),
                        exercise.getDifficulty(),
                        exercise.getQuestions().size()
                ))
                .toList();
    }

    public Exercise getExerciseById(String exerciseId) {
        return exercises.stream()
                .filter(exercise -> exercise.getExerciseId().equals(exerciseId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "ExerciseService.getExerciseById",
                        "exerciseId",
                        exerciseId
                ));
    }
}

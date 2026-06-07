package com.sqlcertification.demo.model;

import java.util.List;

public class Exercise {

    private String exerciseId;
    private String title;
    private int difficulty;
    private String description;
    private List<ExerciseQuestion> questions;

    public String getExerciseId() {
        return exerciseId;
    }

    public void setExerciseId(String exerciseId) {
        this.exerciseId = exerciseId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(int difficulty) {
        this.difficulty = difficulty;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<ExerciseQuestion> getQuestions() {
        return questions;
    }

    public void setQuestions(List<ExerciseQuestion> questions) {
        this.questions = questions;
    }
}

package com.sqlcertification.demo.model;

public class ExerciseSummary {

    private String exerciseId;
    private String title;
    private int difficulty;
    private int questionCount;

    public ExerciseSummary(String exerciseId, String title, int difficulty, int questionCount) {
        this.exerciseId = exerciseId;
        this.title = title;
        this.difficulty = difficulty;
        this.questionCount = questionCount;
    }

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

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }
}

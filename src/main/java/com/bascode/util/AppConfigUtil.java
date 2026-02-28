package com.bascode.util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import com.bascode.model.enums.ElectionPhase;

import jakarta.servlet.ServletContext;

public final class AppConfigUtil {

    private AppConfigUtil() {
    }

    public static LocalDate getVotingDeadline(ServletContext context) {
        String value = getWithEnvFallback(context, "voting.deadline", "VOTING_DEADLINE");
        if (value == null || value.isBlank()) {
            return LocalDate.now().plusYears(1);
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException ex) {
            return LocalDate.now().plusYears(1);
        }
    }

    public static String getBaseUrl(ServletContext context) {
        String value = getWithEnvFallback(context, "app.base-url", "APP_BASE_URL");
        if (value == null || value.isBlank()) {
            return "http://localhost:18080/online-voting-system";
        }
        return value.trim();
    }

    public static ElectionPhase getElectionPhase(ServletContext context) {
        String value = getWithEnvFallback(context, "election.phase", "ELECTION_PHASE");
        if (value == null || value.isBlank()) {
            return ElectionPhase.OPEN;
        }
        try {
            return ElectionPhase.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            return ElectionPhase.OPEN;
        }
    }

    public static boolean isElectionOpen(ServletContext context) {
        return getElectionPhase(context) == ElectionPhase.OPEN;
    }

    private static String getWithEnvFallback(ServletContext context, String contextKey, String envKey) {
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) {
            return envValue;
        }
        return context.getInitParameter(contextKey);
    }
}

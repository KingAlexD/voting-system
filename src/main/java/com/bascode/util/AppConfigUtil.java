package com.bascode.util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import com.bascode.model.enums.ElectionPhase;

import jakarta.servlet.ServletContext;

public final class AppConfigUtil {

    private AppConfigUtil() {}

    // ── Election Phase ────────────────────────────────────────────────────────

    /**
     * Reads the live election phase.
     *
     * Priority:
     *  1. ServletContext attribute "electionPhase"  ← set at runtime by ElectionControlServlet
     *  2. Environment variable ELECTION_PHASE
     *  3. web.xml <context-param> election.phase
     *  4. Default: DRAFT (voting locked until admin explicitly starts the election)
     *
     * The original bug: getWithEnvFallback() only read init-params, never getAttribute(),
     * so setAttribute() calls from ElectionControlServlet were silently ignored.
     */
    public static ElectionPhase getElectionPhase(ServletContext context) {
        // 1. Runtime attribute — written by setElectionPhase() / ElectionControlServlet
        Object attr = context.getAttribute("electionPhase");
        if (attr instanceof ElectionPhase) {
            return (ElectionPhase) attr;
        }
        if (attr instanceof String && !((String) attr).isBlank()) {
            try { return ElectionPhase.valueOf(((String) attr).trim().toUpperCase()); }
            catch (IllegalArgumentException ignored) {}
        }

        // 2 + 3. Environment variable or web.xml init-param
        String value = getWithEnvFallback(context, "election.phase", "ELECTION_PHASE");
        if (value != null && !value.isBlank()) {
            try { return ElectionPhase.valueOf(value.trim().toUpperCase()); }
            catch (IllegalArgumentException ignored) {}
        }

        // 4. Safe default — voting stays locked until admin starts the election
        return ElectionPhase.DRAFT;
    }

    /**
     * Persists the election phase as a runtime ServletContext attribute.
     * All servlets on this JVM instance see the change immediately.
     */
    public static void setElectionPhase(ServletContext context, ElectionPhase phase) {
        context.setAttribute("electionPhase", phase);
    }

    public static boolean isElectionOpen(ServletContext context) {
        return getElectionPhase(context) == ElectionPhase.OPEN;
    }

    // ── Other config ──────────────────────────────────────────────────────────

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

    // ── Internal helper ───────────────────────────────────────────────────────

    private static String getWithEnvFallback(ServletContext context,
                                              String contextKey, String envKey) {
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) return envValue;
        return context.getInitParameter(contextKey);
    }
}

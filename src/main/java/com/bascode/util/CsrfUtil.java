package com.bascode.util;

import java.security.SecureRandom;

import jakarta.servlet.http.HttpSession;

public final class CsrfUtil {
    public static final String SESSION_KEY = "csrfToken";
    public static final String PARAM = "_csrf";
    private static final SecureRandom RANDOM = new SecureRandom();

    private CsrfUtil() {
    }

    public static String getToken(HttpSession session) {
        Object existing = session.getAttribute(SESSION_KEY);
        if (existing instanceof String token && !token.isBlank()) {
            return token;
        }
        byte[] bytes = new byte[24];
        RANDOM.nextBytes(bytes);
        String token = toHex(bytes);
        session.setAttribute(SESSION_KEY, token);
        return token;
    }

    private static String toHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}

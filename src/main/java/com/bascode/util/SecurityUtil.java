package com.bascode.util;

import java.security.SecureRandom;

import org.mindrot.jbcrypt.BCrypt;

public final class SecurityUtil {
    private static final SecureRandom RANDOM = new SecureRandom();

    private SecurityUtil() {
    }

    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    }

    public static boolean verifyPassword(String plainPassword, String passwordHash) {
        if (plainPassword == null || passwordHash == null) {
            return false;
        }
        return BCrypt.checkpw(plainPassword, passwordHash);
    }

    public static String generateVerificationCode() {
        int code = 100000 + RANDOM.nextInt(900000);
        return String.valueOf(code);
    }
}

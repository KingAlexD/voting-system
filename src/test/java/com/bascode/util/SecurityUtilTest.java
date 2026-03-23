package com.bascode.util;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class SecurityUtilTest {

    @Test
    void hashAndVerifyPassword() {
        String password = "DemoPassword@123";
        String hash = SecurityUtil.hashPassword(password);
        assertNotEquals(password, hash);
        assertTrue(SecurityUtil.verifyPassword(password, hash));
        assertFalse(SecurityUtil.verifyPassword("wrong", hash));
    }
}

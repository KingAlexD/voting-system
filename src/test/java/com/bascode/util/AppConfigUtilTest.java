package com.bascode.util;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import com.bascode.model.enums.ElectionPhase;

import jakarta.servlet.ServletContext;

class AppConfigUtilTest {

    @Test
    void parsesElectionPhaseFromContext() {
        ServletContext context = Mockito.mock(ServletContext.class);
        Mockito.when(context.getInitParameter("election.phase")).thenReturn("CLOSED");
        assertEquals(ElectionPhase.CLOSED, AppConfigUtil.getElectionPhase(context));
    }
}

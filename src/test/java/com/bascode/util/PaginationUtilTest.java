package com.bascode.util;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;

import org.junit.jupiter.api.Test;

class PaginationUtilTest {

    @Test
    void paginatesListCorrectly() {
        List<Integer> numbers = List.of(1, 2, 3, 4, 5, 6, 7);
        PageResult<Integer> page = PaginationUtil.paginate(numbers, 2, 3);
        assertEquals(List.of(4, 5, 6), page.getItems());
        assertEquals(2, page.getPage());
        assertEquals(3, page.getTotalPages());
    }
}

package com.bascode.util;

import java.util.Collections;
import java.util.List;

public final class PaginationUtil {

    private PaginationUtil() {
    }

    public static <T> PageResult<T> paginate(List<T> list, int requestedPage, int pageSize) {
        if (list == null || list.isEmpty()) {
            return new PageResult<>(Collections.emptyList(), 1, 1);
        }
        int totalPages = (int) Math.ceil((double) list.size() / pageSize);
        int page = Math.max(1, Math.min(requestedPage, totalPages));
        int from = (page - 1) * pageSize;
        int to = Math.min(from + pageSize, list.size());
        return new PageResult<>(list.subList(from, to), page, totalPages);
    }

    public static int parsePage(String value, int fallback) {
        try {
            int page = Integer.parseInt(value);
            return Math.max(page, 1);
        } catch (Exception ex) {
            return fallback;
        }
    }
}

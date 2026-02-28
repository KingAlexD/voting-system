package com.bascode.util;

import java.util.List;

public class PageResult<T> {
    private final List<T> items;
    private final int page;
    private final int totalPages;

    public PageResult(List<T> items, int page, int totalPages) {
        this.items = items;
        this.page = page;
        this.totalPages = totalPages;
    }

    public List<T> getItems() {
        return items;
    }

    public int getPage() {
        return page;
    }

    public int getTotalPages() {
        return totalPages;
    }
}

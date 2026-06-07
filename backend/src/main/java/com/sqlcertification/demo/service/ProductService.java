package com.sqlcertification.demo.service;

import com.sqlcertification.demo.mapper.ProductMapper;
import com.sqlcertification.demo.model.PageResult;
import com.sqlcertification.demo.model.Product;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductService {

    private final ProductMapper productMapper;

    public ProductService(ProductMapper productMapper) {
        this.productMapper = productMapper;
    }

    public PageResult<Product> getProducts(
            String categoryName,
            String keyword,
            Boolean inStockOnly,
            int page,
            int pageSize
    ) {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.min(Math.max(pageSize, 1), 100);
        int offset = (safePage - 1) * safePageSize;

        List<Product> items = productMapper.selectProducts(
                categoryName, keyword, inStockOnly, safePageSize, offset
        );
        long totalCount = productMapper.countProducts(categoryName, keyword, inStockOnly);

        return new PageResult<>(items, totalCount, safePage, safePageSize);
    }
}

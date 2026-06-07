package com.sqlcertification.demo.mapper;

import com.sqlcertification.demo.model.Product;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductMapper {

    List<Product> selectProducts(
            @Param("categoryName") String categoryName,
            @Param("keyword") String keyword,
            @Param("inStockOnly") Boolean inStockOnly,
            @Param("limit") int limit,
            @Param("offset") int offset
    );

    long countProducts(
            @Param("categoryName") String categoryName,
            @Param("keyword") String keyword,
            @Param("inStockOnly") Boolean inStockOnly
    );
}

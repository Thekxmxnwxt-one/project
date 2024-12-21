// src/components/ProductSortDropdown.js
import React from 'react';

const ProductSortDropdown = ({ sortOrder, onSortChange }) => {
  return (
    <select value={sortOrder} onChange={onSortChange}>
      <option value="default">Price</option>
      <option value="price-asc">price (Min-Max)</option>
      <option value="price-desc">price (Max-Min)</option>
    </select>
  );
};

export default ProductSortDropdown;

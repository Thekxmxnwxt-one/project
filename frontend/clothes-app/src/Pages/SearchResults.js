import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useSearchParams } from 'react-router-dom';
import ClothesCard from '../Component/ClothesCard';
import ProductSortDropdown from '../Component/ProductSortDropdown'; // Import dropdown

const SearchResults = () => {
  const [products, setProducts] = useState([]);
  const [error, setError] = useState(null);
  const [sortOrder, setSortOrder] = useState('default'); // State for sorting
  const [searchParams] = useSearchParams();
  const searchQuery = searchParams.get('q');

  useEffect(() => {
    const fetchProducts = async () => {
      if (searchQuery) {
        try {
          const response = await axios.get(`http://localhost:8080/api/v1/products/search?name=${searchQuery}`);
          if (response.data && Array.isArray(response.data)) {
            setProducts(response.data);
            setError(null);
          } else {
            setError('No products found matching your search');
          }
        } catch (error) {
          console.error('Error fetching products:', error);
          setError('Unable to fetch products');
        }
      } else {
        setProducts([]);
        setError('Please enter your search query');
      }
    };

    fetchProducts();
  }, [searchQuery]);

  const handleSortChange = (e) => {
    setSortOrder(e.target.value);
  };

  const sortedData = [...products].sort((a, b) => {
    if (sortOrder === 'price-asc') return a.price - b.price;
    if (sortOrder === 'price-desc') return b.price - a.price;
    return 0;
  });

  return (
    <div className="new_arrivals">
      <div className="container">
        <div className="row">
          <div className="col text-center">
            <div className="section_title new_arrivals_title">
              <h2>Search results for "{searchQuery}"</h2>
              <div className="underline"></div>
            </div>
          </div>
        </div>

        {/* Sorting section on the left */}
        <div className="row mb-3">
          <div className="col-12 d-flex justify-content-start">
            <ProductSortDropdown sortOrder={sortOrder} onSortChange={handleSortChange} />
          </div>
        </div>

        <div className="row">
          <div className="col">
            {error ? (
              <p className="text-center text-danger">{error}</p>
            ) : sortedData.length > 0 ? (
              <div className="product-grid">
                {sortedData.map((product) => (
                  <ClothesCard key={product.id} product={product} />
                ))}
              </div>
            ) : (
              <p className="text-center">No products found for your search</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default SearchResults;



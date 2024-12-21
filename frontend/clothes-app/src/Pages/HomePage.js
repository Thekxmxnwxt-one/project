import React, { useState, useEffect } from 'react';
import ClothesCard from '../Component/ClothesCard';
import BrandSlider from '../Component/BrandSlider';
import axios from 'axios';
import BannerCarousel from '../Component/BannerCarousel';

const api_url = '/api/v1/products';

const HomePage = () => {
  const [filter, setFilter] = useState('*');
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(api_url);
        setProducts(response.data);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching products:', error);
        setError(error.message);
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const filteredProducts = products.filter(
    (product) => (filter === '*' || product.category === filter) && product.isnew
  );

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  return (
    <div className="new_arrivals">
      <div className="container">
        <div>
          <BannerCarousel />
        </div>
        <div className="row">
          <div className="col text-center">
            <div className="section_title new_arrivals_title">
              <h2>Brands</h2>
              <div className="underline"></div>
              <div>
                <BrandSlider />
              </div>
            </div>
          </div>
        </div>

        <div className="row">
          <div className="col text-center">
            <div className="section_title new_arrivals_title">
              <h2>New Arrivals</h2>
              <div className="underline"></div>
            </div>
          </div>
        </div>
        <div className="row align-items-center">
          <div className="col text-center">
            <div className="new_arrivals_sorting">
              <ul className="arrivals_grid_sorting clearfix button-group filters-button-group">
                <li
                  className={`grid_sorting_button button d-flex flex-column justify-content-center align-items-center ${filter === '*' ? 'active is-checked' : ''}`}
                  onClick={() => setFilter('*')}
                >
                  all
                </li>
                <li
                  className={`grid_sorting_button button d-flex flex-column justify-content-center align-items-center ${filter === 'women' ? 'active' : ''}`}
                  onClick={() => setFilter('women')}
                >
                  women's
                </li>
                <li
                  className={`grid_sorting_button button d-flex flex-column justify-content-center align-items-center ${filter === 'kids' ? 'active' : ''}`}
                  onClick={() => setFilter('kids')}
                >
                  kids's
                </li>
                <li
                  className={`grid_sorting_button button d-flex flex-column justify-content-center align-items-center ${filter === 'men' ? 'active' : ''}`}
                  onClick={() => setFilter('men')}
                >
                  men's
                </li>
              </ul>
            </div>
          </div>
        </div>
        <div className="row">
          <div className="col">
            <div className="product-grid">
              {filteredProducts.map((product) => (
                <ClothesCard key={product.id} product={product} />
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HomePage;

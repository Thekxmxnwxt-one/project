import React, { useState, useEffect } from 'react';
import axios from 'axios';

const BrandSelectDropdown = ({ onBrandSelect }) => {
  const [brands, setBrands] = useState([]);

  useEffect(() => {
    const fetchBrands = async () => {
      try {
        const response = await axios.get('/api/v1/brand'); // URL ของ API
        setBrands(response.data);
      } catch (error) {
        console.error('Error fetching brands:', error);
      }
    };

    fetchBrands();
  }, []);

  const handleBrandChange = (event) => {
    const selectedBrandId = event.target.value;
    if (selectedBrandId) {
      onBrandSelect(selectedBrandId); // เรียก callback พร้อมกับ id ของแบรนด์ที่เลือก
    }
  };

  return (
    <select onChange={handleBrandChange} defaultValue="">
      <option value="">Brand</option>
      {brands.map((brand) => (
        <option key={brand.id} value={brand.id}>
          {brand.brandname}
        </option>
      ))}
    </select>
  );
};

export default BrandSelectDropdown;

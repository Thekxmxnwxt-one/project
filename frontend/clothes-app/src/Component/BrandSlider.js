//BrandSlider.js
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faArrowLeft, faArrowRight } from '@fortawesome/free-solid-svg-icons';
import axios from 'axios';
import '../Style/BrandSlider.css';

const BrandSlider = () => {
  const [brands, setBrands] = useState([]); // เก็บข้อมูลแบรนด์จาก API
  const [currentIndex, setCurrentIndex] = useState(0);
  const visibleItems = 5; // จำนวนแบรนด์ที่จะแสดงในแต่ละครั้ง

  useEffect(() => {
    const fetchBrands = async () => {
      try {
        const response = await axios.get('/api/v1/brand'); // URL ของ API
        setBrands(response.data); // สมมติว่า API ส่งข้อมูลแบรนด์กลับมาเป็น array
      } catch (error) {
        console.error('Error fetching brands:', error);
      }
    };

    fetchBrands();
  }, []);

  const nextSlide = () => {
    if (currentIndex < brands.length - visibleItems) {
      setCurrentIndex(currentIndex + 1);
    }
  };

  const prevSlide = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
    }
  };

  const isNextDisabled = currentIndex >= brands.length - visibleItems;
  const isPrevDisabled = currentIndex === 0;

  return (
    <div className="brand-slider">
      <button 
        className={`slide-arrow left-arrow ${isPrevDisabled ? 'disabled' : ''}`} 
        onClick={prevSlide}
        disabled={isPrevDisabled}
      >
        <FontAwesomeIcon icon={faArrowLeft} />
      </button>

      <div className="brand-slide">
        {brands.slice(currentIndex, currentIndex + visibleItems).map((brand) => (
          <Link to={`/brand/${brand.id}`} className="brand-item" key={brand.id}>
            <img src={brand.brandlogo} alt={brand.brandname} />
            <h3 className="brand-name">{brand.brandname}</h3>
          </Link>
        ))}
      </div>

      <button 
        className={`slide-arrow right-arrow ${isNextDisabled ? 'disabled' : ''}`} 
        onClick={nextSlide}
        disabled={isNextDisabled}
      >
        <FontAwesomeIcon icon={faArrowRight} />
      </button>
    </div>
  );
};

export default BrandSlider;
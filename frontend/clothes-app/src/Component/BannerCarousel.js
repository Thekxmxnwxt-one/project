// src/components/BannerCarousel.jsx
import React from 'react';
import { Carousel } from 'react-bootstrap';

const BannerCarousel = () => {
  return (
    <Carousel>
      <Carousel.Item>
        <img
          className="d-block w-100"
          src="/asserts/images/slide-1.png"
          alt="First slide"
        />
      </Carousel.Item>
      <Carousel.Item>
        <img
          className="d-block w-100"
          src="/asserts/images/slide-2.png"
          alt="Second slide"
        />
      </Carousel.Item>
      <Carousel.Item>
        <img
          className="d-block w-100"
          src="/asserts/images/slide-3.png"
          alt="Third slide"
        />
      </Carousel.Item>
    </Carousel>
  );
};

export default BannerCarousel;
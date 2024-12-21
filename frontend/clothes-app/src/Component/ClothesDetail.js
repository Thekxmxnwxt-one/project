import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'; 
import { faArrowLeft } from '@fortawesome/free-solid-svg-icons';
import axios from 'axios';

const ProductDetail = () => {
  const { productId } = useParams();
  const [product, setProduct] = useState(null);
  const [quantity, setQuantity] = useState(1);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        const response = await axios.get(`http://localhost:8080/api/v1/products/${productId}`);
        setProduct(response.data);
      } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
      }
    };

    fetchProduct();
  }, [productId]);

  if (!product) {
    return <h2>Product not found!</h2>;
  }

  const handleIncrease = () => setQuantity(quantity + 1);
  const handleDecrease = () => {
    if (quantity > 1) setQuantity(quantity - 1);
  };

  const handleGoBack = () => navigate(-1);

  const handleAddToCart = async () => {
    try {
      // เรียก API เพื่อเพิ่มสินค้าไปยังตะกร้า
      const response = await axios.post(`http://localhost:8080/api/v1/cart`, {
        product_id: product.id,
      quantity: quantity
    });

    // แสดงข้อมูลจาก Response
    console.log(response.data);

    if (response.status === 200) {
      alert('Product added to cart');
    } else {
      alert('Something went wrong. Please try again later.');
    }
  } catch (error) {
    // แสดงข้อผิดพลาดที่เกิดขึ้นจาก API
    console.error('Error adding product to cart:', error);

    // ข้อความแสดงข้อผิดพลาด
    alert('Failed to add product to cart');
  }
};

  return (
    <main className="container_a">
      <button onClick={handleGoBack} className="back-arrow">
        <FontAwesomeIcon icon={faArrowLeft} />
      </button>
      
      <div className="left-column">
        <img src={product.imgsrc} alt={product.name} /> {/* ใช้ product.imgsrc */}
      </div>

      <div className="right-column">
        <div className="product-description">
          <span>{product.category}</span>
          <h2>{product.name}</h2>
          <div className="product-price">
            <span>฿ {product.price}</span>
          </div>
        </div>

        <div className="product-configuration">
          <div className="cable-config">
            <p>{product.description}</p>
          </div>
        </div>
        <div className='text-quantity'>
          <p>Quantity</p>
        </div>
        <div className="quantity-selector">
          <button onClick={handleDecrease} className="decrease-btn">-</button>
          <span>{quantity}</span>
          <button onClick={handleIncrease} className="increase-btn">+</button>
        </div>

        <div className="add-to-cart-container">
          <button onClick={handleAddToCart} className="cart-btn">
            Add to cart
          </button>
        </div>
      </div>
    </main>
  );
};

export default ProductDetail;

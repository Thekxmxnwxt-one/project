import React from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const ClothesCard = ({ product }) => {
  // ฟังก์ชันเพิ่มสินค้าลงในตะกร้าโดยตรง
  const handleAddToCart = async () => {
    try {
      const response = await axios.post('http://localhost:8080/api/v1/cart', {
        product_id: product.id,
        quantity: 1, // ปริมาณที่ต้องการ
      });

      if (response.status === 200) {
        alert('Product added to cart');
      } else {
        alert('Something went wrong. Please try again later.');
      }
    } catch (error) {
      console.error('Error adding product to cart:', error);
      alert('Failed to add product to cart');
    }
  };

  

  return (
    <div className="product-item">
      <Link to={`/product/${product.id}`} className="product-link">
        <div className="product">
          <div className="product_image">
            <img src={product.imgsrc} alt={product.name} />
          </div>
          {product.isnew && (
            <div className="product_bubble product_bubble_left product_bubble_green d-flex flex-column align-items-center">
              <span>new</span>
            </div>
          )}
          <div className="product_info">
            <h6 className="product_name">
              <Link to={`/product/${product.id}`}>{product.name}</Link>
            </h6>
            <div className="product_price">฿{product.price}</div>
          </div>
        </div>
      </Link>
      <button className="red_button add_to_cart_button" onClick={handleAddToCart}>
        <a>Add to Cart</a></button>
    </div>
  );
};

export default ClothesCard;

import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';
import '../Style/CartPage.css';

const CartPage = () => {
  const [cartItems, setCartItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // ฟังก์ชันเรียก API เพื่อดึงข้อมูลตะกร้า
  useEffect(() => {
    const fetchCartItems = async () => {
      try {
        const response = await axios.get('http://localhost:8080/api/v1/cart');
        setCartItems(response.data || []); // ถ้าข้อมูลเป็น null ให้ใช้ค่าเริ่มต้นเป็นอาร์เรย์ว่าง
        setLoading(false);
      } catch (err) {
        setError('Failed to load cart items.');
        setLoading(false);
      }
    };

    fetchCartItems();
  }, []); // ทำงานเมื่อ component โหลดครั้งแรก

  // คำนวณราคาทั้งหมดในตะกร้า
  const calculateTotal = () => {
    return cartItems.reduce((total, item) => total + item.price * item.quantity, 0);
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>{error}</div>;
  }

  // ฟังก์ชันลบสินค้าออกจากตะกร้า
const handleRemoveFromCart = async (cartId) => {
    try {
      await axios.delete(`http://localhost:8080/api/v1/cart/${cartId}`);
      // หลังจากลบสินค้า, รีเฟรชข้อมูลในตะกร้า
      const updatedCart = cartItems.filter(item => item.cart_id !== cartId);
      setCartItems(updatedCart);
    } catch (err) {
      console.error('Error removing item from cart:', err);
    }
  };

  return (
    <div className="cart-page">
      <h2>Your Shopping Cart</h2>

      {/* ตรวจสอบว่าตะกร้าว่างหรือไม่ */}
      {Array.isArray(cartItems) && cartItems.length === 0 ? (
        <p>Your cart is empty.</p>
      ) : (
        <div className="cart-items">
          {cartItems.map(item => (
            <div key={item.cart_id} className="cart-item">
              <img src={item.imgsrc} alt={item.name} className="cart-item-image" />
              <div className="cart-item-details">
                <h3>{item.name}</h3>
                <p>Price: ฿{item.price}</p>
                <p>Quantity: {item.quantity}</p>
                <p>Total: ฿{item.price * item.quantity}</p>
              </div>
              <div className="cart-item-actions">
                <button onClick={() => handleRemoveFromCart(item.cart_id)}>Remove</button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* คำนวณรวมราคาสินค้า */}
      {cartItems.length > 0 && (
        <div className="cart-summary">
          <h3>Total: ฿{calculateTotal()}</h3>
          <Link to="/checkout">
            <button className="checkout-btn">Proceed to Checkout</button>
          </Link>
        </div>
      )}
    </div>
  );
};



export default CartPage;

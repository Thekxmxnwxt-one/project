import React from 'react';
import { Link } from 'react-router-dom';
import '../Style/Footer.css';

const Footer = () => {
  return (
    <footer className="footer">
      <div className="footer-container">
        {/* ส่วนที่หนึ่ง: ลิงก์หลัก */}
        <div className="footer-links">
          <h3>About</h3>
          <ul>
            <li><a href="/allproduct">Product</a></li>
            <li>About us</li>
            <li>Contact us</li>
          </ul>
        </div>

        {/* ส่วนที่สอง: ช่องทางการติดต่อ */}
        <div className="footer-contact">
          <h3>Contact</h3>
          <ul>
            <li><a href="tel:+123456789">tel: +123 456 789</a></li>
            <li><a href="mailto:support@shop.com">email: support@shop.com</a></li>
            <li><a href="https://www.facebook.com/yourshop" target="_blank" rel="noopener noreferrer">Facebook</a></li>
          </ul>
        </div>

        {/* ส่วนที่สาม: ข้อมูลลิขสิทธิ์ */}
        <div className="footer-copyright">
          <p>&copy; 2024 ShopName. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}

export default Footer;

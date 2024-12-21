import React from 'react';
import '../Style/BrandShipping.css';

const BrandShipping = () => {
    return (
        <div className="brand-tax-container">
            <h1 className="tax-title">วิธีการจัดส่ง</h1>
            <br></br>
            <div className="tax-section">
                <ul>
                    <li>ขณะนี้เราสามารถจัดส่งสินค้าภายในประเทศไทยผ่านทาง Kerry Express, BEST EXPRESS, J&T EXPRESS และ DHL EXPRESS เท่านั้นระยะเวลาในการจัดส่ง 3-5 วันทำการ</li>
                    <br></br>
                    <li>การจัดส่งข้างต้นสำหรับการสั่งซื้อปกติ ที่ไม่ใช่ช่วงเทศกาล</li>
                </ul>
            </div>
        </div>
    );
};

export default BrandShipping;

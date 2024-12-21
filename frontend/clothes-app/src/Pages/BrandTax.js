import React from 'react';
import '../Style/BrandTax.css';


const BrandTax = () => {
  return (
    <div className="brand-tax-container">
  <h1 className="tax-title">การขอใบกำกับภาษี</h1>
  <br></br>
  <div className="tax-section">
    <ol>
      <li>ออเดอร์ต้องมีสถานะเป็น "สำเร็จ" หรือ "Completed" เท่านั้น</li>
      <li>
        ลูกค้าต้องทักแชทร้านค้าเพื่อแจ้งขอใบกำกับภาษีผ่านทาง Official Line Store 
        <a href="https://line.me/R/ti/p/@angelclothse" target="_blank" rel="noopener noreferrer">@angelclothse</a>
      </li>
      <li>ลูกค้าต้องกรอกแบบฟอร์มเอกสารใบกำกับภาษีที่ทางแอดมินส่งให้ภายใน 5 วันเท่านั้น</li>
      <li>ลูกค้าจะได้รับเอกสารภายใน 10-20 วันทำการ หลังจากกรอกข้อมูลถูกต้อง</li>
    </ol>
    <p className="tax-note">
      *ในกรณีที่กรอกข้อมูลไม่ครบหรือผิด ระยะเวลาที่จะได้รับใบกำกับภาษีอาจเพิ่มขึ้น
    </p>
  </div>
</div>


  );
};

export default BrandTax;

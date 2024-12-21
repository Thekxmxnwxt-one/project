import React from 'react';
import '../Style/BrandPayment.css';

const BrandPayment = () => {
    return (
        <div className="payment-container">
            <h1 className="payment-title">วิธีการชำระเงิน</h1>
            <br></br>
            <div className="payment-section">
                <h2>ฉันจะชำระเงินได้อย่างไร?</h2>
                <p>มี 2 วิธีการชำระเงินให้คุณเลือก</p>
                <ol>
                    <li>บัตรเครดิตและเดบิต Promptpay รับบัตร Visa, MasterCard, JCB และ UnionPay</li>
                    <li>เงินสดในการจัดส่ง สำหรับการจัดส่งในประเทศไทยเท่านั้น โปรดตรวจสอบให้แน่ใจว่ามีจำนวนเงินเพียงพอสำหรับการชำระ</li>
                    <li>ธนาคารทางอินเทอร์เน็ต</li>
                </ol>
            </div>
            <div className="payment-section">
                <h2>ฉันต้องกรอกข้อมูลอะไรบ้างสำหรับการชำระเงินด้วยบัตรเครดิต / เดบิต?</h2>
                <p>โปรดกรอกข้อมูลต่อไปนี้สำหรับการชำระเงินด้วยบัตรเครดิต / เดบิตให้ประสบความสำเร็จ</p>
                <ol>
                    <li>หมายเลขบัตรเครดิต / เดบิต</li>
                    <li>ชื่อและนามสกุลของเจ้าของบัตร</li>
                    <li>วันหมดอายุ</li>
                    <li>หมายเลข CVV</li>
                    <li>ในบางกรณี บริษัท บัตรเครดิตอาจขอให้ใส่รหัส OTP</li>
                </ol>
            </div>
            <div className="payment-section">
                <h2>ฉันสามารถจ่ายด้วยบัตรหลายใบได้หรือไม่?</h2>
                <p>ไม่ได้ในขณะนี้</p>
            </div>
            <div className="payment-section">
                <h2>ฉันจะรู้ได้อย่างไรว่าการชำระเงินของฉันสำเร็จ?</h2>
                <p>ผู้ถือบัตรเครดิต / เดบิตทั้งหมดจะต้องได้รับอนุญาตจาก บริษัท บัตรเครดิต หากการชำระเงินถูกต้อง...</p>
            </div>
        </div>
    );
};

export default BrandPayment;

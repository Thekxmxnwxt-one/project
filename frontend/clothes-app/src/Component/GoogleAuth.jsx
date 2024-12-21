import React, { useState, useEffect } from 'react';
import { GoogleOAuthProvider, GoogleLogin } from '@react-oauth/google';
import {jwtDecode} from 'jwt-decode'; // ตรวจสอบว่าใช้งาน jwt-decode แบบ default import
import axios from 'axios';

const GoogleAuth = ({ setUser, handleClose }) => {
  const [clientId, setClientId] = useState(''); // State สำหรับเก็บ client-id

  // ฟังก์ชันสำหรับยืนยัน token ที่ได้รับจาก Google
  const verifyToken = async (credentialResponse) => {
    try {
      // Decode token จาก Google
      const decodedToken = jwtDecode(credentialResponse.credential);
      console.log('Decoded token:', decodedToken);

      // ส่ง token ไปยัง backend เพื่อตรวจสอบและรับข้อมูลผู้ใช้
      const backendResponse = await axios.post('http://localhost:8081/api/v1/auth/google/verify', {
        id_token: credentialResponse.credential,
      });

      if (backendResponse.status === 200) {
        console.log('Backend response:', backendResponse.data);

        // เก็บข้อมูลผู้ใช้ใน sessionStorage (หรือเปลี่ยนเป็น localStorage ตามความต้องการ)
        const userData = {
          name: backendResponse.data.user.name,
          email: backendResponse.data.user.email,
          picture: decodedToken.picture, // ดึงรูปภาพจาก decodedToken
        };
        setUser(userData);
        sessionStorage.setItem('user', JSON.stringify(userData)); // เก็บข้อมูลผู้ใช้ใน sessionStorage

        sessionStorage.setItem('accessToken', backendResponse.data.access_token); // เก็บ accessToken

        // ปิด modal หลังจากล็อกอินสำเร็จ
        handleClose();
      } else {
        console.error('Failed to verify token on the backend');
      }
    } catch (error) {
      console.error('Authentication error:', error);
    }
  };

  const handleGoogleFailure = (error) => {
    console.error('Google Sign-In error:', error);
  };

  // ฟังก์ชันสำหรับดึง client-id จาก backend
  useEffect(() => {
    const fetchClientId = async () => {
      try {
        const response = await axios.get('http://localhost:8081/api/v1/auth/client-id', {
          headers: {
            'API-Key': 'werj23489', // ใส่ API-Key ใน headers ของการเรียก API
          },
        });
        setClientId(response.data.client_id); // ตั้งค่า clientId จาก backend
      } catch (error) {
        console.error('Error fetching client ID:', error);
      }
    };

    fetchClientId(); // เรียกใช้งานฟังก์ชันดึง clientId
  }, []);

  return (
    <div>
      {clientId ? ( // เช็คว่ามี clientId ก่อน
        <GoogleOAuthProvider clientId={clientId}>
          <div className="text-center mt-3">
            <GoogleLogin
              onSuccess={verifyToken}
              onError={handleGoogleFailure}
              useOneTap
            />
          </div>
        </GoogleOAuthProvider>
      ) : (
        <div>Loading...</div> // แสดงข้อความ Loading ระหว่างรอ clientId
      )}
    </div>
  );
};

export default GoogleAuth;
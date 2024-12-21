import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import '../Style/AboutPage.css';

const BrandInfoPage = () => {
  const { brandId } = useParams();
  const [infoData, setInfoData] = useState(null);

  useEffect(() => {
    const fetchInfoData = async () => {
      try {
        const response = await axios.get(`http://localhost:8080/api/v1/about/${brandId}`);
        setInfoData(response.data);
      } catch (error) {
        console.error("Error fetching brand info data:", error);
      }
    };
    fetchInfoData();
  }, [brandId]);

  if (!infoData) return <div>Loading...</div>;

  return (
    <div className="brand-info-page">
      {/* ส่วนของรูปภาพ */}
      <div className="about-header">
        <img src={infoData.img} alt={infoData.title} />
      </div>
      
      {/* ส่วนของเนื้อหา */}
      <div className="about-content">
        <h2>{infoData.title}</h2>
        <p>{infoData.description}</p>
        {/* คุณสามารถเพิ่มข้อมูลเพิ่มเติม เช่น ที่อยู่ เบอร์โทร หรือข้อมูลอื่น ๆ ได้ที่นี่ */}
      </div>
    </div>
  );
};

export default BrandInfoPage;

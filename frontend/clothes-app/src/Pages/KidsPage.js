import React, { useState, useEffect } from 'react';
import ClothesCard from '../Component/ClothesCard';
import ProductSortDropdown from '../Component/ProductSortDropdown'; // นำเข้า dropdown
import BrandSelectDropdown from '../Component/BrandSelectDropdown';
//import { clothesData } from '../Data/ClothesData';

const api_url = '/api/v1/products/category/kids'

const KidsPage = () => {
  // กรองเฉพาะสินค้าที่เป็นของผู้หญิง (women)
  //const kidProducts = clothesData.filter(product => product.category === 'kids');

  const [kidProducts, setkidsData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [sortOrder, setSortOrder] = useState('default'); // สร้าง state สำหรับเลือกการจัดเรียง
  const [selectedBrandId, setSelectedBrandId] = useState(null);


  useEffect(() => {
    // ฟังก์ชันสำหรับดึงข้อมูลจาก API
    const fetchData = async () => {
      try {
        const response = await fetch(api_url);
        if (!response.ok) {
          console.error('Response status:', response.status);
          throw new Error(`Failed to fetch clothes, status code:
    ${response.status}`);
        }
        const data = await response.json();
        // ตรวจสอบว่าข้อมูลทีBได้รับเป็นอาเรย์หรือไม่
        if (Array.isArray(data)) {
          // ถ้าเป็นอาเรย์ก็จัดเรียงได้เลย
          const sortedBooks = data.sort(
            (a, b) => new Date(b.dateAdded) - new Date(a.dateAdded)
          );
          setkidsData(sortedBooks); // เลือก 3 เล่ม
        } else if (Array.isArray(data.books)) {
          // ถ้าข้อมูลอยู่ในฟิลด์ "books"
          const sortedBooks = data.books.sort(
            (a, b) => new Date(b.dateAdded) - new Date(a.dateAdded)
          );
          setkidsData(sortedBooks);
        } else {
          throw new Error('Unexpected data format');
        }
        setLoading(false);
      } catch (error) {
        console.error('Error fetching clothes:', error);
        setError(error.message);
        setLoading(false);
      }
    };
    fetchData();
  }, []);
  if (loading) {
    return <div>Loading...</div>; // แสดงข้อความระหว่างโหลด
  }
  if (error) {
    return <div>Error: {error}</div>; // แสดงข้อผิดพลาดถ้าเกิดปัญหา
  }

  const handleSortChange = (e) => {
    setSortOrder(e.target.value);
  };

  const handleBrandSelect = (brandId) => {
    setSelectedBrandId(brandId);
  };

  // การจัดเรียงข้อมูลตามราคาหรือเริ่มต้น
  const sortedData = () => {
    if (sortOrder === 'price-asc') {
      return [...kidProducts].sort((a, b) => a.price - b.price);
    } else if (sortOrder === 'price-desc') {
      return [...kidProducts].sort((a, b) => b.price - a.price);
    }
    return kidProducts; // ไม่มีการจัดเรียงถ้าเป็นค่า default
  };

  // กรองสินค้าตามแบรนด์ที่เลือก
  const filteredProducts = sortedData().filter(product => 
    !selectedBrandId || product.brandId === selectedBrandId
  );

  if (loading) {
    return <div>Loading...</div>; // แสดงข้อความระหว่างโหลด
  }

  if (error) {
    return <div>Error: {error}</div>; // แสดงข้อผิดพลาดถ้าเกิดปัญหา
  }

  if (filteredProducts.length === 0) {
    return <div>Unavailable</div>; // แสดงข้อความเมื่อไม่มีสินค้า
  }

  return (
    <div className="new_arrivals">
      <div className="container">
        <div className="row">
          <div className="col text-center">
            <div className="section_title new_arrivals_title">
              <h2>Kids Product</h2>
              <div className="underline"></div>
            </div>
          </div>
        </div>

        {/* เพิ่ม ProductSortDropdown และ BrandSelectDropdown */}
        <div className="row mb-3">
          <div className="col-12 d-flex justify-content-between">
            <ProductSortDropdown sortOrder={sortOrder} onSortChange={handleSortChange} />
            <BrandSelectDropdown onBrandSelect={handleBrandSelect} />
          </div>
        </div>

        <div className="row">
          <div className="col">
            <div className="product-grid">
              {filteredProducts.length > 0 ? (
                filteredProducts.map((product) => (
                  <ClothesCard key={product.id} product={product} />
                ))
              ) : (
                <p>Unavailable</p> // ข้อความที่แสดงเมื่อไม่มีสินค้า
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default KidsPage;

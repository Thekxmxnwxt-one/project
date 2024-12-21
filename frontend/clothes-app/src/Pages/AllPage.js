import React, { useState, useEffect } from 'react';
import axios from 'axios';
import ClothesCard from '../Component/ClothesCard';
import ProductSortDropdown from '../Component/ProductSortDropdown';
import BrandSelectDropdown from '../Component/BrandSelectDropdown';

const api_url = '/api/v1/products';

const AllPage = () => {
  const [clothesData, setClothesData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [sortOrder, setSortOrder] = useState('default');
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
          setClothesData(sortedBooks); // เลือก 3 เล่ม
        } else if (Array.isArray(data.books)) {
          // ถ้าข้อมูลอยู่ในฟิลด์ "books"
          const sortedBooks = data.books.sort(
            (a, b) => new Date(b.dateAdded) - new Date(a.dateAdded)
          );
          setClothesData(sortedBooks);
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
    fetchData(selectedBrandId);
  }, [selectedBrandId]);

  const handleSortChange = (e) => {
    setSortOrder(e.target.value);
  };

  const fetchData = async (brandId = '') => {
    try {
      const response = await axios.get(`/api/v1/products${brandId ? `/brand/${brandId}` : ''}`);
      const data = response.data;
      if (Array.isArray(data)) {
        const sortedProducts = data.sort((a, b) => new Date(b.dateAdded) - new Date(a.dateAdded));
        setClothesData(sortedProducts);
      } else {
        setClothesData([]);
      }
      setLoading(false);
    } catch (error) {
      console.error('Error fetching clothes:', error);
      setError(error.message);
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData(selectedBrandId);
  }, [selectedBrandId]);

  const handleBrandSelect = (brandId) => {
    setSelectedBrandId(brandId);
  };

  const sortedData = [...clothesData].sort((a, b) => {
    if (sortOrder === 'price-asc') return a.price - b.price;
    if (sortOrder === 'price-desc') return b.price - a.price;
    return 0;
  });

  if (loading) {
    return <div>Loading...</div>; // แสดงข้อความระหว่างโหลด
  }
  if (error) {
    return <div>Error: {error}</div>; // แสดงข้อผิดพลาดถ้าเกิดปัญหา
  }

  return (
    <div className="new_arrivals">
      <div className="container">
        <div className="row">
          <div className="col text-center">
            <div className="section_title new_arrivals_title">
              <h2>All Product</h2>
              <div className="underline"></div>
            </div>
          </div>
        </div>

        <div className="row mb-3">
          <div className="col-12 d-flex justify-content-between">
            <ProductSortDropdown sortOrder={sortOrder} onSortChange={handleSortChange} />
            <BrandSelectDropdown onBrandSelect={handleBrandSelect} />
          </div>
        </div>

        <div className="row">
          <div className="col">
            <div className="product-grid">
              {sortedData.length > 0 ? (
                sortedData.map((product) => (
                  <ClothesCard key={product.id} product={product} />
                ))
              ) : (
                <p>Unavailable</p> // Message displayed when no products are available
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AllPage;

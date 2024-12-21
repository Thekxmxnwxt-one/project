import React, { useState, useEffect } from 'react';
import ClothesCard from '../Component/ClothesCard';
import ProductSortDropdown from '../Component/ProductSortDropdown'; // นำเข้า dropdown
import BrandSelectDropdown from '../Component/BrandSelectDropdown';

const api_url = '/api/v1/products/category/women';

const WomanPage = () => {
  const [womenData, setWomenData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [sortOrder, setSortOrder] = useState('default'); // สร้าง state สำหรับการจัดเรียง
  const [selectedBrandId, setSelectedBrandId] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(api_url);
        if (!response.ok) {
          console.error('Response status:', response.status);
          throw new Error(`ไม่สามารถดึงข้อมูลได้, status code: ${response.status}`);
        }
        const data = await response.json();
        if (Array.isArray(data)) {
          setWomenData(data); // บันทึกข้อมูลที่ดึงมา
        } else if (Array.isArray(data.books)) {
          setWomenData(data.books); // ถ้าข้อมูลอยู่ใน books
        } else {
          throw new Error('รูปแบบข้อมูลไม่ถูกต้อง');
        }
        setLoading(false);
      } catch (error) {
        console.error('Error fetching clothes:', error);
        setError(error.message);
        setLoading(false);
      }
    };
    fetchData();
  }, [selectedBrandId]);  // Refetch data when selectedBrandId changes

  const handleSortChange = (e) => {
    setSortOrder(e.target.value);
  };

  const handleBrandSelect = (brandId) => {
    setSelectedBrandId(brandId);
  };

  const sortedData = () => {
    // Sorting logic based on the selected order
    if (sortOrder === 'price-asc') {
      return [...womenData].sort((a, b) => a.price - b.price);
    } else if (sortOrder === 'price-desc') {
      return [...womenData].sort((a, b) => b.price - a.price);
    }
    return womenData; // No sorting if default
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  return (
    <div className="new_arrivals">
      <div className="container">
        <div className="row">
          <div className="col text-center">
            <div className="section_title new_arrivals_title">
              <h2>Woman Product</h2>
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
              {sortedData().length > 0 ? (
                sortedData().map((product) => (
                  <ClothesCard key={product.id} product={product} />
                ))
              ) : (
                <p>Unavailable</p>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default WomanPage;

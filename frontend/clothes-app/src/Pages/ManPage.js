import React, { useState, useEffect } from 'react'; 
import ClothesCard from '../Component/ClothesCard';
import ProductSortDropdown from '../Component/ProductSortDropdown';
import BrandSelectDropdown from '../Component/BrandSelectDropdown';

const api_url = '/api/v1/products/category/men';

const MenPage = () => {
  const [menProducts, setMenData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [sortOrder, setSortOrder] = useState('default');
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
          const sortedProducts = data.sort((a, b) => new Date(b.dateAdded) - new Date(a.dateAdded));
          setMenData(sortedProducts);
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
  }, [selectedBrandId]);

  const handleSortChange = (e) => {
    setSortOrder(e.target.value);
  };

  const handleBrandSelect = (brandId) => {
    setSelectedBrandId(brandId);
  };

  // กรองข้อมูลตามแบรนด์ที่เลือก
  const filteredData = menProducts.filter(product => 
    !selectedBrandId || product.brandId === selectedBrandId
  );

  // การจัดเรียงข้อมูลตามราคาหรือเริ่มต้น
  const sortedData = [...filteredData].sort((a, b) => {
    if (sortOrder === 'price-asc') return a.price - b.price;
    if (sortOrder === 'price-desc') return b.price - a.price;
    return 0;
  });

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  if (filteredData.length === 0) {
    return <div>Unavailableา</div>; // แสดงข้อความเมื่อไม่มีสินค้าจากแบรนด์ที่เลือก
  }

  return (
    <div className="new_arrivals">
      <div className="container">
        <div className="row">
          <div className="col text-center">
            <div className="section_title new_arrivals_title">
              <h2>Man Product</h2>
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
              {sortedData.length > 0 ? (
                sortedData.map((product) => (
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

export default MenPage;

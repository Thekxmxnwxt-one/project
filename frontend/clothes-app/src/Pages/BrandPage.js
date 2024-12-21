import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import ClothesCard from '../Component/ClothesCard';
import '../Style/BrandPage.css';
import ProductSortDropdown from '../Component/ProductSortDropdown';

const BrandPage = () => {
  const { brandId } = useParams();
  //const brandProducts = clothesData.filter(product => product.brandId === parseInt(brandId));
  //const brand = brands.find(brand => brand.id === parseInt(brandId));
  const [brandProducts, setBrandProducts] = useState([]); // เริ่มต้นเป็นอาเรย์ว่าง
  const [brandName, setBrandName] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [sortOrder, setSortOrder] = useState('priceAsc');

  // ดึงข้อมูลสินค้าและแบรนด์
  useEffect(() => {
    const fetchBrandProducts = async () => {
      try {
        const response = await fetch(`http://localhost:8080/api/v1/products/brand/${brandId}`);
        if (!response.ok) throw new Error('Failed to fetch products');
        const data = await response.json();
        setBrandProducts(data || []); // หากข้อมูลเป็น null ให้ตั้งค่าเป็นอาเรย์ว่าง
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    const fetchBrandName = async () => {
      try {
        const response = await fetch(`http://localhost:8080/api/v1/brand/${brandId}`);
        if (!response.ok) throw new Error('Failed to fetch brand name');
        const brandData = await response.json();
        setBrandName(brandData.brandname);
      } catch (err) {
        setError(err.message);
      }
    };

    fetchBrandProducts();
    fetchBrandName();
  }, [brandId]);

  const sortedData = [...brandProducts].sort((a, b) => {
    if (sortOrder === 'price-asc') return a.price - b.price;
    if (sortOrder === 'price-desc') return b.price - a.price;
    return 0;
  });

  const handleSortChange = (e) => {
    setSortOrder(e.target.value);
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className="Brand-page">
      <div className="container">
        <div className="row">
          <div className="col text-center">
            <div className="section_title new_arrivals_title">
              <h2> {brandName}</h2>
              <div className="underline"></div>
            </div>
          </div>
        </div>

        <div className="row">
          <div className="col">
            <ProductSortDropdown onSortChange={handleSortChange} />
          </div>
        </div>

        <div className="row">
          <div className="col">
            <div className="products-grid-brand">
              {sortedData.length > 0 ? (
                sortedData.map(product => (
                  <ClothesCard key={product.id} product={product} />
                ))
              ) : (
                <p>Unavailable</p> // หากไม่มีสินค้าจะแสดงข้อความนี้
              )}
            </div>
          </div>
        </div>

        {/* ส่วนของลิงก์สำหรับหัวข้อเพิ่มเติม */}
        <div className="about-container">
        <div class="about-content-wrapper">
          <div className="footer-column">
            <h4 className="about-title">About {brandName}</h4>
            <ul className="about-links">
              <li><Link to={`/brand/${brandId}/info`}>Additional Information</Link></li>
              <li><Link to={`/brand/${brandId}/location`}>Location</Link></li>
            </ul>
          </div>

          <div className="footer-column">
            <h4 className="about-title">Service</h4>
            <ul className="about-links">
              <li><Link to={`/brand/${brandId}/tax`}>Requesting a tax invoice</Link></li>
              <li><Link to={`/brand/${brandId}/faq`}>FAQ</Link></li>
              <li><Link to={`/brand/${brandId}/shipping`}>Shipping Policy</Link></li>
              <li><Link to={`/brand/${brandId}/return`}>Product return Policy</Link></li>
              <li><Link to={`/brand/${brandId}/payment`}>Payment Method</Link></li>

            </ul>
          </div>

          <div className="footer-column">
            <h4 className="about-title">Follow {brandName}</h4>
            <div className="social-icons">
              <a href="#" className="social-icon"><i className="fab fa-facebook-f"></i></a>
              <a href="#" className="social-icon"><i className="fab fa-twitter"></i></a>
              <a href="#" className="social-icon"><i className="fab fa-instagram"></i></a>
              <a href="#" className="social-icon"><i className="fab fa-youtube"></i></a>
              <a href="#" className="social-icon"><i className="fab fa-tiktok"></i></a>
              <a href="#" className="social-icon"><i className="fab fa-line"></i></a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  );
};

export default BrandPage;

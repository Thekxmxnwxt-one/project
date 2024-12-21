import '../Style/Header.css';
import '@fortawesome/fontawesome-free/css/all.min.css';
import { Link, useNavigate } from 'react-router-dom';  // นำเข้า Link จาก react-router-dom
import React, { useState, useEffect, useRef } from 'react';  // นำเข้า useState จาก React
import { Button, Modal, Dropdown } from 'react-bootstrap'; // เพิ่ม Dropdown จาก react-bootstrap
import GoogleAuth from './GoogleAuth';
import axios from 'axios';

const Header = () => {
  const [searchTerm, setSearchTerm] = useState(''); // เก็บคำค้นหา
  const [searchHistory, setSearchHistory] = useState([]); // เก็บประวัติการค้นหา
  const [showHistory, setShowHistory] = useState(false); // ควบคุมการแสดง dropdown
  const navigate = useNavigate();
  const searchInputRef = useRef(null); // อ้างอิงถึงช่องค้นหา
  const historyDropdownRef = useRef(null); // อ้างอิงถึง dropdown
  const [cartCount, setCartCount] = useState(0);

  // โหลดประวัติการค้นหาจาก localStorage
  useEffect(() => {
    const savedHistory = JSON.parse(localStorage.getItem('searchHistory')) || [];
    setSearchHistory(savedHistory);
  }, []);

  // อัปเดตประวัติการค้นหาใน localStorage
  const updateSearchHistory = (query) => {
    const updatedHistory = [query, ...searchHistory.filter((item) => item !== query)].slice(0, 5); // เก็บล่าสุด 5 อัน
    setSearchHistory(updatedHistory);
    localStorage.setItem('searchHistory', JSON.stringify(updatedHistory));
  };

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    if (searchTerm) {
      updateSearchHistory(searchTerm); // บันทึกคำค้นหาในประวัติ
      navigate(`/search?q=${searchTerm}`);
      setShowHistory(false);
    }
  };

  const handleHistoryClick = (query) => {
    setSearchTerm(query); // ตั้งค่าคำค้นหาด้วยประวัติที่คลิก
    navigate(`/search?q=${query}`);
    setShowHistory(false);
  };

  const handleFocus = () => {
    setShowHistory(true); // แสดง dropdown เมื่อ focus ช่องค้นหา
  };

  const handleClickOutside = (e) => {
    if (
      historyDropdownRef.current &&
      !historyDropdownRef.current.contains(e.target) &&
      !searchInputRef.current.contains(e.target)
    ) {
      setShowHistory(false); // ซ่อน dropdown เมื่อคลิกนอก dropdown และช่องค้นหา
    }
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  // ฟังก์ชันลบประวัติการค้นหาที่เลือก
  const handleDeleteHistory = (queryToDelete) => {
    const updatedHistory = searchHistory.filter((query) => query !== queryToDelete);
    setSearchHistory(updatedHistory);
    localStorage.setItem('searchHistory', JSON.stringify(updatedHistory));
  };
  
  const [showLogin, setShowLogin] = useState(false);
  const [user, setUser] = useState(null); // เก็บข้อมูลผู้ใช้

  useEffect(() => {
    // ดึงข้อมูลผู้ใช้จาก sessionStorage เมื่อหน้าเว็บถูกโหลดหรือรีเฟรช
    const storedUser = sessionStorage.getItem('user');
    if (storedUser) {
      setUser(JSON.parse(storedUser)); // กำหนดข้อมูลผู้ใช้ใน state
    }
  }, []);

  const handleShow = () => setShowLogin(true);
  const handleClose = () => setShowLogin(false);
  const handleLogout = () => {
    // ลบข้อมูลผู้ใช้จาก sessionStorage
    sessionStorage.removeItem('user');
    setUser(null); // รีเซ็ต state
    navigate('/'); // เปลี่ยนเส้นทางกลับไปที่หน้าหลัก
  };


  // ฟังก์ชันสำหรับส่งคำค้นหาเมื่อกด Enter
  const handleSearch = (e) => {
    if (e.key === 'Enter') {
      navigate(`/search?query=${searchTerm}`); // เปลี่ยนเส้นทางไปยังหน้า /search พร้อมส่งคำค้นหา
      setSearchTerm(''); // ล้างคำค้นหา
    }
  };

  const fetchCartCount = async () => {
    try {
      const response = await axios.get('http://localhost:8080/api/v1/cart');
      const totalItems = response.data.reduce((total, item) => total + item.quantity, 0);
      setCartCount(totalItems); // อัพเดต cartCount
    } catch (error) {
      console.error('Error fetching cart count:', error);
    }
  };

  useEffect(() => {
    fetchCartCount(); // เรียกฟังก์ชันเมื่อหน้าเว็บโหลดครั้งแรกเพื่อดึงข้อมูลตะกร้า
  }, []); // ค่าภายใน [] หมายความว่าจะรันครั้งเดียวเมื่อ component ถูก mount

  // ฟังก์ชันการเพิ่มสินค้าในตะกร้า
  const handleAddToCart = async (productId) => {
    try {
      await axios.post('http://localhost:8080/api/v1/cart', { product_id: productId, quantity: 1 });
      fetchCartCount(); // เรียกฟังก์ชันเพื่ออัพเดตจำนวนสินค้าหลังจากเพิ่มสินค้า
    } catch (error) {
      console.error('Error adding product to cart:', error);
    }
  };
  
  const handleCartClick = () => {
    navigate('/cart'); // ใช้ navigate เพื่อไปที่หน้าตะกร้า
  };

  return (
    <header className="App-header">
      <div className="logo">ANGEL CLOSET</div>
      <nav>
        <ul>
          <li><Link to="/">HOME</Link></li>  {/* ใช้ Link แทน a */}
          <li><Link to="/allproduct">ALL PRODUCT</Link></li>
          <li><Link to="/woman">WOMAN</Link></li>  {/* ใช้ Link แทน a */}
          <li><Link to="/man">MAN</Link></li>      {/* ใช้ Link แทน a */}
          <li><Link to="/kids">KIDS</Link></li>    {/* ใช้ Link แทน a */}
        </ul>
      </nav>
      <div className="header-icons d-flex align-items-center">
      <form onSubmit={handleSearchSubmit} className="search-form" style={{ position: 'relative' }}>
          <input
            type="text"
            className="search-input"
            placeholder="Search Product"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            onFocus={handleFocus}
            ref={searchInputRef}
          />
          <button type="submit" className="search-button">
            <i className="fas fa-search"></i>
          </button>
          {/* แสดง dropdown ของประวัติการค้นหา */}
          {showHistory && searchHistory.length > 0 && (
            <ul
              ref={historyDropdownRef}
              className="search-history-dropdown"
              style={{
                position: 'absolute',
                top: '100%',
                left: 0,
                right: 0,
                backgroundColor: 'white',
                border: '1px solid #ccc',
                maxHeight: '150px',
                overflowY: 'auto',
                zIndex: 10,
                listStyle: 'none',
                margin: 0,
                padding: 0,
              }}
            >
              {searchHistory.map((query, index) => (
                <li
                  key={index}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '8px',
                    borderBottom: '1px solid #eee'
                  }}
                >
                  <span
                    onClick={() => handleHistoryClick(query)}
                    style={{ cursor: 'pointer', flex: 1 }}
                  >
                    {query}
                  </span>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleDeleteHistory(query);
                    }}
                    style={{
                      background: 'none',
                      border: 'none',
                      color: 'red',
                      cursor: 'pointer',
                      marginLeft: '10px'
                    }}
                  >
                    X
                  </button>
                </li>
              ))}
            </ul>
          )}
        </form>

        <i className="fas fa-shopping-bag" onClick={handleCartClick}>
            {cartCount > 0 && (
              <span className="cart-count">{cartCount}</span> // แสดงจำนวนสินค้าถ้ามี
            )}
        </i>

        {user ? (
            <Dropdown>
              <Dropdown.Toggle 
                variant="light" 
                id="dropdown-basic" 
                className="d-flex align-items-center" 
                style={{
                  backgroundColor: 'transparent', // ทำให้พื้นหลังเป็นสีใส
                  color: '#333', // สีตัวอักษร
                  marginLeft: '10px',
                }}
              >
                <img
                  src={user.picture}
                  alt="user-profile"
                  style={{
                    borderRadius: '50%',
                    width: '30px'
                  }}
                  referrerPolicy="no-referrer"
                />
              </Dropdown.Toggle>

              <Dropdown.Menu>
                <Dropdown.Item as={Link} to="/profile">My Profile</Dropdown.Item>
                <Dropdown.Item onClick={handleLogout}>Logout</Dropdown.Item>
              </Dropdown.Menu>
            </Dropdown>
          ) : (
            <i className="fas fa-user" onClick={handleShow} style={{ cursor: 'pointer' }}></i>
          )}

            <Modal show={showLogin} onHide={handleClose} centered>
              <Modal.Header closeButton>
                <Modal.Title>เข้าสู่ระบบ</Modal.Title>
              </Modal.Header>
              <Modal.Body>
                <GoogleAuth
                  setUser={(user) => {
                    setUser(user);
                    sessionStorage.setItem('user', JSON.stringify(user)); // เก็บข้อมูลผู้ใช้ใน sessionStorage
                  }}
                  handleClose={handleClose}
                />
              </Modal.Body>
            </Modal>
      </div>
    </header>
  );
}

export default Header;

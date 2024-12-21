import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import 'bootstrap/dist/css/bootstrap.min.css';
import Header from './Component/Navbar';
import Footer from './Component/Footer';
import HomePage from './Pages/HomePage';
import AllPage from './Pages/AllPage';
import './App.css';
import WomenPage from './Pages/WomanPage';
import MenPage from './Pages/ManPage';
import KidsPage from './Pages/KidsPage';
import ProductDetail from './Component/ClothesDetail';
import BrandPage from './Pages/BrandPage';
import BrandInfoPage from './Pages/BrandInfoPage'; // สร้างและนำเข้า component ใหม่
import BrandFAQ from './Pages/BrandFAQ';
import BrandPayment from './Pages/BrandPayment';
import LocationPage from './Pages/LocationPage';
import BrandTax from './Pages/BrandTax';
import BrandShipping from './Pages/BrandShipping';
import BrandReturn from './Pages/BrandReturn';
import CartPage from './Pages/CartPage';
import SearchResults from './Pages/SearchResults';
import { GoogleOAuthProvider } from '@react-oauth/google';

const App = () => {
  return (
    <GoogleOAuthProvider clientId="515890392386-cgcel1u5s5s97p4m6v1c0viq2h0t7qkk.apps.googleusercontent.com">
    <Router>
      <Header />
      <Routes>
        <Route path="/" element={<HomePage />}/>
        <Route path="/allproduct" element={<AllPage />}/>
        <Route path="/woman" element={<WomenPage />}/>
        <Route path="/man" element={<MenPage />}/>
        <Route path="/kids" element={<KidsPage />}/>
        <Route path="/product/:productId" element={<ProductDetail />} />
        <Route path="/brand/:brandId" element={<BrandPage />} />
        <Route path="/brand/:brandId/info" element={<BrandInfoPage />} /> {/* เพิ่ม Route ใหม่ */}
        <Route path="/brand/:brandId/faq" element={<BrandFAQ />} />
        <Route path="/brand/:brandId/payment" element={<BrandPayment />} />
        <Route path="/brand/:brandId/location" element={<LocationPage />} /> 
        <Route path="/brand/:brandId/tax" element={<BrandTax />} />
        <Route path="/brand/:brandId/shipping" element={<BrandShipping/>} />
        <Route path="/brand/:brandId/return" element={<BrandReturn/>} />


        <Route path="/search" element={<SearchResults />} />
        <Route path="/cart" element={<CartPage />} />
      </Routes>
      <Footer />

    </Router>
    </GoogleOAuthProvider>
  );
};

export default App;

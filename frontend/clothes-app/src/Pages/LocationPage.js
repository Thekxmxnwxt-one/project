import React, { useState, useEffect } from 'react';
import axios from 'axios';
import '../Style/LocationPage.css';
import { useParams } from 'react-router-dom';

const LocationPage = () => {
  const { brandId } = useParams(); // Get the brand ID from the URL
  const [branches, setBranches] = useState([]);
  const [filteredBranches, setFilteredBranches] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [province, setProvince] = useState('');

  // Fetch branches for the specific brand ID
  useEffect(() => {
    if (brandId) {
      axios.get(`http://localhost:8080/api/v1/branches/brand/${brandId}`)
        .then((response) => {
          const data = response.data || [];
          setBranches(data);
          setFilteredBranches(data);
        })
        .catch((error) => console.error('Failed to fetch branches:', error));
    }
  }, [brandId]);

  // Filter branches by search term
  useEffect(() => {
    const filtered = branches.filter(
      (branch) =>
        branch.banch && branch.banch.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredBranches(filtered);
  }, [searchTerm, branches]);

  // Filter branches by province
  useEffect(() => {
    if (province) {
      const filtered = branches.filter((branch) => branch.province === province);
      setFilteredBranches(filtered);
    } else {
      setFilteredBranches(branches); // Show all branches if no province is selected
    }
  }, [province, branches]);

  // List of provinces
  const provinces = [
    "กรุงเทพมหานคร", "กระบี่", "กาญจนบุรี", "กาฬสินธุ์", "กำแพงเพชร",
    "ขอนแก่น", "จันทบุรี", "ฉะเชิงเทรา", "ชลบุรี", "ชัยนาท", "ชัยภูมิ",
    "ชุมพร", "เชียงราย", "เชียงใหม่", "ตรัง", "ตราด", "ตาก",
    "นครนายก", "นครปฐม", "นครพนม", "นครราชสีมา", "นครศรีธรรมราช",
    "นครสวรรค์", "นนทบุรี", "นราธิวาส", "น่าน", "บึงกาฬ", "บุรีรัมย์",
    "ปทุมธานี", "ประจวบคีรีขันธ์", "ปราจีนบุรี", "ปัตตานี", "พะเยา",
    "พระนครศรีอยุธยา", "พังงา", "พัทลุง", "พิจิตร", "พิษณุโลก",
    "เพชรบุรี", "เพชรบูรณ์", "แพร่", "ภูเก็ต", "มหาสารคาม", "มุกดาหาร",
    "แม่ฮ่องสอน", "ยโสธร", "ยะลา", "ร้อยเอ็ด", "ระนอง", "ระยอง",
    "ราชบุรี", "ลพบุรี", "ลำปาง", "ลำพูน", "เลย", "ศรีสะเกษ",
    "สกลนคร", "สงขลา", "สตูล", "สมุทรปราการ", "สมุทรสงคราม",
    "สมุทรสาคร", "สระแก้ว", "สระบุรี", "สิงห์บุรี", "สุโขทัย",
    "สุพรรณบุรี", "สุราษฎร์ธานี", "สุรินทร์", "หนองคาย", "หนองบัวลำภู",
    "อ่างทอง", "อำนาจเจริญ", "อุดรธานี", "อุตรดิตถ์", "อุทัยธานี",
    "อุบลราชธานี"
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white p-4 shadow">
        <h1 className="text-center text-2xl font-bold">ค้นหาที่ตั้งสาขา</h1>
      </header>
  
      {/* Search Section */}
      <div className="search-container p-4">
        <div className="faq-search">
          <input
            type="text"
            placeholder="ที่อยู่, ชื่อสาขา"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)} // Update searchTerm
          />
          <button>
            <i className="fas fa-search"></i>
          </button>
        </div>
        <div className="dropdown-container mt-4">
          <label htmlFor="province-select" className="block mb-1 font-bold italic">
            ค้นหาตามจังหวัด
          </label>
          <select
            id="province-select"
            className="border rounded p-2 italic"
            value={province}
            onChange={(e) => setProvince(e.target.value)} // Update province
          >
            <option value="">ทั้งหมด</option>
            {provinces.map((province) => (
              <option key={province} value={province}>
                {province}
              </option>
            ))}
          </select>
        </div>
      </div>
  
      {/* Branch List */}
      <div className="content-container">
        <div className="branch-list">
          <h2>สาขาทั้งหมด ({filteredBranches.length})</h2>
          <ul>
            {filteredBranches.map((branch) => (
              <li key={branch.id}>
                <strong>{branch.banch}</strong> - {branch.banch_location}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default LocationPage;

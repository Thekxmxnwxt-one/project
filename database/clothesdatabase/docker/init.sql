-- ตรวจสอบว่า database มีอยู่แล้วหรือไม่
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'clothesstore') THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE clothesstore');
    END IF;
END$$;

-- กำหนดสิทธิ์ให้กับผู้ใช้งาน
GRANT ALL PRIVILEGES ON DATABASE clothesstore TO clothesstore_user;

-- ใช้คำสั่ง \c ใน CLI เพื่อเชื่อมต่อ (ไม่สามารถรันได้ใน script-based tool)
-- \c clothesstore

-- สร้าง Extension สำหรับ UUID (เฉพาะ PostgreSQL)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- เริ่มต้น Transaction
BEGIN;

-- สร้างตาราง products
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    imgsrc VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(255) NOT NULL,
    price FLOAT NOT NULL,
    isNew BOOLEAN,
    createdate DATE DEFAULT CURRENT_DATE,
    updatedate DATE DEFAULT CURRENT_DATE
);

-- สร้างตาราง brand
CREATE TABLE IF NOT EXISTS brand (
    id SERIAL PRIMARY KEY,
    brandname VARCHAR(100),
    brandlogo VARCHAR(255)
);

-- สร้างตาราง about_page
CREATE TABLE IF NOT EXISTS about_page (
    id SERIAL PRIMARY KEY,
    brand_id INT REFERENCES brand(id),
    img VARCHAR(255),
    title VARCHAR(255),
    description TEXT
);

-- สร้างตาราง branch
CREATE TABLE IF NOT EXISTS branch (
    id SERIAL PRIMARY KEY,
    brand_id INT REFERENCES brand(id),
    province VARCHAR(255),
    banch VARCHAR(255),
    banch_location VARCHAR(255)
);

-- สร้างตาราง cart
CREATE TABLE IF NOT EXISTS cart (
    cart_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- สร้าง ENUM สำหรับ user_status และ user_role
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_status') THEN
        CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE user_role AS ENUM ('customer', 'seller', 'admin');
    END IF;
END$$;

-- สร้างตาราง users
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    google_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    profile_picture_url VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    status user_status NOT NULL DEFAULT 'active',
    role user_role NOT NULL DEFAULT 'customer',
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- สร้างตาราง user_sessions
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    id_token TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- สร้างตาราง user_login_history
CREATE TABLE IF NOT EXISTS user_login_history (
    login_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    login_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- สร้างตาราง api_keys
CREATE TABLE IF NOT EXISTS api_keys (
    key_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    api_key VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- สร้าง Trigger สำหรับตาราง users
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- สร้าง Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_login_history_user_id ON user_login_history(user_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_api_key ON api_keys(api_key);

COMMIT;

-- เพิ่มข้อมูลตัวอย่าง

INSERT INTO products (category, imgSrc, name, description, brand, price, isNew) VALUES
('women', '/images/product_1.avif', 'Bossini', 'กางเกงขายาว ผู้หญิง สีกากี',1, 1990.00, TRUE),
('women', '/images/product_2.avif', 'Bossini', 'เสื้อยืด ผู้ชาย สีเทา', 1, 690.00, TRUE),
('men', '/images/product_3.avif', 'Bossini', 'เสื้อสเวตเตอร์ ผู้ชาย สีครีม', 1, 1590.00, FALSE),
('women', '/images/product_4.avif', 'Bossini', 'กางเกงยีนส์ ผู้หญิง สียีนส์', 1, 1990.00, FALSE),
('men', '/images/product_5.avif', 'Bossini', 'เสื้อยืด ผู้ชาย สีแดง', 1, 450.00, FALSE),
('men', '/images/product_6.webp', 'Original Super Fleece Cone Hoodie', 'THE FIT - This hoodie for men has an original fit with the original cone oversized hood.
THE FEEL - Brushed on the interior for exceptional softness, this mens sweatshirt is crafted with an ultra-heavyweight 14 oz. fabric.
THE LOOK - This men hoodie is notable for its oversized, cone-shaped hood and classic rib waistband and cuffs. Double-needle construction for added durability.',2, 2700.00, TRUE),
('kids', '/images/product_7.webp', 'Big Girls Hoodie, Be the Good', 'THE FIT - Standard fit girls hoodie for easy layering or solo wear.
THE FEEL - Soft fleece fabric for ultimate comfort.
THE LOOK - Drawstring hem for a fresh look',2, 960.00, TRUE),
('kids', '/images/product_8.webp', 'Big Girls Hoodie, Print Hood', 'Fabric: 60% Cotton, 40% Polyester', 2, 960.00, FALSE),
('women', '/images/product_9.webp', 'T-Shirt, Cropped Baby Tee, University of Michigan', 'Fabric: 60% Cotton/40% Polyester', 2, 750.00, FALSE),
('women', '/images/product_10.webp', 'Puffer Vest, Classic Script Logo', 'Fabric: 100% Polyester', 2, 2700.00, FALSE),
('men', '/images/product_11.webp', 'CPS TYPOGRAPHY TEE', 'เสื้อ CPS สไตล์วินเทจ แต่งสีฟอกซีด โดดเด่นด้วยลวดลายปักขอบตามตัวพิมพ์อักษร เสริมเสน่ห์ด้วยไอเท็มเรียบง่าย ยิ่งจับคู่ท่อนล่างคุมโทนสีดำ ช่วยเพิ่มความเท่กรันจ์ อินเทรนด์ในสไตล์มินิมอล', 3, 1390.00, TRUE),
('men', '/images/product_12.webp', 'LONG-SLEEVE STRIPE TEE', 'เสื้อยืดแขนยาวทรงหลวม มาพร้อมลายพิมพ์ขวางยอดนิยม เสื้อยืดสไตล์คลาสสิกเรียบง่าย สามารถแมตช์กับกางเกงโทนสีดำ เข้าถึงลุคโดดเด่นที่ไม่ว่าจะแต่งลุคไหนก็ไม่มีเอาต์', 3, 1590.00, TRUE),
('women', '/images/product_13.webp', 'VELVET GRAPHIC TEE', 'ค้นพบสไตล์สุดสร้างสรรค์ ผ่านเสื้อยืดอาร์ตเวิร์กผีเสื้อพิมพ์กำมะหยี่คอลลาจกับฟ้อนต์ ไอเท็มผสานระหว่างความเท่สไตล์ Grunge กับเฟมินีนได้อย่างลงตัว ให้คุณอัปเดตลุคเสื้อยืดเรียบเท่ในสไตล์ร่วมสมัยไม่เหมือนใคร', 3, 1190.00, FALSE),
('women', '/images/product_14.webp', 'CUT-OUT WIDE LEG JEANS', 'ค้นพบไอเท็มแฟชั่นกางเกงยีนส์สไตล์ Utility ดีไซน์แต่งฟอกเลอะและขาดคัตเอาต์ที่ขาหลายตำแหน่ง สะท้อนความเป็นสตรีทแฟชั่นในสไตล์ดิบเท่ ผสมผสานกับสไตล์ลำลองได้อย่างลงตัว', 3, 2490.00, FALSE),
('women', '/images/product_15.webp', 'DISTRESSED DARK GREEN SWEATER', 'เข้าถึงแฟชั่นวินเทอร์กับเสื้อสเวตเตอร์ นำเสนอลุค Grunge ด้วยโทนสีเขียวแต่งขาด และปักป้ายแพทช์อย่างมีสไตล์ สวมใส่สร้างลุคสตรีทเท่เซอร์โดดเด่นน่าจดจำ', 3, 1890.00, FALSE),
('women', '/images/product_16.avif', 'ELLE BE PARIS', 'เสื้อยืดแขนสั้น สกรีนลายกราฟฟิคลาย ELLE BE PARIS รุ่น W3K692 สีกรมท่าง', 4, 990.00, TRUE),
('women', '/images/product_17.avif', 'Elle', 'เสื้อเชิ๊ตสตรีผ้า COTTON/NYLON/SPANDEX แขนยาว ทรง OVER SIZE รุ่น W3B276 สีน้ำเงิน', 4, 2190.00, FALSE),
('men', '/images/product_18.webp', 'ELLE HOMME', 'กางเกงขาสามส่วน กระเป๋าล้วง 2 ข้างและกระเป๋าหลัง I W8L272', 4, 990.00, FALSE),
('kids', '/images/product_19.webp', 'the good day lab™ White Shirts', 'เสื้อเชิ้ตเด็ก สะท้อนน้ำ กันคราบเปิ้อน', 5, 1990.00, TRUE),
('kids', '/images/product_20.webp', 'the good day lab™ Kids T-shirt Collection', 'เสื้อยืดเด็ก สะท้อนน้ำ กันคราบเปิ้อน', 5, 590.00, TRUE),
('men','/images/product_21.webp','Cool Tech™ Jeans - Regular','กางเกงยีนส์เย็น ลดอุณหภูมิบริเวณต้นขาด้านในลงสูงสุด 2 องศา ใส่สบาย ไม่เหนียวเหนอะหนะ', 5, 2990.00,FALSE),
('men','/images/product_22.webp','GQWhite™ Mandarin Collar Shirt','เสื้อเชิ้ตคอจีน ผ้านุ่มพิเศษ สะท้อนน้ำ ยับยาก รีดง่าย', 5, 1990.00,FALSE),
('men','/images/product_23.webp','Minimal Polo','เสื้อโปโลสไตล์ Minimal ใส่ง่าย มาพร้อมกับเทคโนโลยีเทปลดกลิ่นนำเข้าจากประเทศญี่ปุ่น ยับยั้งแบคทีเรีย ลดกลิ่นเหงื่อ ยับยาก', 5, 999.00,FALSE),
('kids', '/images/product_24.avif', 'Hooded Barn Jacket', 'With its corduroy details and roomy pockets, this version of our signature barn jacket is crafted from water-repellent fabric and insulated with down-alternative fill. A removable hood adds protection from rainy weather.', 6, 4050.00, TRUE),
('kids', '/images/product_25.avif', 'The Iconic Flag Sweater', 'With an intarsia-knit historical American flag, this combed cotton sweater is a small-scale version of a Ralph Lauren icon.', 6, 3450.00, TRUE),
('women', '/images/product_26.avif', 'Slim Fit Oxford Shirt', 'Classic in style, this Slim Fit shirt is crafted with Ralph Lauren’s soft cotton oxford and finished with our multicolored signature Pony embroidered at the chest.', 6, 3840.00, TRUE),
('women', '/images/product_27.avif', 'Ruffle-Trim Cotton Voile Blouse', 'With cascading ruffles and crocheted lace trim, lightweight cotton voile brings an airy look and feel to this blouse.', 6, 14940.00, FALSE),
('men', '/images/product_28.avif', 'Custom Fit Poplin Shirt', 'Crafted with 120s-quality, two-ply cotton poplin, this shirt features a trim fit and our signature embroidered Pony at the hem.', 6, 5040.00, FALSE),
('men', '/images/product_29.avif', 'Whitman Relaxed Fit Pleated Chino Pant', 'In soft cotton chino, these unisex pants offer a classic Polo look with their relaxed, pleated silhouette.', 6, 5040.00, TRUE),
('kids', '/images/product_30.avif', 'KIDS เสื้อยืด AIRism', 'เสื้อยืด AIRism คอตตอน ลายกราฟิก แขนสั้น', 7, 390.00, FALSE),
('kids', '/images/product_31.avif', 'GIRLS เสื้อยืดแขนสั้น mofusand UT', 'เสื้อยืดแขนสั้น mofusand UT', 7, 390.00, FALSE),
('kids', '/images/product_32.avif', 'เสื้อยืด HEATTECH Ultra Warm', 'เสื้อยืด HEATTECH Ultra Warm คอกลม', 7, 590.00, TRUE),
('women', '/images/product_33.avif', 'เสื้อยืด Ultra Stretch AIRism', 'เสื้อยืด Ultra Stretch AIRism แขนสั้น ทรงครอป', 7, 490.00, FALSE),
('women', '/images/product_34.avif', 'เสื้อกล้าม เสริมบรา แขนกุด สไตล์อเมริกัน ลายทาง', 'เสื้อกล้าม เสริมบรา แขนกุด สไตล์อเมริกัน ลายทาง', 7, 590.00, TRUE),
('men', '/images/product_35.avif', 'ยีนส์ ทรงกว้าง ขาตรง', 'ยีนส์ ทรงกว้าง ขาตรง', 7, 1290.00, TRUE),
('men', '/images/product_36.avif', 'เสื้อยืดแขนสั้น The Louvre x Camille Henrot UT', 'เสื้อยืดแขนสั้น The Louvre x Camille Henrot UT', 7, 590.00, FALSE),
('women','/images/product_37.jpg','Frilled blouse','Oversized blouse in a crêpe weave featuring a round neckline, frills down the front and a deep opening with spaghetti ties. Long raglan sleeves with elasticated, flounce-trimmed cuffs and spaghetti ties around the wrists.', 8, 999.00,TRUE ),
('women','/images/product_38.jpg','Frill-trimmed blouse','Oversized blouse in woven fabric with a round neckline and an opening with narrow ties at the front. Yoke with a frill trim at the front and gathers at the back. Long balloon sleeves with narrow elastication at the cuffs.', 8, 799.00,FALSE ),
('kids','/images/product_39.jpg','เสื้อกันหนาวคอตตอนถักลายแจ็คการ์ด','เสื้อกันหนาวผ้าคอตตอนถักแจ็คคาร์ดเนื้อนุ่ม กุ๊นผ้าริบรอบคอ ต่อผ้าริบที่ปลายแขนและชายเสื้อ', 8, 599.00,TRUE ),
('kids','/images/product_40.jpg','Wide denim-look trousers','Trousers in heavy, denim-look jersey with adjustable elastication at the waist, a fake fly, fake front pockets and wide legs', 8, 599.00,FALSE ),
('kids','/images/product_41.jpg','เสื้อคาร์ดิแกนผ้ายืดถักลาย','คาร์ดิแกนแขนยาวในผ้ายืดถักลาย คอกลม ติดกระดุมผ่าหน้า กุ๊นขอบซิกแซกที่ปลายแขนและชายเสื้อ', 8, 399.00,TRUE ),
('men','/images/product_42.jpg','Slim Fit Glittery polo shirt','Short-sleeved polo shirt in a fine knit containing shimmering, metallic threads with a collar and a small V-shaped opening at the top. Ribbed trim at the cuffs and hem. Slim fit that hugs the contours of your body, creating a fitted silhouette.', 8, 1099.00,FALSE ),
('men','/images/product_43.jpg','Regular Fit Sequined shirt','Shirt in a soft weave fully adorned with sequins featuring a turn-down collar, concealed button placket and a gently rounded hem. Long sleeves with buttoned cuffs and a sleeve placket. Regular fit for comfortable wear and a classic silhouette.', 8, 1999.00,TRUE ),
('men','/images/product_44.jpg','Regular Fit Twill shirt','Shirt in soft twill with a turn-down collar, French front and a yoke at the back. Long sleeves with buttoned cuffs and a sleeve placket with a link button. Rounded hem. Regular fit for comfortable wear and a classic silhouette.', 8, 799.00,FALSE ),
('women', '/images/product_45.jpg', 'เดรสผ้าเครป SKATER', 'เดรสคอวีและมีแขนยาว แต่งจีบตรงเอวและเย็บสม็อกด้านข้าง ชายทรงเอ ด้านหลังติดซิปซ่อนใต้ตะเข็บ', 9, 1990.00, TRUE),
('women', '/images/product_46.jpg', 'เดรสสั้นผ้าถัก', 'เดรสคอโปโลและแขนยาวเลยศอก ด้านหน้าติดกระดุมบุผ้าสีโทนเดียวกัน', 9, 2190.00, FALSE),
('women', '/images/product_47.jpg', 'กางเกงขาบานผ้าอินเตอร์ล็อค ลายตะเข็บ', 'กางเกงขายาวเอวสูงทำจากผ้าถักยืดและยืดหยุ่น เนื้อทอแน่น นุ่มฟู และทึบแสง เอวยางยืดปรับขนาดได้ด้วยเชือก แต่งตะเข็บด้านหน้า ชายขาบาน', 9, 1490.00, TRUE),
('kids', '/images/product_48.jpg', 'เสื้อทีเชิ้ตแขนแร็กแลนปักลาย', 'เสื้อทีเชิ้ตคอกลมแขนยาวสีตัด แต่งข้อความตรงหน้าอกและติดฉลากตรงด้านหลัง', 9, 590.00, TRUE),
('kids', '/images/product_49.jpg', 'เสื้อทีเชิ้ตคอเสื้อจับจีบ', 'เสื้อทีเชิ้ตคอบัวและแขนยาว ผ่ารูปหยดน้ำและติดกระดุมตรงด้านหลัง', 9, 790.00, FALSE),
('men', '/images/product_50.jpg', 'เสื้อเชิ้ตผ้าพลิ้ว', 'เสื้อเชิ้ต relaxed fit ทำจากผ้าวิสโคสผสม เสื้อเชิ้ตคอโบว์ลิ่งและแขนยาวข้อมือติดกระดุม ชายผ่าด้านข้าง ทรงสั้น ด้านหน้าติดชุดกระดุม', 9, 2490.00, TRUE),
('men', '/images/product_51.jpg', 'เสื้อเชิ้ตผ้าทอผิวไม่เรียบ', 'เสื้อเชิ้ต relaxed fit ทำจากผ้าทอผสมผ้าฝ้าย คอปกโบว์ลิ่งและแขนสั้น เปิดปิดด้านหน้าด้วยชุดกระดุม', 9, 1990.00, FALSE);

INSERT INTO brand (brandname, brandlogo) VALUES 
('bossini', '/images-logo/brand-bossini.jpg'),
('Champion', '/images-logo/brand-champion.png'),
('CPS', '/images-logo/brand-cps.jpg'),
('ELLE', '/images-logo/brand-elle.jpg'),
('GQ', '/images-logo/brand-gq.png'),
('Polo Ralph Lauren', '/images-logo/brand-polo.jpg'),
('Uniqlo', '/images-logo/brand-uniqlo.png'),
('H&M', '/images-logo/brand-hm.png'),
('Zara', '/images-logo/brand-zara.png');

INSERT INTO about_page (id,brand_id, img, title, description) VALUES 
(1, 1,'/images-about/brand_bossini4.jpg',
'Bossini International Holdings Limited 
และบริษัทย่อยเป็นเจ้าของแบรนด์เครื่องแต่งกาย ผู้ค้าปลีก และผู้ให้สิทธิ์แฟรนไชส์ 
​​โดยมีสำนักงานใหญ่อยู่ในฮ่องกงและมีตลาดหลักอยู่ในฮ่องกง จีนแผ่นดินใหญ่ 
ไต้หวัน ไทย และสิงคโปร์',
'ก่อตั้งโดย Law Ting-pong และเปิดตัวร้านค้าปลีกแห่งแรกในปี 1987 
ปัจจุบันมีสาขาเพิ่มขึ้นเป็น 938 แห่งทั่วโลก โดยเป็นการผสมผสานระหว่างร้านค้า
ที่บริหารจัดการโดยตรงและร้านค้าแฟรนไชส์ ​​กลุ่มบริษัทมีร้านค้าที่บริหารจัดการ
โดยตรง 257 แห่งในฮ่องกงจีนแผ่นดินใหญ่ไต้หวันและสิงคโปร์ 
พร้อมด้วยร้านค้าแฟรนไชส์อีก 81 แห่งใน จีนแผ่นดิน ใหญ่ กลุ่มบริษัทให้บริการ
ร้านค้าแฟรนไชส์รวมทั้งหมด 600 แห่งในอีกประมาณ 40 ประเทศ 
รวมถึงในเอเชียตะวันออกเฉียงใต้ตะวันออกกลางยุโรปและอเมริกากลาง'),

(2, 2, '/images-about/brand_champion2.jpg',
'Champion (มีชื่อเรียกอีกอย่างว่าChampion USA) 
เป็นแบรนด์เสื้อผ้าที่เชี่ยวชาญด้านชุดกีฬาซึ่งเป็นเจ้าของและทำการตลาด
โดยบริษัทเครื่องแต่งกายสัญชาติอเมริกัน Hanesbrands',
'บริษัทก่อตั้งขึ้นในปี 1919 โดยพี่น้อง Feinbloom ในชื่อ "Knickerbocker 
Knitting Company" บริษัทได้ลงนามข้อตกลงกับMichigan Wolverines
ในการผลิตชุดเครื่องแบบสำหรับทีมของพวกเขา ในช่วงทศวรรษปี 1930 
บริษัทได้เปลี่ยนชื่อเป็น "Champion Knitting Mills Inc." 
โดยผลิตเสื้อสเวตเตอร์และเสื้อฮู้ดหลังจากนั้นไม่นาน ผลิตภัณฑ์ Champion 
ก็ได้รับการนำไปใช้โดยสถาบันการทหารของสหรัฐฯเพื่อใช้ในการฝึกซ้อมและชั้นเรียนพลศึกษา'),

(3, 3, '/images-about/brand_CPS2.jpg',
'CPS CHAPS แบรนด์เสื้อผ้าและเครื่องแต่งกายแฟชั่นที่มีเอกลักษณ์โดดเด่นเฉพาะตัว 
ภายใต้คอนเซ็ปต์ “CREATIVITY. PASSION. SELF.” ที่เต็มไปด้วยพลังแห่งความสร้างสรรค์ 
และแรงบันดาลใจในการดีไซน์เสื้อผ้าให้ดูโดดเด่นและมีสไตล์ ',
'ก่อตั้งขึ้นในปี 2523 เริ่มต้นจากการจำหน่ายเฉพาะเสื้อเชิ้ตของผู้ชาย 
จากนั้นเราได้เริ่มขยายสินค้าดีไซน์เพิ่มมากขึ้น จนสามารถนำเสนอคอลเลกชั่น
อย่างครบถ้วนสำหรับผู้ชายได้ในปี 2533 และได้มีการเปิดตัวคอลเลกชั่นผู้หญิงในปี 2537.'),

(4, 4, '/images-about/brand_elle2.jpg',
'ELLE Magazine Thailand นิตยสารแฟชั่นรายเดือนหัวนอกสำหรับผู้หญิง',
'ก่อตั้งขึ้นโดย เฮเลน่า ลาซาเรฟฟ์ (Hélène Lazareff) เมื่อ 21 พฤศจิกายน ปี ค.ศ. 1945 
 ที่ประเทศฝรั่งเศส ด้วยเจตนารมณ์ในการเป็นกระบอกเสียงให้ผู้หญิง
 หลังจากนั้นในยุค 80’s ELLE กลายเป็นแบรนด์ระดับโลกที่มีคอลเลคชั่น Ready-to-wear 
 เปิดตัวครั้งแรกในญี่ปุ่น และนี่เป็นเพียงจุดเริ่มต้น หลังจากนั้นสำหรับ ELLE คือทุกสิ่งทุกอย่าง 
 คือสไตล์ที่แฝงอยู่ในทุกช่วงชีวิตหญิงสาว ตั้งแต่วิถีชีวิต การท่องเที่ยว รสนิยมทางดนตรี ศิลปะ 
 อาหาร รถยนต์ หรือแม้กระทั่งเทคโนโลยี ในยุค 80’s ELLE ได้เปิดตัวคอลเลคชั่นเสื้อผ้า 
 ready-to-wear ครั้งแรกที่ญี่ปุ่น และนี่คือจุดเริ่มต้นที่ทำให้ ELLE เป็นมากกว่าแค่นิตยสาร'),

(5, 5, '/images-about/brand_GQ2.jpg','GQ เป็นแบรนด์เสื้อผ้าจากประเทศไทย',
'ก่อตั้งขึ้นเมื่อปี 1969 ซึ่งถือเป็นเจ้าแรก ๆ ที่ผลิตเสื้อผ้าสำเร็จรูปพร้อมใส่
สำหรับผู้ชายในเมืองไทย มีสินค้าพระเอกคือเสื้อโปโลที่ทำจากผ้าฝ้ายชุบ 
ใส่สบายระบายความร้อนได้ดี เหมาะกับอากาศเมืองไทย ซึ่งถูกจริตวัยรุ่นยุคนั้น
อย่างไรก็ตาม นั่นคือเรื่องราวความสำเร็จในอดีต…ที่ไม่ได้ต่อยอดสู่ปัจจุบัน 
เพราะแบรนด์ไม่ได้ทำการตลาดมากนัก ไม่ได้ขยายฐานลูกค้า อาศัยลูกค้าประจำเก่า ๆ 
และไม่ได้คิดค้นนวัตกรรมเสื้อผ้าใหม่ ๆ เมื่อเวลาดำเนินมาถึงยุคปัจจุบันที่มีแบรนด์เสื้อผ้าระดับโลกมากมายเข้ามาแข่งขันในเมืองไทย 
ทำให้ชื่อของ GQ กลายเป็นความทรงจำในอดีตที่ไม่ได้อยู่ในสารบบของวัยรุ่นยุคใหม่ 
และวัยรุ่นยุคเก่าในวันวาน…มาวันนี้ก็กลายเป็นผู้ใหญ่ชราเต็มตัวแล้ว
แบรนด์จึงเหมือนอยู่กับที่ คือ ‘พออยู่ได้’ แต่ก็ไม่โตมากไปกว่านี้แล้ว…จนเมื่อมาถึงรุ่นลูก');

(6, 6, '/images-about/brand_GQ2.jpg','MDs’ STYLE | Ralph Lauren บุรุษผู้เป็น Icon แห่งวงการ Fashion และโลกที่ไม่มีวันล้าสมัย',
'ในปี 1968 คุณ Ralph ได้เริ่มต้นแบรนด์ชื่อว่า Polo และมี Showroom เล็กๆ ในตึก Empire State ซึ่งตัวเขาเองนอกจากเป็นผู้ออกแบบแล้ว 
ยังเป็นทั้ง Cashier และ Delivery Man อีกด้วย ด้วยความที่ Ralph Lauren เป็นผู้ชื่นชอบ เสื้อ ผ้าแนว Classic Menswear เป็นทุนเดิม 
เริ่มต้นตั้งแต่การวางขาย Necktie เส้นใหญ่เป็นพิเศษ ตั้งแต่ยุคสมัยที่ไม่มีใครสนใจ การออกแบบเสื้อผ้า จึงพยายามลอกแบบจากสไตล์ผู้ดีอังกฤษเป็นหลัก 
ถึงแม้ว่าจะไม่มีพื้นฐานด้านการออกแบบมาก่อนเลยก็ตาม จนในปี 1969 แบรนด์ เสื้อ Polo ก็ได้พื้นที่ในร้าน Bloomingdale 
ซึ่งถือเป็นครั้งแรกที่ทางร้านยอมให้แบรนด์อื่นเข้ามาวางขายเลยด้วย ก่อนจะขยายไปยังเสื้อผ้าสตรีในปี 1971 ซึ่งถือเป็นเรื่องใหม่มากในวงการนักออกแบบเสื้อผ้าชาวอเมริกัน 
พร้อมกับเปิด Shop Stand Alone แห่งแรกบนถนน Rodeo Drive ใน Beverly Hills
ในปี 1972 คือปีที่ Ralph Lauren ได้ออกแบบเสื้อเชิ้ต Cotton ที่มีโลโก้ Polo ปักอยู่ที่ปกเสื้อ 
จนกลายเป็น Signature Shirts ของแบรนด์จวบจนทุกวันนี้ และไม่ได้'),

(7, 7, '/images-about/brand_GQ2.jpg','Uniqlo แบรนด์เสื้อมินิมอล เบอร์ต้นๆ ที่รู้จักกันทั่วโลก',
'ก่อตั้งขึ้นในปีค.ศ. 1984 หรือ พ.ศ. 2527 ที่ประเทศญี่ปุ่น โดยเริ่มแรกเดิมทีนั้นไม่ได้ใช้ชื่อนี้ เพราะเป็นเพียงร้านเสื้อผ้าขนาดเล็กที่ชื่อว่า 
Unique Clothing Warehouse ในเมือง Hiroshima (ฮิโรชิมะ) นั่นคือจุดเริ่มต้นก่อนที่จะได้ขยายธุรกิจอย่างต่อเนื่อง 
จนกลายเป็นแบรนด์เสื้อผ้าระดับโลกที่เราต่างก็รู้จักกันดีในเรื่องของ “เสื้อผ้าคุณภาพดีในราคาที่จับต้องได้” โดยมีแนวคิดหลักคือ “LifeWear”
 ซึ่งหมายถึงเสื้อผ้าที่ตอบสนองความต้องการในชีวิตประจำวันของผู้คน เป็นจุดยืนของแบรนด์ยูนิโคล่ที่คงคอนเซ็ปต์ไม่ว่าใครก็ใส่แบรนด์นี้ได้'),

(8, 8, '/images-about/brand_GQ2.jpg','H&M จุดแข็งของแบรนด์เสื้อผ้า “แฟชั่น” ที่เข้าถึงง่าย',
'H&M หรือชื่อเต็มอย่าง Hennes & Mauritz เป็นแบรนด์แฟชั่นสัญชาติสวีเดน ก่อตั้งขึ้นในปี 1947 
โดยตอนแรกได้เริ่มจากร้านขายเสื้อผ้าสำหรับผู้หญิงโดยใช้ชื่อว่า Hennes แต่ต่อมาได้ขยายธุรกิจไปสู่การขายเสื้อผ้าสำหรับผู้ชายและเด็กด้วย 
จึงเปลี่ยนชื่อเป็น Hennes & Mauritz ทำให้เกิดตัวย่อจนคนพูดชื่อติดปากกันว่า H&M ในเวลาต่อมา แนวคิดในการดำเนินธุรกิจของ H&M 
คือการนำเสนอแฟชั่นและคุณภาพในราคาคุ้มค่าด้วยวิธีการที่ยั่งยืน'),

(9, 9, '/images-about/brand_GQ2.jpg','ZARA แบรนด์เสื้อที่ขึ้นแท่น ราชินีแห่งแฟชั่น Fast Fashion',
'ก่อตั้งขึ้นในปี 1975 โดย Amancio Ortega (อามันซิโอ ออร์เตกา) ชาวสเปน ที่เมือง A Coruña (ลาโครูนา) ประเทศสเปน โดยเริ่มแรกของแบรนด์ ZARA 
นั้นก็เป็นเพียงร้านค้าเล็กๆ ที่จำหน่ายเสื้อผ้าเลียนแบบดีไซน์จากแบรนด์หรู แต่ด้วย “ความสามารถในการผลิตเสื้อผ้าจำนวนมากในเวลาอันรวดเร็ว” 
 และนำเสนอเทรนด์ใหม่ๆ ได้ทันเหตุการณ์ติดเทรนด์ ณ ขณะนั้น จึงเป็นเหตุผลที่ทำให้แบรนด์ซาร่าเติบโตอย่างรวดเร็ว 
 และกลายเป็นหนึ่งในแบรนด์แฟชั่นที่ใหญ่ที่สุดในโลกในปัจจุบัน เกร็ดเล็กๆ ที่แอดอยากบอกต่อคือ อามันซิโอ ออร์เตกา เจ้าของแบรนด์ซาร่า 
 เป็นบุคคลที่รวยที่สุดใน “สเปน” และเป็นเศรษฐีอันดับ 6 ของโลก ในปี 2019');

INSERT INTO branch (brand_id, province, banch, banch_location) VALUES 
(1, 'กรุงเทพมหานคร', 'Central Bangna (เซ็นทรัล บางนา)', 'ชั้น 2'),
(1, 'กรุงเทพมหานคร', 'Seacon Square (ซีคอนสแควร์)', 'โซนโรบินสันชั้น 2'),
(1, 'กรุงเทพมหานคร', 'Centralworld (เซ็นทรัลเวิลด์)', 'ชั้น 3'),
(1, 'นนทบุรี', 'Outlet Square Muang Thong Thani (เมืองทองธานี)', 'ชั้น 2'),
(1, 'กรุงเทพมหานคร', 'Siam Premium Outlets Bangkok (สยาม พรีเมี่ยม เอาท์เล็ต กรุงเทพ)', 'ประตู G ห้อง: G122B'),
(1, 'กรุงเทพมหานคร', 'Central Village Suvarnabhumi (เซ็นทรัล วิลเลจ สุวรรณภูมิ)', 'Zone C NO. C122'),
(1, 'นครราชสีมา', 'Terminal 21 Korat (เทอมินอล 21 โคราช)', 'ชั้น G'),
(1, 'นครราชสีมา', 'The Mall Korat (เดอะมอลล์ โคราช)', 'ชั้น 1 โซน Ladies Boutique'),
(1, 'นครราชสีมา', 'Premium Outlet Khao-Yai (พรีเมี่ยม เอาท์เล็ท เขาใหญ่)', 'ชั้น G'),
(1, 'ชลบุรี', 'Outlet mall Pattaya (เอาท์เล็ทมอลล์ พัทยา)', 'TIMBERLAND Outlet Store พัทยา'),
(2, 'กรุงเทพมหานคร', 'ICONSIAM (ไอคอนสยาม)', 'ชั้น 1'),
(2, 'กรุงเทพมหานคร', 'Centralworld (เซ็นทรัลเวิลด์)', 'ชั้น 3 โซน Atrium'),
(2, 'กรุงเทพมหานคร', 'Mega Bangna (เมกาบางนา)', 'ชั้น 1'),
(2, 'กรุงเทพมหานคร', 'Terminal 21 Asok (เทอร์มินอล 21 อโศก)', 'ชั้น 2'),
(2, 'กรุงเทพมหานคร', 'Central Village Suvarnabhumi (เซ็นทรัล วิลเลจ สุวรรณภูมิ)', 'ล็อก F117'),
(2, 'กรุงเทพมหานคร', 'Siam Premium Outlets Bangkok (สยาม พรีเมี่ยม เอาท์เล็ต กรุงเทพ)', 'ประตู F ห้อง: G41'),
(2, 'กรุงเทพมหานคร', 'Zpell (สเปลล์)', 'ชั้น 2'),
(2, 'กรุงเทพมหานคร', 'JD Sports ICONSIAM (เจดี สปอร์ต ไอคอนสยาม)', 'ชั้น 2 และ ชั้น 3'),
(2, 'กรุงเทพมหานคร', 'JD Sports Siam Center (เจดี สปอร์ต สยามเซ็นเตอร์)', 'ชั้น G'),
(2, 'กรุงเทพมหานคร', 'JD Sports Mega Bangna (เจดี สปอร์ต เมกาบางนา)', 'ชั้น 1'),
(2, 'กรุงเทพมหานคร', 'JD Sports Terminal 21 Asok (เจดี สปอร์ต เทอร์มินอล 21 อโศก)', 'ชั้น 1'),
(2, 'กรุงเทพมหานคร', 'Sports Mall Siam Paragon (สปอร์ตส์ มอลล์ สยามพารากอน)', 'ชั้น 2'),
(2, 'กรุงเทพมหานคร', 'Sports Mall Emporium (สปอร์ต มอลล์ เอ็มโพเรียม)', 'ชั้น 2'),
(2, 'กรุงเทพมหานคร', 'Sports Mall The Mall Ngamwongwan (สปอร์ต มอลล์ เดอะมอลล์ งามวงศ์วาน)', 'ชั้น 3'),
(2, 'กรุงเทพมหานคร', 'Fashion Island (แฟชั่นไอส์แลนด์)', 'ชั้น G'),
(2, 'กรุงเทพมหานคร', 'Siam Center (สยามเซ็นเตอร์)', 'ชั้น M Fl'),
(2, 'กรุงเทพมหานคร', 'Terminal 21 Rama 3 (เทอร์มินอล 21 พระราม 3)', 'ชั้น G'),
(2, 'ขอนแก่น', 'Central Khonkaen (เซ็นทรัล ขอนแก่น)', 'ชั้น 2'),
(2, 'เชียงใหม่', 'Central Chiang Mai Airport (เซ็นทรัล เชียงใหม่ แอร์พอร์ต)', 'ชั้น 2'),
(2, 'เชียงใหม่', 'Central Chiang Mai (เซ็นทรัล เชียงใหม่)', 'ชั้น 3'),
(2, 'ชลบุรี', 'Terminal 21 Pattaya (เทอร์มินอล 21 พัทยา)', 'ชั้น G'),
(2, 'สงขลา', 'Central Hat Yai (เซ็นทรัล หาดใหญ่)', 'ชั้น 2'),
(3, 'กรุงเทพมหานคร', 'Central Bangna (เซ็นทรัล บางนา)', 'ชั้น 2'),
(3, 'กรุงเทพมหานคร', 'Mega Bangna (เมกาบางนา)', 'ชั้น 1'),
(3, 'กรุงเทพมหานคร', 'Central Rama 3 (เซ็นทรัล พระราม 3)', 'ชั้น 2'),
(3, 'กรุงเทพมหานคร', 'Central Ladprao (เซ็นทรัล ลาดพร้าว)', 'ชั้น 2'),
(3, 'กรุงเทพมหานคร', 'Siam Center (สยามเซ็นเตอร์)', 'ชั้น G'),
(3, 'กรุงเทพมหานคร', 'Centralworld (เซ็นทรัลเวิลด์)', 'ชั้น 2'),
(3, 'กรุงเทพมหานคร', 'CentralPlaza Pinklao (เซ็นทรัลพลาซา ปิ่นเกล้า)', 'ชั้น 1'),
(3, 'กรุงเทพมหานคร', 'The Mall Bangkapi (เดอะมอลล์ บางกะปิ)', 'ชั้น 1'),
(3,'กรุงเทพมหานคร', 'Fashion Island (แฟชั่นไอส์แลนด์)', 'ชั้น 1'),
(3,'กรุงเทพมหานคร', 'CentralPlaza Rama 2 (เซ็นทรัลพลาซา พระราม 2)', 'ชั้น 1'),
(3,'นนทบุรี', 'CentralPlaza Chaengwattana (เซ็นทรัลพลาซา แจ้งวัฒนะ)', 'ชั้น 1'),
(3,'กรุงเทพมหานคร', 'CentralPlaza Rama 9 (เซ็นทรัลพลาซา พระราม 9)', 'ชั้น 1'),
(3,'นครปฐม', 'CentralPlaza Salaya (เซ็นทรัลพลาซา ศาลายา)', 'ชั้น 1'),
(3,'นนทบุรี', 'CentralPlaza Westgate (เซ็นทรัลพลาซา เวสต์เกต)', 'ชั้น 3'),
(3,'ปทุมธานี', 'Zpell at Future Park Rungsit (สเปลล์ แอท ฟิวเจอร์พาร์ค รังสิต)', 'ชั้น G'),
(3,'กรุงเทพมหานคร', 'ICONSIAM (ไอคอนสยาม)', 'ชั้น 1'),
(3,'กรุงเทพมหานคร', 'Online (ออนไลน์)', '1054 ซอย สุขุมวิท 66/1 ถนน สุขุมวิท'),
(3,'กรุงเทพมหานคร', 'Sukhumvit (สุขุมวิท)', 'คลังสินค้า บริษัท ยัสปาล จำกัด ชั้น 1 ซอยสุขุมวิท 66/1'),
(3,'กรุงเทพมหานคร', 'Seacon Square Srimakarin (ซีคอนสแควร์ ศรีนครินทร์)', 'ชั้น 1'),
(3,'ปทุมธานี', 'Future Park Rungsit (สเปลล์ แอท ฟิวเจอร์พาร์ค รังสิต)', 'ชั้น B'),
(3,'กรุงเทพมหานคร', 'Terminal 21 Asok (เทอร์มินอล 21 อโศก)', 'ชั้น M'),
(3,'นครปฐม', 'Central Nakhon Pathom (เซ็นทรัล นครปฐม)', 'ชั้น 1'),
(3,'อยุธยา', 'Central Ayuttaya (เซ็นทรัล อยุธยา)', 'G Floor 129/1, 129/2, 129/3'),
(3,'นครสวรรค์', 'Central Nakhon Sawan (เซ็นทรัล นครสวรรค์)', 'ชั้น G'),
(3,'นครราชสีมา', 'The mall Korat (เดอะมอลล์ โคราช)', 'ชั้น 1'),
(3,'ขอนแก่น', 'Central Khonkaen (เซ็นทรัล ขอนแก่น)', 'ชั้น 1'),
(3,'อุดรธานี', 'CentralPlaza Udonthani (เซ็นทรัลพลาซา อุดรธานี)', 'ชั้น 1'),
(3,'อุบลราชธานี', 'CentralPlaza Ubonratchathani (เซ็นทรัลพลาซา อุบลราชธานี)', 'ชั้น 1'),
(3,'นครราชสีมา', 'CentralPlaza Nakhon Ratchasima (เซ็นทรัลพลาซา นครราชสีมา)', 'ชั้น 1'),
(3,'เชียงราย', 'CentralPlaza Nakhon Chiang Rai (เซ็นทรัลพลาซา เชียงราย)', 'ชั้น 1'),
(3,'พิษณุโลก', 'CentralPlaza Pisanulok (เซ็นทรัลพลาซา พิษณุโลก)', 'ชั้น 1'),
(3,'ลำปาง', 'CentralPlaza Lampang (เซ็นทรัลพลาซา ลำปาง)', 'ชั้น 1'),
(3,'เชียงใหม่', 'CentralFestival Chiangmai (เซ็นทรัลเฟสติวัล เชียงใหม่)', 'ชั้น 1'),
(3,'ชลบุรี', 'CentralFestival Pattaya Beach (เซ็นทรัลเฟสติวัล พัทยา บีช)', 'ชั้น 1'),
(3,'ชลบุรี', 'CentralPlaza Chonburi (เซ็นทรัลพลาซา ชลบุรี)', 'ชั้น 1'),
(3,'ระยอง', 'Passione Shopping Destination (แพชชั่น ช็อปปิ้ง เดสติเนชั่น)', 'FS1-008 F-Shop Zone'),
(3,'ระยอง', 'CentralPlaza Rayong (เซ็นทรัลพลาซา ระยอง)', 'ชั้น 1'),
(3,'ประจวบคีรีขันต์', 'Bluport Huahin (บลูพอร์ต หัวหิน)', 'ชั้น 1'),
(3,'ภูเก็ต', 'CentralFestival Phuket (เซ็นทรัล ภูเก็ต)', 'ชั้น 1'),
(3,'สุราษฎร์ธานี', 'CentralPlaza Suratthani (เซ็นทรัลพลาซา สุราษฎร์ธานี)', 'ชั้น 1'),
(3,'ภูเก็ต', 'Jungceylon Shopping Center (จังซีลอน)', 'ชั้น G'),
(3,'สงขลา', 'CentralFestival Hatyai (เซ็นทรัลเฟสติวัล หาดใหญ่)', 'ชั้น 1'),
(3,'นครศรีธรรมราช', 'CentralPlaza Nakhon Si Thammarat (เซ็นทรัลพลาซา นครศรีธรรมราช)', 'ชั้น 1'),
(4, 'กรุงเทพมหานคร', 'Central Chidlom (เซ็นทรัล ชิดลม)', 'ชั้น G'),
(4, 'กรุงเทพมหานคร', 'Central Silom Complex (เซ็นทรัล สีลม คอมเพล็กซ์)', 'ชั้น 3'),
(4, 'กรุงเทพมหานคร', 'CentralwOrld (เซ็นทรัลเวิลด์)', 'ชั้น 5'),
(4, 'กรุงเทพมหานคร', 'Robinson Fashion Island (โรบินสัน แฟชั่นไอส์แลนด์)', 'ชั้น G'),
(4, 'กรุงเทพมหานคร', 'Robinson Sukhumvit (โรบินสัน สุขุมวิท)', '259 ถนนสุขุมวิท'),
(4, 'กรุงเทพมหานคร', 'Robinson Bangrak (โรบินสัน บางรัก)', 'ชั้น G'),
(4, 'กรุงเทพมหานคร', 'Robinson Seacon Bangkae (โรบินสัน ซีคอน บางแค)', 'ชั้น 1'),
(4, 'กรุงเทพมหานคร', 'Siam Paragon (สยามพารากอน)', 'ชั้น 2 แผนกเสื้อผ้าบุรุษ'),
(4, 'ปทุมธานี', 'Central Future Park Rangsit (เซ็นทรัล ฟิวเจอร์พาร์ค รังสิต)', 'ชั้น G'),
(4, 'ปทุมธานี', 'Robinson Future Park Rangsit (โรบินสัน ฟิวเจอร์พาร์ค รังสิต)', 'ชั้น 2'),
(4, 'นนทบุรี', 'Central WestGate (เซ็นทรัล เวสต์เกต)', 'ชั้น 3'),
(4, 'นนทบุรี', 'CentralPlaza Chaengwattana (เซ็นทรัลพลาซา แจ้งวัฒนะ)', 'ชั้น 4'),
(4, 'นนทบุรี', 'Robinson Srisamarn (โรบินสัน ศรีสมาน)', 'ชั้น 1'),
(4, 'นครปฐม', 'CentralPlaza Salaya (เซ็นทรัลพลาซา ศาลายา)', 'ชั้น 1'),
(4, 'สมุทรสาคร', 'Robinson CentralPlaza Mahachai (โรบินสัน เซ็นทรัลพลาซา มหาชัย)', 'ชั้น 2'),
(4, 'กรุงเทพมหานคร', 'Robinson Lifestyle Lardkrabang (โรบินสัน ไลฟ์สไตล์ ลาดกระบัง)', 'ชั้น 1'),
(4, 'กรุงเทพมหานคร', 'Robinson Seacon Square (โรบินสัน ซีคอนสแควร์)', 'ชั้น 1'),
(4, 'สมุทรปราการ', 'Robinson Lifestyle Samutprakan (โรบินสัน ไลฟ์สไตล์ สมุทรปราการ)', 'ชั้น 2'),
(4, 'กรุงเทพมหานคร', 'Central Bangna (เซ็นทรัล บางนา)', 'ชั้น 3'),
(4, 'กรุงเทพมหานคร', 'Central Village Suvarnabhumi (เซ็นทรัล วิลเลจ สุวรรณภูมิ)', 'Brick Village Zone'),
(4, 'นนทบุรี', 'Central Westville (เซ็นทรัล เวสต์วิลล์)', 'ชั้น 1'),
(4, 'นนทบุรี', 'Robinson Ratchaphruek (โรบินสัน ราชพฤกษ์)', 'ชั้น 1'),
(4, 'กรุงเทพมหานคร', 'Central Rama 2 (เซ็นทรัล พระราม 2)', 'ชั้น 1'),
(4, 'กรุงเทพมหานคร', 'Central Rama 3 (เซ็นทรัล พระราม 3)', 'ชั้น 1'),
(4, 'ปทุมธานี', 'Future Park Rangsit (ฟิวเจอร์พาร์ค รังสิต)', 'ชั้น 2'),
(4, 'กรุงเทพมหานคร', 'Central Pinklao (เซ็นทรัล ปิ่นเกล้า)', 'ชั้น 2'),
(4, 'กรุงเทพมหานคร', 'Robinson Rama 9 (โรบินสัน พระราม 9)', 'ชั้น G'),
(4, 'ลพบุรี', 'Robinson Lifestyle Lopburi (โรบินสัน ไลฟ์สไตล์ ลพบุรี)', 'ชั้น 1'),
(4, 'พระนครศรีอยุธยา', 'Robinson Ayutthaya (โรบินสัน พระนครศรีอยุธยา)', 'ชั้น 1'),
(4, 'สระบุรี', 'Robinson Lifestyle Saraburi (โรบินสัน ไลฟ์สไตล์ สระบุรี)', 'ชั้น 1'),
(4, 'ชัยภูมิ', 'Robinson Lifestyle Chaiyaphum (โรบินสัน ไลฟ์สไตล์ ชัยภูมิ)', 'ชั้น 1'),
(4, 'บุรีรัมย์', 'Robinson Lifestyle Buriram (โรบินสัน ไลฟ์สไตล์ บุรีรัมย์)', 'ชั้น 1'),
(4, 'สุรินทร์', 'Robinson Lifestyle Surin (โรบินสัน ไลฟ์สไตล์ สุรินทร์)', 'ชั้น 1'),
(4, 'มุกดาหาร', 'Robinson Lifestyle Mukdahan (โรบินสัน ไลฟ์สไตล์ มุกดาหาร)', 'ชั้น 1'),
(4, 'สกลนคร', 'Robinson Lifestyle Sakonnakhon (โรบินสัน ไลฟ์สไตล์ สกลนคร)', 'ชั้น 1'),
(4, 'ร้อยเอ็ด', 'Robinson Lifestyle RoiEt (โรบินสัน ไลฟ์สไตล์ ร้อยเอ็ด)', 'ชั้น 1'),
(4, 'ขอนแก่น', 'Robinson CentralPlaza khonkaen (โรบินสัน เซ็นทรัลพลาซา ขอนแก่น)', 'ชั้น 1'),
(4, 'ขอนแก่น', 'Central Khon Kaen (เซ็นทรัล ขอนแก่น)', 'ชั้น 3'),
(4, 'อุดรธานี', 'Central Udon Thani (เซ็นทรัล อุดรธานี)', 'ชั้น 2'),
(4, 'อุบลราชธานี', 'Robinson Ubon Ratchathani (โรบินสัน อุบลราชธานี)', 'ชั้น 2'),
(4, 'เชียงใหม่', 'Robinson CentralPlaza Chiangmai Ariport (โรบินสัน เซ็นทรัลพลาซา เชียงใหม่ แอร์พอร์ต)', 'ชั้น 3'),
(4, 'เชียงราย', 'Robinson CentralPlaza Chiangrai (โรบินสัน เซ็นทรัลพลาซา เชียงราย)', 'ชั้น 1'),
(4, 'พะเยา', 'Robinson Phapao (โรบินสัน พะเยา)', 'ชั้น 1'),
(4, 'ลำปาง', 'Robinson CentralPlaza Lampang (โรบินสัน เซ็นทรัลพลาซา ลำปาง)', 'ชั้น 2'),
(4, 'ลำปาง', 'Seri Department Store Lampang (เสรีสรรพสินค้า ลำปาง)', 'ชั้น 1'),
(4, 'กำแพงเพชร', 'Robinson Lifestyle Kampheangphen (โรบินสัน ไลฟ์สไตล์ กำแพงเพชร)', 'ชั้น 1'),
(4, 'พิษณุโลก', 'Robinson CentralPlaza Phitsanulok (โรบินสัน เซ็นทรัลพลาซา พิษณุโลก)', 'ชั้น 2'),
(4, 'ปราจีนบุรี', 'Robinson Lifestyle Prachinburi (โรบินสัน ไลฟ์สไตล์ ปราจีนบุรี)', 'ชั้น 1'),
(4, 'สุพรรณบุรี', 'Robinson Lifestyle Suphanburi (โรบินสัน ไลฟ์สไตล์ สุพรรณบุรี)', 'ชั้น 1'),
(4, 'เชียงใหม่', 'Central Chiangmai (เซ็นทรัล เชียงใหม่)', 'ชั้น 2'),
(4, 'ชลบุรี', 'CentralFeatival Pattaya Beach (เซ็นทรัลเฟสติวัล พัทยา บีช)', 'ชั้น'),
(5, 'กรุงเทพมหานคร', 'Online (ออนไลน์)', 'เซ็นทรัล ชิดลม ถนนเพลินจิต'),
(5, 'กรุงเทพมหานคร', 'Central Chidlom (เซ็นทรัล ชิดลม)', 'ชั้น G'),
(5, 'กรุงเทพมหานคร', 'Central Silom Complex (เซ็นทรัล สีลม คอมเพล็กซ์)', 'ชั้น 3'),
(5, 'กรุงเทพมหานคร', 'CentralwOrld (เซ็นทรัลเวิลด์)', 'ชั้น 5'),
(5, 'กรุงเทพมหานคร', 'Robinson Fashion Island (โรบินสัน แฟชั่นไอส์แลนด์)', 'ชั้น G'),
(5, 'กรุงเทพมหานคร', 'Robinson Sukhumvit (โรบินสัน สุขุมวิท)', '259 ถนนสุขุมวิท'),
(5, 'กรุงเทพมหานคร', 'Robinson Bangrak (โรบินสัน บางรัก)', 'ชั้น G'),
(5, 'กรุงเทพมหานคร', 'Robinson Seacon Bangkae (โรบินสัน ซีคอน บางแค)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'The Mall Bangkae (เดอะมอลล์ บางแค)', 'ชั้น 2'),
(5, 'กรุงเทพมหานคร', 'The Mall Bangkapi (เดอะมอลล์ บางกะปิ)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'The Mall Thapra (เดอะมอลล์ ท่าพระ)', 'ชั้น 2'),
(5, 'กรุงเทพมหานคร', 'Siam Paragon (สยามพารากอน)', 'ชั้น 2 แผนกเสื้อผ้าบุรุษ'),
(5, 'กรุงเทพมหานคร', 'The Mall Ramkhamhaeng (เดอะมอลล์ รามคำแหง)', 'ชั้น 2'),
(5, 'กรุงเทพมหานคร', 'Siam Takashimaya (สยามทาคาชิมาย่า)', 'ชั้น G'),
(5, 'กรุงเทพมหานคร', 'PATA Pinklao (พาต้า ปิ่นเกล้า)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Tanghuaseng (ตั้งฮั่วเส็ง ธนบุรี)', 'ชั้น 2'),
(5, 'กรุงเทพมหานคร', 'Big C Rajdamri (บิ๊กซี ราชดำริ)', '97/11 ถนนราชดำริห์'),
(5, 'ปทุมธานี', 'Central Future Park Rangsit (เซ็นทรัล ฟิวเจอร์พาร์ค รังสิต)', 'ชั้น G'),
(5, 'ปทุมธานี', 'Robinson Future Park Rangsit (โรบินสัน ฟิวเจอร์พาร์ค รังสิต)', 'ชั้น 2'),
(5, 'นนทบุรี', 'Central WestGate (เซ็นทรัล เวสต์เกต)', 'ชั้น 3'),
(5, 'นนทบุรี', 'CentralPlaza Chaengwattana (เซ็นทรัลพลาซา แจ้งวัฒนะ)', 'ชั้น 4'),
(5, 'นนทบุรี', 'Robinson Srisamarn (โรบินสัน ศรีสมาน)', 'ชั้น 1'),
(5, 'นนทบุรี', 'The Mall Ngamwongwan (เดอะมอลล์ งามวงศ์วาน)', 'ชั้น 2'),
(5, 'นครปฐม', 'Srinakorn Nakhon Pathom (ศรีนคร นครปฐม)', 'ชั้น 1'),
(5, 'นครปฐม', 'Charoendee Nakhon Pathom (เจริญดี นครปฐม)', 'ชั้น 1'),
(5, 'นครปฐม', 'CentralPlaza Salaya (เซ็นทรัลพลาซา ศาลายา)', 'ชั้น 1'),
(5, 'สมุทรสาคร', 'Robinson CentralPlaza Mahachai (โรบินสัน เซ็นทรัลพลาซา มหาชัย)', 'ชั้น 2'),
(5, 'สมุทรสาคร', 'Yuri House Mahachai (ยูริ เฮ้าส์ มหาชัย)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Siam Premium Outlets Bangkok (สยาม พรีเมี่ยม เอาท์เล็ต กรุงเทพ)', 'ชั้น 2'),
(5, 'กรุงเทพมหานคร', 'Robinson Lifestyle Lardkrabang (โรบินสัน ไลฟ์สไตล์ ลาดกระบัง)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Robinson Seacon Square (โรบินสัน ซีคอนสแควร์)', 'ชั้น 1'),
(5, 'สมุทรปราการ', 'Robinson Lifestyle Samutprakan (โรบินสัน ไลฟ์สไตล์ สมุทรปราการ)', 'ชั้น 2'),
(5, 'สมุทรปราการ', 'Imperial World Samrong (อิมพีเรียลเวิลด์ สำโรง)', 'ชั้น 3'),
(5, 'กรุงเทพมหานคร', 'Fashion Island (แฟชั่นไอส์แลนด์)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Sukhumvit 35 (สุขุมวิท 35)', 'ชั้น 2'),
(5, 'กรุงเทพมหานคร', 'BTS Ari (บีทีเอส อารีย์)', 'WERK BTS Ari'),
(5, 'กรุงเทพมหานคร', 'ICONSIAM (ไอคอนสยาม)', 'ชั้น 5'),
(5, 'กรุงเทพมหานคร', 'Central Bangna (เซ็นทรัล บางนา)', 'ชั้น 3'),
(5, 'กรุงเทพมหานคร', 'Supara Rama 4 Road (สุภารา ถนนพระราม 4)', 'ชั้น 2'),
(5, 'นนทบุรี', 'Outlet Square Muang Thong Thani (เมืองทองธานี)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Phromphong (พร้อมพงษ์)', '597 ถ. สุขุมวิท'),
(5, 'กรุงเทพมหานคร', 'Central Village Suvarnabhumi (เซ็นทรัล วิลเลจ สุวรรณภูมิ)', 'Brick Village Zone'),
(5, 'นนทบุรี', 'Central Westville (เซ็นทรัล เวสต์วิลล์)', 'ชั้น 1'),
(5, 'นนทบุรี', 'Robinson Ratchaphruek (โรบินสัน ราชพฤกษ์)', 'ชั้น 1'),
(5, 'นนทบุรี', 'Lotus Bang Kruai-Sai Noi (โลตัส บางกรวย-ไทรน้อย)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Central Rama 2 (เซ็นทรัล พระราม 2)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Central Rama 3 (เซ็นทรัล พระราม 3)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Lotus Rama 4 (โลตัส พระราม 4)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Siam Premium Outlets Bangkok (สยาม พรีเมี่ยม เอาท์เล็ต กรุงเทพ)', '-'),
(5, 'กรุงเทพมหานคร', 'Seacon Bangkae (ซีคอน บางแค)', '-'),
(5, 'กรุงเทพมหานคร', 'Lotus Sukhumvit 50 (โลตัส สุขุมวิท 50)', 'ชั้น 2'),
(5, 'ปทุมธานี', 'Future Park Rangsit (ฟิวเจอร์พาร์ค รังสิต)', 'ชั้น 2'),
(5, 'นนทบุรี', 'Cosmo Bazaar Muang Thong Thani (คอสโม บาซาร์ เมืองทองธานี)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Seacon Square Srinagarindra (ซีคอน สแควร์ ศรีนครินทร์)', '-'),
(5, 'กรุงเทพมหานคร', 'Don Mueang Airport (ท่าอากาศยานดอนเมือง)', 'อาคารผู้โดยสารอาคาร 2'),
(5, 'กรุงเทพมหานคร', 'Mega Bangna (เมกาบางนา)', 'ชั้น 1'),
(5, 'กรุงเทพมหานคร', 'Central Pinklao (เซ็นทรัล ปิ่นเกล้า)', 'ชั้น 2'),
(5, 'กรุงเทพมหานคร', 'MBK Center (เอ็มบีเค เซ็นเตอร์)', 'ชั้น 3 โซน A'),
(5, 'กรุงเทพมหานคร', 'MBK Center (เอ็มบีเค เซ็นเตอร์)', 'ชั้น 3 โซน B'),
(5, 'กรุงเทพมหานคร', 'Robinson Rama 9 (โรบินสัน พระราม 9 )', 'ชั้น G'),
(5, 'พิจิตร', 'Chaiyapong Plaza (ชัยพงษ์ พลาซ่า)', 'ชั้น 1'),
(5, 'ลพบุรี', 'Robinson Lifestyle Lopburi (โรบินสัน ไลฟ์สไตล์ ลพบุรี)', 'ชั้น 1'),
(5, 'ลพบุรี', 'Pratoothongwattana (ประตูทองวัฒนา)', 'ชั้น 1'),
(5, 'ลพบุรี', 'Pinya Shopping Center Lopburi (ภิญญา ช็อปปิ้งเซ็นเตอร์ ลพบุรี)', 'ชั้น 1'),
(5, 'สิงห์บุรี', 'Chaisaeng Singburi (ไชยแสง สิงห์บุรี)', 'ชั้น 1'),
(5, 'พระนครศรีอยุธยา', 'Robinson Ayutthaya (โรบินสัน พระนครศรีอยุธยา)', 'ชั้น 1'),
(5, 'พระนครศรีอยุธยา', 'Premium Outlet Ayutthaya (พรีเมี่ยมเอาท์เล็ท อยุธยา)', 'ชั้น 1'),
(5, 'สระบุรี', 'Robinson Lifestyle Saraburi (โรบินสัน ไลฟ์สไตล์ สระบุรี)', 'ชั้น 1'),
(5, 'สระบุรี', 'Taweekit Complex Saraburi (ทวีกิจคอมเพล็กซ์ สระบุรี)', 'ชั้น 1'),
(5, 'นครราชสีมา', 'The Mall Korat (เดอะมอลล์ โคราช)', 'ชั้น 2'),
(5, 'ชัยภูมิ', 'Robinson Lifestyle Chaiyaphum (โรบินสัน ไลฟ์สไตล์ ชัยภูมิ)', 'ชั้น 1'),
(5, 'บุรีรัมย์', 'Robinson Lifestyle Buriram (โรบินสัน ไลฟ์สไตล์ บุรีรัมย์)', 'ชั้น 1'),
(5, 'สุรินทร์', 'Robinson Lifestyle Surin (โรบินสัน ไลฟ์สไตล์ สุรินทร์)', 'ชั้น 1'),
(5, 'ศรีสะเกษ', 'SeunHeng Plaza Sisaket (ซุ่นเฮงพลาซ่า ศรีสะเกษ)', 'ชั้น 1'),
(5, 'มุกดาหาร', 'Robinson Lifestyle Mukdahan (โรบินสัน ไลฟ์สไตล์ มุกดาหาร)', 'ชั้น 1'),
(5, 'สกลนคร', 'Robinson Lifestyle Sakonnakhon (โรบินสัน ไลฟ์สไตล์ สกลนคร)', 'ชั้น 1'),
(5, 'ร้อยเอ็ด', 'Robinson Lifestyle RoiEt (โรบินสัน ไลฟ์สไตล์ ร้อยเอ็ด)', 'ชั้น 1'),
(5, 'ร้อยเอ็ด', 'Roi Et Plaza (ร้อยเอ็ด พลาซา)', 'ชั้น 1'),
(5, 'นครสวรรค์', 'Sermthai Complex (เสริมไทย)', 'ชั้น 1'),
(5, 'ขอนแก่น', 'Robinson CentralPlaza khonkaen (โรบินสัน เซ็นทรัลพลาซา ขอนแก่น)', 'ชั้น 1'),
(5, 'ขอนแก่น', 'Fairy Plaza Khonkaen (แฟรรี่ พลาซ่า ขอนแก่น)', 'ชั้น 1'),
(5, 'เพชรบูรณ์', 'Topland Phetchabun (ท็อปแลนด์ เพชรบูรณ์)', 'ชั้น 2'),
(5, 'ขอนแก่น', 'Central Khon Kaen (เซ็นทรัล ขอนแก่น)', 'ชั้น 3'),
(5, 'อุดรธานี', 'Central Udon Thani (เซ็นทรัล อุดรธานี)', 'ชั้น 2'),
(5, 'อุบลราชธานี', 'Robinson Ubon Ratchathani (โรบินสัน อุบลราชธานี)', 'ชั้น 2'),
(5, 'เชียงใหม่', 'Robinson CentralPlaza Chiangmai Ariport (โรบินสัน เซ็นทรัลพลาซา เชียงใหม่ แอร์พอร์ต)', 'ชั้น 3'),
(5, 'เชียงราย', 'Robinson CentralPlaza Chiangrai (โรบินสัน เซ็นทรัลพลาซา เชียงราย)', 'ชั้น 1'),
(5, 'พะเยา', 'Robinson Phapao (โรบินสัน พะเยา)', 'ชั้น 1'),
(5, 'พะเยา', 'Charoenphan Phapao (เจริญภัณฑ์ พะเยา)', 'ชั้น 1'),
(5, 'ลำปาง', 'Robinson CentralPlaza Lampang (โรบินสัน เซ็นทรัลพลาซา ลำปาง)', 'ชั้น 2'),
(5, 'ลำปาง', 'Seri Department Store Lampang (เสรีสรรพสินค้า ลำปาง)', 'ชั้น 1'),
(5, 'อุตรดิตถ์', 'Friday Department Store Uttaradit (ห้างสรรพสินค้าฟรายด์เดย์ อุตรดิตถ์)', 'ชั้น 1'),
(5, 'กำแพงเพชร', 'Robinson Lifestyle Kampheangphen (โรบินสัน ไลฟ์สไตล์ กำแพงเพชร)', 'ชั้น 1'),
(5, 'พิษณุโลก', 'Robinson CentralPlaza Phitsanulok (โรบินสัน เซ็นทรัลพลาซา พิษณุโลก)', 'ชั้น 2'),
(5, 'พิษณุโลก', 'Topland Plaza Phitsanulok (ท็อปแลนด์ พิษณุโลก)', 'ชั้น 1'),
(5, 'พิจิตร', 'Phichit Central (พิจิตร เซ็นทรัล)', 'ชั้น 1'),
(5, 'ปราจีนบุรี', 'Robinson Lifestyle Prachinburi (โรบินสัน ไลฟ์สไตล์ ปราจีนบุรี)', 'ชั้น 1'),
(5, 'สุพรรณบุรี', 'Robinson Lifestyle Suphanburi (โรบินสัน ไลฟ์สไตล์ สุพรรณบุรี)', 'ชั้น 1'),
(5, 'เชียงใหม่', 'Central Chiangmai (เซ็นทรัล เชียงใหม่)', 'ชั้น 2'),
(5, 'ชลบุรี', 'CentralFestival Pattaya Beach (เซ็นทรัลเฟสติวัล พัทยา บีช)', 'ชั้น 1'),
(5, 'ชลบุรี', 'Robinson CentralPlaza Chonburi (โรบินสัน เซ็นทรัลพลาซา ชลบุรี)', 'ชั้น 1'),
(5, 'ชลบุรี', 'Robinson Lifestyle Chonburi (โรบินสัน ไลฟ์สไตล์ ชลบุรี)', 'ชั้น 1'),
(5, 'ชลบุรี', 'Robinson Pacific Park Sriracha (โรบินสัน แปซิฟิค พาร์ค ศรีราชา)', 'ชั้น 3'),
(5, 'ฉะเชิงเทรา', 'Robinson Chachoensao (โรบินสัน ฉะเชิงเทรา)', 'ชั้น 1'),
(5, 'ระยอง', 'Passione Shopping Destination (แพชชั่น ช็อปปิ้ง เดสติเนชั่น ระยอง)', 'ชั้น 2'),
(5, 'ระยอง', 'Robinson CentralPlaza Rayong (โรบินสัน เซ็นทรัลพลาซา ระยอง)', 'ชั้น 2'),
(5, 'จันทบุรี', 'Robinson Lifestyle Chanthaburi (โรบินสัน ไลฟ์สไตล์ จันทบุรี)', 'ชั้น 1'),
(5, 'จันทบุรี', 'Lotus Chanthaburi (โลตัส จันทบุรี)', 'ชั้น 1'),
(5, 'ชลบุรี', 'Outlet Mall Pattaya (เอาท์เล็ทมอลล์ พัทยา)', '-'),
(5, 'ตาก', 'Robinson Lifestyle Measot (โรบินสัน ไลฟ์สไตล์ แม่สอด)', 'ชั้น 1'),
(5, 'กาญจนบุรี', 'Robinson Lifestyle Kanchanaburi (โรบินสัน ไลฟ์สไตล์ กาญจนบุรี)', 'ชั้น 1'),
(5, 'เพชรบุรี', 'Robinson Lifestyle Phetchaburi (โรบินสัน ไลฟ์สไตล์ เพชรบุรี)', 'ชั้น 1'),
(5, 'เพชรบุรี', 'Premium Outlet Cha-am (พรีเมี่ยมเอาท์เล็ท ชะอำ)', 'ชั้น 1'),
(5, 'ชุมพร', 'Ocean Chumporn (โอเชี่ยน ชุมพร)', 'ชั้น 2'),
(5, 'สุราษฎร์ธานี', 'Sahathai Garden Plaza Suratthani (สหไทย การ์เด้น พลาซ่า สุราษฎร์ธานี)', 'ชั้น 2'),
(5, 'ภูเก็ต', 'Central Phuket (เซ็นทรัล ภูเก็ต)', 'ชั้น 3'),
(5, 'ภูเก็ต', 'Robinson Ocean Phuket (โรบินสัน โอเชี่ยน ภูเก็ต)', 'ชั้น 3'),
(5, 'กระบี่', 'Vogue Krabi (โวค กระบี่)', 'ชั้น 2'),
(5, 'นครศรีธรรมราช', 'Robinson Lifestyle Nakornsrithammarat (โรบินสัน ไลฟ์สไตล์ นครศรีธรรมราช)', 'ชั้น 1'),
(5, 'นครศรีธรรมราช', 'Robinson CentralPlaza Nakornsrithammarat (โรบินสัน เซ็นทรัลพลาซา นครศรีธรรมราช)', 'ชั้น 2'),
(5, 'นครศรีธรรมราช', 'Sahathai Plaza Nakhonsithammarat (สหไทยพลาซ่า นครศรีธรรมราช)', 'ชั้น 1'),
(5, 'นครศรีธรรมราช', 'Sahathai Department Store Nakornsrithammarat (สหไทยสรรพสินค้า นครศรีธรรมราช)', 'ชั้น 1'),
(5, 'ตรัง', 'Robinson Lifestyle Trang (โรบินสัน ไลฟ์สไตล์ ตรัง)', 'ชั้น 1'),
(5, 'สงขลา', 'CentralFestival Hat Yai (เซ็นทรัลเฟสติวัล หาดใหญ่)', 'ชั้น 3'),
(5, 'สงขลา', 'Robinson Hat Yai (โรบินสัน หาดใหญ่)', 'ชั้น 2'),
(5, 'สงขลา', 'Odean Hatyai (โอเดียน หาดใหญ่)', 'ชั้น 1'),
(5, 'สงขลา', 'Diana Hat Yai (ไดอาน่า หาดใหญ่)', 'ชั้น 1'),
(5, 'ปัตตานี', 'Diana Pattani (ไดอาน่า ปัตตานี)', 'ชั้น 2'),
(5, 'สุราษฎร์ธานี', 'Robinson CentralPlaza Suratthani (โรบินสัน เซ็นทรัลพลาซา สุราษฎร์ธานี)', 'ชั้น 1'),
(6, 'กรุงเทพมหานคร','Central Embassy(เซ็นทรัล เอ็มบาสซี)','ชั้น G'),
(6, 'กรุงเทพมหานคร','Siam Paragon(สยามพารากอน)','ชั้น 4'),
(6, 'กรุงเทพมหานคร','centalwOrld(เซ็นทรัลเวิร์ด)','ชั้น 2'),
(7, 'กรุงเทพมหานคร','centalPlaza Mahachai(เซ็นทรัลพลา มหาชัย)','ชั้น 1'),
(7, 'กรุงเทพมหานคร','Seacon Bangkae(ซีคอน บางแค)','ชั้น 1'),
(7, 'กรุงเทพมหานคร','ICONSIAM(ไอคอนสยาม)','ชั้น 2'),
(7, 'กรุงเทพมหานคร','Gateway Bangsue(เกตเวย์ บางซื่อ)','ชั้น M'),
(7, 'พิษณุโลก','centalPlaza Phitsanulok(เซ็นทรัลพลาซ่า พิษณุโลก)','ชั้น 1'),
(7, 'ขอนแก่น','centalPlaza Khonkaen(เซ็นทรัลพลาซ่า ขอนแก่น)','ชั้น 1'),
(7, 'อุดรธานี','centalPlaza Udonthani(เซ็นทรัลพลาซ่า อุดรธานี)','ชั้น 1'),
(7, 'ชลบุรี','Terminal 21 Pattaya(เทอร์มินอล  21 พัทนา)','ชั้น G,M'),
(7, 'กาญจนบุรี','Robinson Kanchanaburi(โรบินสัน กาญจนบุรี)','ชั้น 1'),
(7, 'สงขลา','Roasisde Hat Yai Songkhla(โรดไซด์ หาดใหญ่ สงขลา)','Hatyai Village'),
(7, 'ภูเก็ต','centalFestivsl Phuket(เซ็นทรัลเฟสติวัล ภูเก็ต)','ชั้น 1'),
(8, 'กรุงเทพมหานคร','Siam Paragon(สยาม พารากอน)','ชั้น 2'),
(8, 'กรุงเทพมหานคร','centalLadprao(เซ็นทรัลลาดพร้าว)','ชั้น 1'),
(8, 'กรุงเทพมหานคร','Terminal 21 Asok (เทอมินอล  21 อโศก)','ชั้น M'),
(8, 'กรุงเทพมหานคร','Icon Siam(ไอค่อนสยาม)','ชั้น 2'),
(8, 'กรุงเทพมหานคร','Fasion Island(แฟชั่น ไอซ์แลนด์)','ชั้น 1'),
(9, 'กรุงเทพมหานคร','cental Ladprao(เซ็นทรัลลาดพร้าว)','ชั้น 1'),
(9, 'กรุงเทพมหานคร','Mega Bangna(เมกาบางนา)','ชั้น 1'),
(9, 'กรุงเทพมหานคร','centalwOrld(เซ็นทรัลเวิร์ด)','ชั้น 2'),
(9, 'กรุงเทพมหานคร','Siam Paragon(สยาม พารากอน)','ชั้น 2');
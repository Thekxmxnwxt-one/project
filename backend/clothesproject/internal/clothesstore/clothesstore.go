package clothesstore

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	_ "github.com/lib/pq"
)

type ProductStore interface {
	GetProducts(ctx context.Context, id int) (Clothes, error)
	GetProduct(ctx context.Context, id int) (Clothes, error)
	AddProduct(ctx context.Context, product Clothes) error
	DeleteProduct(ctx context.Context, id int) error
	GetAllProducts(ctx context.Context) ([]Clothes, error)
	UpdateProduct(ctx context.Context, product Clothes) error
	GetProductsByCategory(ctx context.Context, category string) ([]Clothes, error)
	GetAboutPageByBrandID(ctx context.Context, brand_id int) (AboutPage, error)
	GetAllBranches(ctx context.Context) ([]Branch, error)
	GetBranchesByBrand(ctx context.Context, brandID int) ([]Branch, error)
	GetBranchesByBrandAndProvince(ctx context.Context, brandID int, province string) ([]Branch, error)
	GetBrandByID(ctx context.Context, brandID string) (Brands, error)
	GetAllBrands(ctx context.Context) ([]Brands, error)
	GetProductsByBrand(ctx context.Context, brandID string) ([]Clothes, error)
	SearchProducts(ctx context.Context, searchQuery string) ([]Clothes, error)
	AddBrand(ctx context.Context, brand Brands) error
	DeleteBrand(ctx context.Context, brandID string) error
	UpdateBrand(ctx context.Context, brand Brands) error
	GetAllCart(ctx context.Context) ([]CartItem, error)
	AddProductToCart(ctx context.Context, productID int, quantity int) error
	DeleteProductFromCart(ctx context.Context, cartID int) error
	Close() error
	Ping() error
	Reconnect(connStr string) error
}

type Clothes struct {
	ID          int       `json:"id"`
	Category    string    `json:"category"`
	ImgSrc      string    `json:"imgsrc"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	BrandID     int       `json:"brand"`
	Price       float64   `json:"price"`
	IsNew       bool      `json:"isnew"`
	Createdate  time.Time `json:"createdate"`
	Updatedate  time.Time `json:"updatedate"`
}

type AboutPage struct {
	ID          int    `json:"id"`
	Brand_id    int    `json:"brand_id"`
	Img         string `json:"img"`
	Title       string `json:"title"`
	Description string `json:"description"`
}

type Branch struct {
	ID            int    `json:"id"`
	BrandID       int    `json:"brand_id"`
	Province      string `json:"province"`
	Banch         string `json:"banch"`
	BanchLocation string `json:"banch_location"`
}

type Brands struct {
	BrandID   string `json:"id"`
	Brandname string `json:"brandname"`
	Brandlogo string `json:"brandlogo"`
}

type CartItem struct {
	CartID        int       `json:"cart_id"`
	ProductID     int       `json:"product_id"`
	ProductName   string    `json:"name"`
	ProductImgSrc string    `json:"imgsrc"`
	Quantity      int       `json:"quantity"`
	Price         float64   `json:"price"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type PostgresDatabase struct {
	db *sql.DB
}

func NewPostgresDatabase(connStr string) (*PostgresDatabase, error) {
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %v", err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %v", err)
	}

	return &PostgresDatabase{db: db}, nil
}

// GetProducts ดึงข้อมูลสินค้าจากฐานข้อมูลตาม ID
func (pdb *PostgresDatabase) GetProducts(ctx context.Context, id int) (Clothes, error) {
	return pdb.GetProduct(ctx, id) // ใช้ GetProduct เพื่อดึงสินค้าจาก ID
}

// GetProduct ดึงข้อมูลสินค้าจากฐานข้อมูลตาม ID
func (pdb *PostgresDatabase) GetProduct(ctx context.Context, id int) (Clothes, error) {
	var product Clothes
	err := pdb.db.QueryRowContext(ctx, "SELECT id, category, imgsrc, name, description, brand, price, isnew, createdate, updatedate FROM products WHERE id = $1", id).Scan(
		&product.ID, &product.Category, &product.ImgSrc, &product.Name, &product.Description, &product.BrandID, &product.Price, &product.IsNew, &product.Createdate, &product.Updatedate)
	if err != nil {
		if err == sql.ErrNoRows {
			return Clothes{}, errors.New("product not found")
		}
		return Clothes{}, fmt.Errorf("failed to get product: %v", err)
	}
	return product, nil
}

// GetProductByCategory ดึงสินค้าจากฐานข้อมูลตามประเภท
func (pdb *PostgresDatabase) GetProductsByCategory(ctx context.Context, category string) ([]Clothes, error) {
	query := "SELECT id, category, imgsrc, name, description, brand, price, isnew FROM products WHERE category = $1"
	rows, err := pdb.db.QueryContext(ctx, query, category)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var products []Clothes

	for rows.Next() {
		var product Clothes
		if err := rows.Scan(&product.ID, &product.Category, &product.ImgSrc, &product.Name, &product.Description, &product.BrandID, &product.Price, &product.IsNew); err != nil {
			return nil, err
		}
		products = append(products, product)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return products, nil
}

// AddProduct เพิ่มข้อมูลสินค้าใหม่ลงในฐานข้อมูล
func (pdb *PostgresDatabase) AddProduct(ctx context.Context, product Clothes) error {
	_, err := pdb.db.ExecContext(ctx, "INSERT INTO products (category, imgsrc, name, description, brand, price, isnew) VALUES ($1, $2, $3, $4, $5, $6, $7)",
		product.Category, product.ImgSrc, product.Name, product.Description, product.BrandID, product.Price, product.IsNew)
	if err != nil {
		return fmt.Errorf("failed to add product: %v", err)
	}
	return nil
}

// DeleteProduct ลบข้อมูลสินค้าจากฐานข้อมูล
func (pdb *PostgresDatabase) DeleteProduct(ctx context.Context, id int) error {
	_, err := pdb.db.ExecContext(ctx, "DELETE FROM products WHERE id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete product: %v", err)
	}
	return nil
}

// UpdateProduct อัพเดตข้อมูลสินค้าที่มีอยู่ในฐานข้อมูล
func (pdb *PostgresDatabase) UpdateProduct(ctx context.Context, product Clothes) error {
	_, err := pdb.db.ExecContext(ctx, "UPDATE products SET category = $1, imgsrc = $2, name = $3, description = $4, brand = $5, price = $6, isnew = $7 WHERE id = $8",
		product.Category, product.ImgSrc, product.Name, product.Description, product.BrandID, product.Price, product.IsNew, product.ID)
	if err != nil {
		return fmt.Errorf("failed to update product: %v", err)
	}
	return nil
}

func (pdb *PostgresDatabase) Close() error {
	return pdb.db.Close()
}

func (pdb *PostgresDatabase) Ping() error {
	return pdb.db.Ping()
}

func (pdb *PostgresDatabase) Reconnect(connStr string) error {
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return fmt.Errorf("failed to reconnect to database: %v", err)
	}

	pdb.db = db
	return pdb.Ping()
}

func (pdb *PostgresDatabase) GetAllProducts(ctx context.Context) ([]Clothes, error) {
	query := "SELECT id, category, imgsrc, name, description, brand, price, isnew FROM products"
	rows, err := pdb.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var products []Clothes

	for rows.Next() {
		var product Clothes
		if err := rows.Scan(&product.ID, &product.Category, &product.ImgSrc, &product.Name, &product.Description, &product.BrandID, &product.Price, &product.IsNew); err != nil {
			return nil, err
		}
		products = append(products, product)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return products, nil
}

// เพิ่มฟังก์ชัน GetAboutPage ใน ProductStore
func (pdb *PostgresDatabase) GetAboutPageByBrandID(ctx context.Context, brand_id int) (AboutPage, error) {
	var about AboutPage
	query := `SELECT brand_id, img, title, description FROM about_page WHERE brand_id = $1`
	err := pdb.db.QueryRowContext(ctx, query, brand_id).Scan(&about.Brand_id, &about.Img, &about.Title, &about.Description)
	if err != nil {
		if err == sql.ErrNoRows {
			return AboutPage{}, fmt.Errorf("about page not found for brand_id %d", brand_id)
		}
		return AboutPage{}, fmt.Errorf("failed to get about page: %v", err)
	}
	return about, nil
}

// GetAllBranches ดึงข้อมูลทุกสาขา
func (pdb *PostgresDatabase) GetAllBranches(ctx context.Context) ([]Branch, error) {
	rows, err := pdb.db.QueryContext(ctx, "SELECT id, brand_id, province, banch, banch_location FROM branch")
	if err != nil {
		return nil, fmt.Errorf("failed to fetch all branches: %v", err)
	}
	defer rows.Close()

	var branches []Branch
	for rows.Next() {
		var branch Branch
		if err := rows.Scan(&branch.ID, &branch.BrandID, &branch.Province, &branch.Banch, &branch.BanchLocation); err != nil {
			return nil, fmt.Errorf("failed to scan branch row: %v", err)
		}
		branches = append(branches, branch)
	}

	return branches, nil
}

// GetBranchesByBrand ดึงข้อมูลสาขาตามแบรนด์
func (pdb *PostgresDatabase) GetBranchesByBrand(ctx context.Context, brandID int) ([]Branch, error) {
	rows, err := pdb.db.QueryContext(ctx, "SELECT id, brand_id, province, banch, banch_location FROM branch WHERE brand_id = $1", brandID)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch branches by brand: %v", err)
	}
	defer rows.Close()

	var branches []Branch
	for rows.Next() {
		var branch Branch
		if err := rows.Scan(&branch.ID, &branch.BrandID, &branch.Province, &branch.Banch, &branch.BanchLocation); err != nil {
			return nil, fmt.Errorf("failed to scan branch row: %v", err)
		}
		branches = append(branches, branch)
	}

	return branches, nil
}

// GetBranchesByBrandAndProvince ดึงข้อมูลสาขาตามแบรนด์และจังหวัด
func (pdb *PostgresDatabase) GetBranchesByBrandAndProvince(ctx context.Context, brandID int, province string) ([]Branch, error) {
	rows, err := pdb.db.QueryContext(ctx, "SELECT id, brand_id, province, banch, banch_location FROM branch WHERE brand_id = $1 AND province = $2", brandID, province)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch branches by brand and province: %v", err)
	}
	defer rows.Close()

	var branches []Branch
	for rows.Next() {
		var branch Branch
		if err := rows.Scan(&branch.ID, &branch.BrandID, &branch.Province, &branch.Banch, &branch.BanchLocation); err != nil {
			return nil, fmt.Errorf("failed to scan branch row: %v", err)
		}
		branches = append(branches, branch)
	}

	return branches, nil
}
func (pdb *PostgresDatabase) GetBrandByID(ctx context.Context, brandID string) (Brands, error) {
	// ตรวจสอบว่า brandID ไม่ใช่ค่าว่าง
	if brandID == "" {
		return Brands{}, fmt.Errorf("brand ID is required")
	}

	// สร้างตัวแปรที่จะเก็บข้อมูลแบรนด์
	var brand Brands
	query := "SELECT id, brandname, brandlogo FROM brand WHERE id = $1"

	// ดึงข้อมูลจากฐานข้อมูลตาม brandID
	err := pdb.db.QueryRowContext(ctx, query, brandID).Scan(&brand.BrandID, &brand.Brandname, &brand.Brandlogo)
	if err != nil {
		// ตรวจสอบกรณีที่ไม่พบข้อมูล (sql.ErrNoRows)
		if err == sql.ErrNoRows {
			return Brands{}, fmt.Errorf("brand not found")
		}
		// กรณีเกิดข้อผิดพลาดในการดึงข้อมูล
		return Brands{}, fmt.Errorf("failed to get brand: %v", err)
	}

	// คืนค่าแบรนด์ที่ได้จากฐานข้อมูล
	return brand, nil
}

func (pdb *PostgresDatabase) GetAllBrands(ctx context.Context) ([]Brands, error) {
	query := "SELECT id, brandname, brandlogo FROM brand"
	rows, err := pdb.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var brands []Brands

	for rows.Next() {
		var brand Brands
		if err := rows.Scan(&brand.BrandID, &brand.Brandname, &brand.Brandlogo); err != nil {
			return nil, err
		}
		brands = append(brands, brand)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return brands, nil
}

// GetProductsByBrand ดึงข้อมูลสินค้าจากฐานข้อมูลตาม BrandID
func (pdb *PostgresDatabase) GetProductsByBrand(ctx context.Context, brandID string) ([]Clothes, error) {
	query := "SELECT id, category, imgsrc, name, description, brand, price, isnew FROM products WHERE brand = $1"
	rows, err := pdb.db.QueryContext(ctx, query, brandID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var products []Clothes
	for rows.Next() {
		var product Clothes
		if err := rows.Scan(&product.ID, &product.Category, &product.ImgSrc, &product.Name, &product.Description, &product.BrandID, &product.Price, &product.IsNew); err != nil {
			return nil, err
		}
		products = append(products, product)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	return products, nil
}

// สร้างฟังก์ชัน SearchProducts ใน PostgresDatabase
func (pdb *PostgresDatabase) SearchProducts(ctx context.Context, searchQuery string) ([]Clothes, error) {
	// ใช้ LIKE เพื่อค้นหาคำที่ระบุในชื่อหรือคำอธิบายของผลิตภัณฑ์
	query := "SELECT id, category, imgsrc, name, description, brand, price, isnew FROM products WHERE name ILIKE $1 OR description ILIKE $1"
	rows, err := pdb.db.QueryContext(ctx, query, "%"+searchQuery+"%")
	if err != nil {
		return nil, fmt.Errorf("failed to search products: %v", err)
	}
	defer rows.Close()

	var products []Clothes

	for rows.Next() {
		var product Clothes
		if err := rows.Scan(&product.ID, &product.Category, &product.ImgSrc, &product.Name, &product.Description, &product.BrandID, &product.Price, &product.IsNew); err != nil {
			return nil, err
		}
		products = append(products, product)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return products, nil

}

// AddProduct เพิ่มข้อมูลสินค้าใหม่ลงในฐานข้อมูล
func (pdb *PostgresDatabase) AddBrand(ctx context.Context, brand Brands) error {
	_, err := pdb.db.ExecContext(ctx, "INSERT INTO brand (brandname, brandlogo) VALUES ($1, $2)",
		brand.Brandlogo, brand.Brandname)
	if err != nil {
		return fmt.Errorf("failed to add brand: %v", err)
	}
	return nil
}

// DeleteProduct ลบข้อมูลสินค้าจากฐานข้อมูล
func (pdb *PostgresDatabase) DeleteBrand(ctx context.Context, brandID string) error {
	_, err := pdb.db.ExecContext(ctx, "DELETE FROM brand WHERE id = $1", brandID)
	if err != nil {
		return fmt.Errorf("failed to delete brand: %v", err)
	}
	return nil
}

// UpdateProduct อัพเดตข้อมูลสินค้าที่มีอยู่ในฐานข้อมูล
func (pdb *PostgresDatabase) UpdateBrand(ctx context.Context, brand Brands) error {
	_, err := pdb.db.ExecContext(ctx, "UPDATE brand SET brandname = $1, brandlogo = $2 WHERE id = $3",
		brand.Brandlogo, brand.Brandname, brand.BrandID)
	if err != nil {
		return fmt.Errorf("failed to update brand: %v", err)
	}
	return nil
}

// GetAllCart ดึงข้อมูลสินค้าทั้งหมดในตะกร้า
func (pdb *PostgresDatabase) GetAllCart(ctx context.Context) ([]CartItem, error) {
	query := `
        SELECT c.cart_id, p.name AS product_name, p.imgsrc AS product_imgsrc, c.quantity, (p.price * c.quantity) AS total_price
        FROM cart c
        JOIN products p ON c.product_id = p.id;
    `
	rows, err := pdb.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to query cart items: %v", err)
	}
	defer rows.Close()

	var cartItems []CartItem
	for rows.Next() {
		var item CartItem
		if err := rows.Scan(&item.CartID, &item.ProductName, &item.ProductImgSrc, &item.Quantity, &item.Price); err != nil {
			return nil, fmt.Errorf("failed to scan cart item: %v", err)
		}
		cartItems = append(cartItems, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("row iteration error: %v", err)
	}

	return cartItems, nil
}

// AddProductToCart เพิ่มสินค้าใหม่หรืออัพเดตจำนวนสินค้าในตะกร้า
func (pdb *PostgresDatabase) AddProductToCart(ctx context.Context, productID int, quantity int) error {
	// เริ่มต้น transaction เพื่อให้มั่นใจว่าการเพิ่ม/อัพเดตข้อมูลเป็นไปอย่างถูกต้อง
	tx, err := pdb.db.Begin()
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %v", err)
	}
	defer tx.Rollback()

	// ตรวจสอบว่าในตะกร้ามีสินค้านี้อยู่แล้วหรือไม่
	var existingCartID int
	err = tx.QueryRowContext(ctx, "SELECT cart_id FROM cart WHERE product_id = $1", productID).Scan(&existingCartID)
	if err != nil && err != sql.ErrNoRows {
		return fmt.Errorf("failed to check if product exists in cart: %v", err)
	}

	if err == sql.ErrNoRows {
		// ถ้าไม่มีสินค้าในตะกร้า ให้เพิ่มสินค้าใหม่
		_, err = tx.ExecContext(ctx, `
            INSERT INTO cart (product_id, quantity, price) 
            VALUES ($1, $2, (SELECT price FROM products WHERE id = $1))
        `, productID, quantity)
		if err != nil {
			return fmt.Errorf("failed to insert product into cart: %v", err)
		}
	} else {
		// ถ้ามีสินค้าในตะกร้าแล้ว ให้ทำการอัพเดตจำนวนสินค้า
		_, err = tx.ExecContext(ctx, `
            UPDATE cart 
            SET quantity = quantity + $2 
            WHERE product_id = $1
        `, productID, quantity)
		if err != nil {
			return fmt.Errorf("failed to update quantity in cart: %v", err)
		}
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %v", err)
	}

	return nil
}

func (pdb *PostgresDatabase) DeleteProductFromCart(ctx context.Context, cartID int) error {
	// ลบข้อมูลสินค้าในตะกร้า
	_, err := pdb.db.ExecContext(ctx, "DELETE FROM cart WHERE cart_id = $1", cartID)
	if err != nil {
		return fmt.Errorf("failed to delete product from cart: %v", err)
	}
	return nil
}

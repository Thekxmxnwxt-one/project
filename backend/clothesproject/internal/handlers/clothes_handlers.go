package handlers

import (
	"clothesproject/internal/clothesstore"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type ClothesHandlers struct {
	Store clothesstore.ProductStore // ใช้ interface โดยตรง
}

func NewClothesHandlers(store clothesstore.ProductStore) *ClothesHandlers {
	return &ClothesHandlers{Store: store}
}

func (h *ClothesHandlers) GetAllProducts(c *gin.Context) {
	ctx := c.Request.Context()
	products, err := h.Store.GetAllProducts(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, products)
}

func (h *ClothesHandlers) AddProduct(c *gin.Context) {
	var product clothesstore.Clothes
	if err := c.ShouldBindJSON(&product); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	ctx := c.Request.Context()
	if err := h.Store.AddProduct(ctx, product); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, product)
}

func (h *ClothesHandlers) DeleteProduct(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}
	ctx := c.Request.Context()
	if err := h.Store.DeleteProduct(ctx, id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Product deleted"})
}

func (h *ClothesHandlers) UpdateProduct(c *gin.Context) {
	var product clothesstore.Clothes
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}
	if err := c.ShouldBindJSON(&product); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	ctx := c.Request.Context()
	product.ID = id
	if err := h.Store.UpdateProduct(ctx, product); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, product)
}

func (h *ClothesHandlers) GetProduct(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}
	ctx := c.Request.Context()
	product, err := h.Store.GetProduct(ctx, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, product)
}

func (h *ClothesHandlers) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "healthy"})
}

func (h *ClothesHandlers) GetProductByCategory(c *gin.Context) {
	category := c.Param("category")
	ctx := c.Request.Context()
	products, err := h.Store.GetProductsByCategory(ctx, category)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, products)
}

// ฟังก์ชันสำหรับดึงข้อมูล About Page
func (h *ClothesHandlers) GetAboutPage(c *gin.Context) {
	ctx := c.Request.Context()
	brandID, err := strconv.Atoi(c.Param("brand_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid brand ID"})
		return
	}
	aboutPage, err := h.Store.GetAboutPageByBrandID(ctx, brandID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, aboutPage)
}

// GetAllBranches ดึงข้อมูลทุกสาขา
func (h *ClothesHandlers) GetAllBranches(c *gin.Context) {
	ctx := c.Request.Context()
	branches, err := h.Store.GetAllBranches(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, branches)
}

// GetBranchesByBrand ดึงข้อมูลสาขาตามแบรนด์
func (h *ClothesHandlers) GetBranchesByBrand(c *gin.Context) {
	ctx := c.Request.Context()
	brandID, err := strconv.Atoi(c.Param("brand_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid brand ID"})
		return
	}
	branches, err := h.Store.GetBranchesByBrand(ctx, brandID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, branches)
}

// GetBranchesByBrandAndProvince ดึงข้อมูลสาขาตามแบรนด์และจังหวัด
func (h *ClothesHandlers) GetBranchesByBrandAndProvince(c *gin.Context) {
	ctx := c.Request.Context()
	brandID, err := strconv.Atoi(c.Param("brand_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid brand ID"})
		return
	}
	province := c.Param("province")
	branches, err := h.Store.GetBranchesByBrandAndProvince(ctx, brandID, province)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, branches)
}

func (h *ClothesHandlers) GetBrandByID(c *gin.Context) {
	brandID := c.Param("brandID")                    // ดึงค่าพารามิเตอร์ id จาก URL
	ctx := c.Request.Context()                       // ใช้ context จาก request
	brand, err := h.Store.GetBrandByID(ctx, brandID) // ส่ง context ไปที่ Store
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, brand)
}
func (h *ClothesHandlers) GetAllBrands(c *gin.Context) {
	ctx := c.Request.Context()
	brands, err := h.Store.GetAllBrands(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, brands)
}

// Handler สำหรับค้นหาสินค้าตาม Brand
func (h *ClothesHandlers) GetProductsByBrand(c *gin.Context) {
	brandID := c.Param("brandID")
	ctx := c.Request.Context()

	// เรียกใช้ฟังก์ชัน GetProductsByBrand จาก Store เพื่อดึงข้อมูลสินค้าตาม Brand
	products, err := h.Store.GetProductsByBrand(ctx, brandID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// ส่งผลลัพธ์กลับ
	c.JSON(http.StatusOK, products)
}

// เพิ่มฟังก์ชันสำหรับค้นหาสินค้าตามชื่อ
func (h *ClothesHandlers) SearchProducts(c *gin.Context) {
	// รับค่า query parameter ที่ชื่อ "name"
	searchTerm := c.Query("name")
	ctx := c.Request.Context()

	// เรียกใช้ฟังก์ชัน SearchProductsByName จาก Store
	products, err := h.Store.SearchProducts(ctx, searchTerm)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// ส่งผลลัพธ์เป็น JSON
	c.JSON(http.StatusOK, products)
}

func (h *ClothesHandlers) AddBrand(c *gin.Context) {
	var brand clothesstore.Brands
	if err := c.ShouldBindJSON(&brand); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	ctx := c.Request.Context()
	if err := h.Store.AddBrand(ctx, brand); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, brand)
}

func (h *ClothesHandlers) DeleteBrand(c *gin.Context) {
	brandID := c.Param("id") // ดึง id มาในรูปแบบ string โดยตรง
	ctx := c.Request.Context()
	if err := h.Store.DeleteBrand(ctx, brandID); err != nil { // ส่งเป็น string
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Brand deleted"})
}

func (h *ClothesHandlers) UpdateBrand(c *gin.Context) {
	var brand clothesstore.Brands
	brandID := c.Param("id") // ดึง id มาในรูปแบบ string
	if err := c.ShouldBindJSON(&brand); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	ctx := c.Request.Context()
	brand.BrandID = brandID // ใช้ string เป็น brandID
	if err := h.Store.UpdateBrand(ctx, brand); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, brand)
}

// GetAllCart คือ Handler สำหรับดึงข้อมูลสินค้าทั้งหมดในตะกร้า
func (h *ClothesHandlers) GetAllCart(c *gin.Context) {
	ctx := c.Request.Context()

	// ดึงข้อมูลตะกร้าจาก store
	cartItems, err := h.Store.GetAllCart(ctx)
	if err != nil {
		// หากเกิดข้อผิดพลาดในการดึงข้อมูล ส่งกลับ error 500
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// ส่งข้อมูลสินค้าทั้งหมดในตะกร้ากลับไปเป็น JSON
	c.JSON(http.StatusOK, cartItems)
}

// AddProductToCart คือ Handler สำหรับการเพิ่มสินค้าไปยังตะกร้า
func (h *ClothesHandlers) AddProductToCart(c *gin.Context) {
	// อ่านข้อมูลจาก JSON body
	var request struct {
		ProductID int `json:"product_id"` // รหัสสินค้าที่จะเพิ่ม
		Quantity  int `json:"quantity"`   // จำนวนสินค้าที่จะเพิ่ม
	}

	// ผูกข้อมูล JSON ที่ได้รับจาก request
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON"})
		return
	}

	// ตรวจสอบว่า quantity เป็นค่าที่ถูกต้อง
	if request.Quantity <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Quantity must be greater than 0"})
		return
	}

	// เรียกฟังก์ชันเพิ่มสินค้าลงในตะกร้า
	ctx := c.Request.Context()
	err := h.Store.AddProductToCart(ctx, request.ProductID, request.Quantity)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Product added to cart"})
}

func (h *ClothesHandlers) DeleteProductFromCart(c *gin.Context) {
	// รับ cart_id จาก URL params
	fmt.Println("Received cart_id:", c.Param("cart_id"))
	cartID, err := strconv.Atoi(c.Param("cart_id"))
	if err != nil {
		fmt.Println("Error converting cart_id:", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid cart ID"})
		return
	}

	ctx := c.Request.Context()
	if err := h.Store.DeleteProductFromCart(ctx, cartID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Product deleted"})
}

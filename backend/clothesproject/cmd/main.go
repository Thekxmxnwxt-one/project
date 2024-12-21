package main

import (
	"clothesproject/internal/clothesstore"
	"clothesproject/internal/config"
	"clothesproject/internal/handlers"
	"context"
	"log"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func TimeoutMiddleware(timeout time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), timeout)
		defer cancel()

		c.Request = c.Request.WithContext(ctx)
		c.Next()
	}
}

func main() {
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}
	db, err := clothesstore.NewPostgresDatabase(cfg.GetConnectionString())
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close() // ย้าย deferred close ให้อยู่ในที่ที่ไม่ขึ้นกับ nil check

	cs := db // db จะเป็น *PostgresDatabase ซึ่ง implements ProductStore
	h := handlers.NewClothesHandlers(cs)
	go func() {
		for {
			time.Sleep(10 * time.Second)
			if err := db.Ping(); err != nil {
				log.Printf("Database connection lost: %v", err)
				if reconnErr := db.Reconnect(cfg.GetConnectionString()); reconnErr != nil {
					log.Printf("Failed to reconnect: %v", reconnErr)
				} else {
					log.Printf("Successfully reconnected to the database")
				}
			}
		}
	}()

	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()

	// เพิ่ม CORS Middleware ที่นี่
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"http://localhost:3000"}, // ระบุ Origin ที่อนุญาต
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE"},
		AllowHeaders:     []string{"Authorization", "Content-Type"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	r.Use(TimeoutMiddleware(5 * time.Second))

	r.GET("/health", h.HealthCheck)

	// API v1
	v1 := r.Group("/api/v1")
	{
		v1.GET("/products/:id", h.GetProduct)
		v1.POST("/products", h.AddProduct)
		v1.DELETE("/products/:id", h.DeleteProduct)
		v1.PUT("/products/:id", h.UpdateProduct)

		// เพิ่ม API สำหรับดูข้อมูลสินค้าทั้งหมด
		v1.GET("/products", h.GetAllProducts)

		// เพิ่ม API สำหรับดูข้อมูลสินค้าตามหมวดหมู่
		v1.GET("/products/category/:category", h.GetProductByCategory)

		// เพิ่ม API สำหรับ About Page
		v1.GET("/about/:brand_id", h.GetAboutPage)

		v1.GET("/brand", h.GetAllBrands)
		v1.GET("/brand/:brandID", h.GetBrandByID)
		v1.POST("/brand", h.AddBrand)
		v1.DELETE("/brand/:brandID", h.DeleteBrand)
		v1.PUT("/brand/:brandID", h.UpdateBrand)

		v1.GET("/products/brand/:brandID", h.GetProductsByBrand)

		v1.GET("/products/search", h.SearchProducts)

		// API สำหรับดึงข้อมูลสาขาทั้งหมด
		v1.GET("/branches", h.GetAllBranches)

		// API สำหรับดึงข้อมูลสาขาตามแบรนด์
		v1.GET("/branches/brand/:brand_id", h.GetBranchesByBrand)

		// API สำหรับดึงข้อมูลสาขาตามแบรนด์และจังหวัด
		v1.GET("/branches/brand/:brand_id/province/:province", h.GetBranchesByBrandAndProvince)

		// Cart APIs
		v1.GET("/cart", h.GetAllCart)
		v1.POST("/cart", h.AddProductToCart)
		v1.DELETE("/cart/:cartID", h.DeleteProductFromCart)
	}

	if err := r.Run(":" + cfg.AppPort); err != nil {
		log.Printf("Failed to run server: %v", err)
	}
}

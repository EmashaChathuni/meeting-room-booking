package main

import (
	"log"
	"os"
	"time"

	"meeting-room-booking/config"
	"meeting-room-booking/routes"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()

	// 1. CORS Configuration (CRITICAL for Flutter)
	router.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "X-API-Key", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// 2. Health Check (Must be at the TOP)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "message": "Backend is running!"})
	})

	// 3. Register Routes
	routes.RegisterRoutes(router)

	// 4. Database Connection (Non-blocking)
	go func() {
		log.Println("⌛ Attempting to connect to Supabase...")
		config.ConnectDB() 
	}()

	// 5. Get Port
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Server starting on port %s", port)
	router.Run(":" + port)
}

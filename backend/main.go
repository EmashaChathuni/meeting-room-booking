// main.go - Entry point for the Meeting Room Booking API server
package main

import (
	"log"
	"os"

	"meeting-room-booking/config"
	"meeting-room-booking/routes"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables from .env file
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, reading from system environment")
	}

	// Create a new Gin router
	router := gin.Default()

	// 🏥 Health check route (Always works even if DB is slow)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "OK", "message": "Backend is alive!"})
	})

	// Allow CORS so Flutter app can talk to the API
	router.Use(cors.New(cors.Config{
		AllowAllOrigins: true,
		AllowMethods:    []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:    []string{"Origin", "Content-Type", "X-API-Key", "Authorization"},
	}))

	// Connect to the database with logging
	log.Println("⌛ Connecting to Supabase...")
	config.ConnectDB()
	log.Println("✅ Database connected successfully")
	defer config.DB.Close()

	// Register all API routes
	routes.RegisterRoutes(router)

	// Get port from environment variable (default: 8081)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Server running on http://localhost:%s", port)
	log.Printf("📖 Swagger docs: http://localhost:%s/swagger/index.html", port)

	// Start the server
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

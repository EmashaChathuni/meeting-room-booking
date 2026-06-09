// main.go - Entry point for the Meeting Room Booking API server
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

	// 1. MUST ADD CORS: This allows the Flutter App to communicate with your API
	router.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "X-API-Key", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// 2. Add the health checks
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "Backend is running"})
	})
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// 3. Register your actual routes (Login, Signup, Bookings)
	routes.RegisterRoutes(router)

	// 4. Connect to Database in the background (prevents timeout)
	go func() {
		log.Println("⌛ Connecting to Supabase...")
		config.ConnectDB() 
	}()

	// 5. Start Server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	router.Run("0.0.0.0:" + port)
}

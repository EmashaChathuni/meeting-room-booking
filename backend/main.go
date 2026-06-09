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

	// 1. CORS Configuration
	router.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "X-API-Key", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// 2. Register standard routes
	routes.RegisterRoutes(router)

	// 3. THE FIX: Register routes with the Choreo path prefix
	choreo := router.Group("/default/backend/v1.0")
	{
		routes.RegisterRoutesOnGroup(choreo)
	}

	// 4. Connect to Database in background
	go config.ConnectDB()

	// 5. Start Server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	router.Run("0.0.0.0:" + port)
}

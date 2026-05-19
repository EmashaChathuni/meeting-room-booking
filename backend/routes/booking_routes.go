// routes/booking_routes.go - API route definitions and middleware
package routes

import (
	"meeting-room-booking/controllers"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

// APIKeyMiddleware checks for a valid API key in the request header
func APIKeyMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get the expected API key from environment variable
		expectedKey := os.Getenv("API_KEY")
		if expectedKey == "" {
			// If no API key is configured, skip authentication
			c.Next()
			return
		}

		// Read the API key from the request header
		providedKey := c.GetHeader("X-API-Key")

		if providedKey == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Missing API key. Please provide X-API-Key header",
			})
			c.Abort() // Stop processing the request
			return
		}

		if providedKey != expectedKey {
			c.JSON(http.StatusForbidden, gin.H{
				"success": false,
				"message": "Invalid API key",
			})
			c.Abort()
			return
		}

		// API key is valid, continue to the next handler
		c.Next()
	}
}

// RegisterRoutes sets up all API routes on the given Gin router
func RegisterRoutes(router *gin.Engine) {
	// Health check endpoint (no authentication required)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "ok",
			"message": "Meeting Room Booking API is running",
		})
	})

	// Serve Swagger UI (static HTML)
	router.Static("/swagger", "./docs/swagger-ui")
	// Serve swagger.yaml at /swagger-spec for the Swagger UI to reference
	router.StaticFile("/swagger-spec", "./docs/swagger.yaml")

	// API routes group with authentication middleware
	api := router.Group("/api")
	api.Use(APIKeyMiddleware())
	{
		// Booking CRUD endpoints
		api.GET("/bookings", controllers.GetAllBookings)       // Get all bookings
		api.GET("/bookings/:id", controllers.GetBookingByID)   // Get one booking
		api.POST("/bookings", controllers.CreateBooking)       // Create a booking
		api.PUT("/bookings/:id", controllers.UpdateBooking)    // Update a booking
		api.DELETE("/bookings/:id", controllers.DeleteBooking) // Delete a booking
	}
}

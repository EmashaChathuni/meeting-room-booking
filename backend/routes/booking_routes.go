// routes/booking_routes.go - API route definitions and middleware
package routes

import (
	"net/http"

	"meeting-room-booking/controllers"

	"github.com/gin-gonic/gin"
)

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

	// API routes group
	api := router.Group("/api")
	{
		// Auth routes (no authentication required)
		auth := api.Group("/auth")
		{
			auth.POST("/signup", controllers.Signup)
			auth.POST("/login", controllers.Login)
		}

		// User profile route (requires authentication)
		api.GET("/profile", AuthMiddleware(), controllers.GetProfile)

		// Booking routes (all require authentication)
		bookings := api.Group("/bookings")
		bookings.Use(AuthMiddleware())
		{
			bookings.GET("", controllers.GetAllBookings)       // Get all bookings for authenticated user
			bookings.GET("/:id", controllers.GetBookingByID)   // Get one booking
			bookings.POST("", controllers.CreateBooking)       // Create a booking
			bookings.PUT("/:id", controllers.UpdateBooking)    // Update a booking
			bookings.DELETE("/:id", controllers.DeleteBooking) // Delete a booking
		}
	}
}

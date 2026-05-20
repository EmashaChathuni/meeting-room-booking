// controllers/booking_controller.go - HTTP request handlers
package controllers

import (
	"net/http"

	"meeting-room-booking/models"
	"meeting-room-booking/repositories"

	"github.com/gin-gonic/gin"
)

// GetAllBookings handles GET /api/bookings - requires authentication
func GetAllBookings(c *gin.Context) {
	// Get user_id from context (set by auth middleware)
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"message": "Unauthorized",
		})
		return
	}

	bookings, err := repositories.GetAllBookings(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to fetch bookings",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Bookings fetched successfully",
		"data":    bookings,
	})
}

// GetBookingByID handles GET /api/bookings/:id - requires authentication
func GetBookingByID(c *gin.Context) {
	id := c.Param("id")

	// Get user_id from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"message": "Unauthorized",
		})
		return
	}

	booking, err := repositories.GetBookingByID(id, userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to fetch booking",
			"error":   err.Error(),
		})
		return
	}

	if booking == nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Booking not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Booking fetched successfully",
		"data":    booking,
	})
}

// CreateBooking handles POST /api/bookings - requires authentication
func CreateBooking(c *gin.Context) {
	var req models.CreateBookingRequest

	// Parse the JSON request body
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid request body",
			"error":   err.Error(),
		})
		return
	}

	// Get user_id from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"message": "Unauthorized",
		})
		return
	}

	booking, err := repositories.CreateBooking(userID.(string), req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Failed to create booking",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Booking created successfully",
		"data":    booking,
	})
}

// UpdateBooking handles PUT /api/bookings/:id - requires authentication
func UpdateBooking(c *gin.Context) {
	id := c.Param("id")

	var req models.UpdateBookingRequest

	// Parse the JSON request body
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid request body",
			"error":   err.Error(),
		})
		return
	}

	// Get user_id from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"message": "Unauthorized",
		})
		return
	}

	booking, err := repositories.UpdateBooking(id, userID.(string), req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to update booking",
			"error":   err.Error(),
		})
		return
	}

	if booking == nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Booking not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Booking updated successfully",
		"data":    booking,
	})
}

// DeleteBooking handles DELETE /api/bookings/:id - requires authentication
func DeleteBooking(c *gin.Context) {
	id := c.Param("id")

	// Get user_id from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"message": "Unauthorized",
		})
		return
	}

	deleted, err := repositories.DeleteBooking(id, userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to delete booking",
			"error":   err.Error(),
		})
		return
	}

	if !deleted {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Booking not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Booking deleted successfully",
	})
}

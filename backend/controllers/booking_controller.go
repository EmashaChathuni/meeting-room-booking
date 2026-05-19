// controllers/booking_controller.go - HTTP request handlers
package controllers

import (
	"meeting-room-booking/models"
	"meeting-room-booking/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GetAllBookings handles GET /api/bookings
func GetAllBookings(c *gin.Context) {
	bookings, err := services.GetAllBookings()
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

// GetBookingByID handles GET /api/bookings/:id
func GetBookingByID(c *gin.Context) {
	id := c.Param("id")

	booking, err := services.GetBookingByID(id)
	if err != nil {
		if err.Error() == "booking not found" {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"message": "Booking not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to fetch booking",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Booking fetched successfully",
		"data":    booking,
	})
}

// CreateBooking handles POST /api/bookings
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

	booking, err := services.CreateBooking(req)
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

// UpdateBooking handles PUT /api/bookings/:id
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

	booking, err := services.UpdateBooking(id, req)
	if err != nil {
		if err.Error() == "booking not found" {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"message": "Booking not found",
			})
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Failed to update booking",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Booking updated successfully",
		"data":    booking,
	})
}

// DeleteBooking handles DELETE /api/bookings/:id
func DeleteBooking(c *gin.Context) {
	id := c.Param("id")

	err := services.DeleteBooking(id)
	if err != nil {
		if err.Error() == "booking not found" {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"message": "Booking not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to delete booking",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Booking deleted successfully",
	})
}

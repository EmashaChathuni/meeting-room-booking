// services/booking_service.go - Business logic layer
package services

import (
	"errors"
	"meeting-room-booking/models"
	"meeting-room-booking/repositories"
)

// GetAllBookings returns a list of all bookings
func GetAllBookings() ([]models.Booking, error) {
	bookings, err := repositories.GetAllBookings()
	if err != nil {
		return nil, err
	}

	// If no bookings exist, return an empty slice (not nil)
	if bookings == nil {
		return []models.Booking{}, nil
	}

	return bookings, nil
}

// GetBookingByID returns a single booking, or an error if not found
func GetBookingByID(id string) (*models.Booking, error) {
	if id == "" {
		return nil, errors.New("booking ID cannot be empty")
	}

	booking, err := repositories.GetBookingByID(id)
	if err != nil {
		return nil, err
	}

	if booking == nil {
		return nil, errors.New("booking not found")
	}

	return booking, nil
}

// CreateBooking validates the request and creates a new booking
func CreateBooking(req models.CreateBookingRequest) (*models.Booking, error) {
	// Basic validation: start time must be before end time
	if req.StartTime >= req.EndTime {
		return nil, errors.New("start time must be before end time")
	}

	// Validate status value if provided
	if req.Status != "" && req.Status != "pending" && req.Status != "confirmed" && req.Status != "cancelled" {
		return nil, errors.New("status must be one of: pending, confirmed, cancelled")
	}

	return repositories.CreateBooking(req)
}

// UpdateBooking validates and updates an existing booking
func UpdateBooking(id string, req models.UpdateBookingRequest) (*models.Booking, error) {
	if id == "" {
		return nil, errors.New("booking ID cannot be empty")
	}

	// Validate status if provided
	if req.Status != "" && req.Status != "pending" && req.Status != "confirmed" && req.Status != "cancelled" {
		return nil, errors.New("status must be one of: pending, confirmed, cancelled")
	}

	// Validate time range if both times are provided
	if req.StartTime != "" && req.EndTime != "" && req.StartTime >= req.EndTime {
		return nil, errors.New("start time must be before end time")
	}

	booking, err := repositories.UpdateBooking(id, req)
	if err != nil {
		return nil, err
	}

	if booking == nil {
		return nil, errors.New("booking not found")
	}

	return booking, nil
}

// DeleteBooking removes a booking by ID
func DeleteBooking(id string) error {
	if id == "" {
		return errors.New("booking ID cannot be empty")
	}

	deleted, err := repositories.DeleteBooking(id)
	if err != nil {
		return err
	}

	if !deleted {
		return errors.New("booking not found")
	}

	return nil
}

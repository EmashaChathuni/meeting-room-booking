// models/booking.go - The Booking data model
package models

import "time"

// Booking represents a meeting room booking record in the database
type Booking struct {
	ID             int       `json:"id"`              // Unique booking ID (auto-increment)
	UserID         int       `json:"user_id"`         // ID of the user who made the booking
	RoomName       string    `json:"room_name"`       // Name of the meeting room
	MeetingTitle   string    `json:"meeting_title"`   // Title or purpose of the meeting
	MeetingDate    string    `json:"meeting_date"`    // Date of the meeting (YYYY-MM-DD)
	StartTime      string    `json:"start_time"`      // Start time (HH:MM)
	EndTime        string    `json:"end_time"`        // End time (HH:MM)
	NumberOfPeople int       `json:"number_of_people"` // Number of attendees
	Status         string    `json:"status"`          // Status: pending, confirmed, cancelled
	CreatedAt      time.Time `json:"created_at"`      // When the booking was created
	UpdatedAt      time.Time `json:"updated_at"`      // When the booking was last updated
}

// CreateBookingRequest is used when creating a new booking (user_id comes from auth token)
type CreateBookingRequest struct {
	RoomName       string `json:"room_name" binding:"required"`
	MeetingTitle   string `json:"meeting_title" binding:"required"`
	MeetingDate    string `json:"meeting_date" binding:"required"`
	StartTime      string `json:"start_time" binding:"required"`
	EndTime        string `json:"end_time" binding:"required"`
	NumberOfPeople int    `json:"number_of_people" binding:"required,min=1"`
	Status         string `json:"status"`
}

// UpdateBookingRequest is used when updating an existing booking
type UpdateBookingRequest struct {
	RoomName       string `json:"room_name"`
	MeetingTitle   string `json:"meeting_title"`
	MeetingDate    string `json:"meeting_date"`
	StartTime      string `json:"start_time"`
	EndTime        string `json:"end_time"`
	NumberOfPeople int    `json:"number_of_people"`
	Status         string `json:"status"`
}

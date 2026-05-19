// repositories/booking_repository.go - Direct database operations
package repositories

import (
	"database/sql"
	"fmt"
	"meeting-room-booking/config"
	"meeting-room-booking/models"
)

// GetAllBookings fetches all bookings from the database
func GetAllBookings() ([]models.Booking, error) {
	query := `
		SELECT id, room_name, booked_by, department, meeting_title,
		       meeting_date, start_time, end_time, number_of_people, status, created_at
		FROM meeting_bookings
		ORDER BY created_at DESC
	`

	rows, err := config.DB.Query(query)
	if err != nil {
		return nil, fmt.Errorf("error querying bookings: %w", err)
	}
	defer rows.Close()

	var bookings []models.Booking

	for rows.Next() {
		var b models.Booking
		err := rows.Scan(
			&b.ID, &b.RoomName, &b.BookedBy, &b.Department,
			&b.MeetingTitle, &b.MeetingDate, &b.StartTime, &b.EndTime,
			&b.NumberOfPeople, &b.Status, &b.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("error scanning booking row: %w", err)
		}
		bookings = append(bookings, b)
	}

	return bookings, nil
}

// GetBookingByID fetches a single booking by its ID
func GetBookingByID(id string) (*models.Booking, error) {
	query := `
		SELECT id, room_name, booked_by, department, meeting_title,
		       meeting_date, start_time, end_time, number_of_people, status, created_at
		FROM meeting_bookings
		WHERE id = $1
	`

	var b models.Booking
	err := config.DB.QueryRow(query, id).Scan(
		&b.ID, &b.RoomName, &b.BookedBy, &b.Department,
		&b.MeetingTitle, &b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil // Not found
	}
	if err != nil {
		return nil, fmt.Errorf("error fetching booking: %w", err)
	}

	return &b, nil
}

// CreateBooking inserts a new booking into the database
func CreateBooking(req models.CreateBookingRequest) (*models.Booking, error) {
	// Default status to "pending" if not provided
	status := req.Status
	if status == "" {
		status = "pending"
	}

	query := `
		INSERT INTO meeting_bookings
		  (room_name, booked_by, department, meeting_title, meeting_date,
		   start_time, end_time, number_of_people, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING id, room_name, booked_by, department, meeting_title,
		          meeting_date, start_time, end_time, number_of_people, status, created_at
	`

	var b models.Booking
	err := config.DB.QueryRow(
		query,
		req.RoomName, req.BookedBy, req.Department, req.MeetingTitle,
		req.MeetingDate, req.StartTime, req.EndTime, req.NumberOfPeople, status,
	).Scan(
		&b.ID, &b.RoomName, &b.BookedBy, &b.Department,
		&b.MeetingTitle, &b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("error creating booking: %w", err)
	}

	return &b, nil
}

// UpdateBooking updates an existing booking in the database
func UpdateBooking(id string, req models.UpdateBookingRequest) (*models.Booking, error) {
	query := `
		UPDATE meeting_bookings
		SET room_name = $1, booked_by = $2, department = $3, meeting_title = $4,
		    meeting_date = $5, start_time = $6, end_time = $7,
		    number_of_people = $8, status = $9
		WHERE id = $10
		RETURNING id, room_name, booked_by, department, meeting_title,
		          meeting_date, start_time, end_time, number_of_people, status, created_at
	`

	var b models.Booking
	err := config.DB.QueryRow(
		query,
		req.RoomName, req.BookedBy, req.Department, req.MeetingTitle,
		req.MeetingDate, req.StartTime, req.EndTime, req.NumberOfPeople, req.Status,
		id,
	).Scan(
		&b.ID, &b.RoomName, &b.BookedBy, &b.Department,
		&b.MeetingTitle, &b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil // Not found
	}
	if err != nil {
		return nil, fmt.Errorf("error updating booking: %w", err)
	}

	return &b, nil
}

// DeleteBooking removes a booking from the database by ID
func DeleteBooking(id string) (bool, error) {
	query := `DELETE FROM meeting_bookings WHERE id = $1`

	result, err := config.DB.Exec(query, id)
	if err != nil {
		return false, fmt.Errorf("error deleting booking: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return false, err
	}

	return rowsAffected > 0, nil
}

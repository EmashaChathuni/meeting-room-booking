// repositories/booking_repository.go - Direct database operations
package repositories

import (
	"database/sql"
	"fmt"
	"strings"

	"meeting-room-booking/config"
	"meeting-room-booking/models"
)

// normalizeTime ensures time string includes seconds (HH:MM:SS format)
func normalizeTime(timeStr string) string {
	timeStr = strings.TrimSpace(timeStr)
	// If already has seconds, return as-is
	if strings.Count(timeStr, ":") == 2 {
		return timeStr
	}
	// If only HH:MM format, add :00 seconds
	if strings.Count(timeStr, ":") == 1 {
		return timeStr + ":00"
	}
	return timeStr
}

// GetAllBookings fetches all bookings for the authenticated user
func GetAllBookings(userID int) ([]models.Booking, error) {
	query := `
		SELECT id, user_id, room_name, booked_by, department, meeting_title,
		       meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
		FROM meeting_bookings
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := config.DB.Query(query, userID)
	if err != nil {
		return nil, fmt.Errorf("error querying bookings: %w", err)
	}
	defer rows.Close()

	var bookings []models.Booking

	for rows.Next() {
		var b models.Booking
		err := rows.Scan(
			&b.ID, &b.UserID, &b.RoomName, &b.BookedBy, &b.Department, &b.MeetingTitle,
			&b.MeetingDate, &b.StartTime, &b.EndTime,
			&b.NumberOfPeople, &b.Status, &b.CreatedAt, &b.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("error scanning booking row: %w", err)
		}
		bookings = append(bookings, b)
	}

	return bookings, nil
}

// GetBookingByID fetches a single booking by its ID
func GetBookingByID(id, userID int) (*models.Booking, error) {
	query := `
		SELECT id, user_id, room_name, booked_by, department, meeting_title,
		       meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
		FROM meeting_bookings
		WHERE id = $1 AND user_id = $2
	`

	var b models.Booking
	err := config.DB.QueryRow(query, id, userID).Scan(
		&b.ID, &b.UserID, &b.RoomName, &b.BookedBy, &b.Department, &b.MeetingTitle,
		&b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt, &b.UpdatedAt,
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
func CreateBooking(userID int, req models.CreateBookingRequest) (*models.Booking, error) {
	// Default status to "pending" if not provided
	status := req.Status
	if status == "" {
		status = "pending"
	}

	// Normalize time strings to include seconds
	startTime := normalizeTime(req.StartTime)
	endTime := normalizeTime(req.EndTime)

	query := `
		INSERT INTO meeting_bookings
		  (user_id, room_name, booked_by, department, meeting_title, meeting_date,
		   start_time, end_time, number_of_people, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, user_id, room_name, booked_by, department, meeting_title,
		          meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
	`

	var b models.Booking
	err := config.DB.QueryRow(
		query,
		userID, req.RoomName, req.BookedBy, req.Department, req.MeetingTitle, req.MeetingDate,
		startTime, endTime, req.NumberOfPeople, status,
	).Scan(
		&b.ID, &b.UserID, &b.RoomName, &b.BookedBy, &b.Department, &b.MeetingTitle,
		&b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt, &b.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("error creating booking: %w", err)
	}

	return &b, nil
}

// UpdateBooking updates an existing booking in the database
func UpdateBooking(id, userID int, req models.UpdateBookingRequest) (*models.Booking, error) {
	// Normalize time strings if provided
	startTime := req.StartTime
	endTime := req.EndTime
	
	if startTime != "" {
		startTime = normalizeTime(startTime)
	}
	if endTime != "" {
		endTime = normalizeTime(endTime)
	}

	query := `
		UPDATE meeting_bookings
		SET room_name = COALESCE(NULLIF($1, ''), room_name),
		    booked_by = COALESCE(NULLIF($2, ''), booked_by),
		    department = COALESCE(NULLIF($3, ''), department),
		    meeting_title = COALESCE(NULLIF($4, ''), meeting_title),
		    meeting_date = COALESCE(NULLIF($5, ''), meeting_date),
		    start_time = COALESCE(NULLIF($6, ''), start_time),
		    end_time = COALESCE(NULLIF($7, ''), end_time),
		    number_of_people = COALESCE(NULLIF($8, 0), number_of_people),
		    status = COALESCE(NULLIF($9, ''), status),
		    updated_at = NOW()
		WHERE id = $10 AND user_id = $11
		RETURNING id, user_id, room_name, booked_by, department, meeting_title,
		          meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
	`

	var b models.Booking
	err := config.DB.QueryRow(
		query,
		req.RoomName, req.BookedBy, req.Department, req.MeetingTitle, req.MeetingDate,
		startTime, endTime, req.NumberOfPeople, req.Status,
		id, userID,
	).Scan(
		&b.ID, &b.UserID, &b.RoomName, &b.BookedBy, &b.Department, &b.MeetingTitle,
		&b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt, &b.UpdatedAt,
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
func DeleteBooking(id, userID int) (bool, error) {
	query := `DELETE FROM meeting_bookings WHERE id = $1 AND user_id = $2`

	result, err := config.DB.Exec(query, id, userID)
	if err != nil {
		return false, fmt.Errorf("error deleting booking: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return false, err
	}

	return rowsAffected > 0, nil
}

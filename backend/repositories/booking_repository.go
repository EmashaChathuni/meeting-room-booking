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

// GetAllBookings fetches all bookings from the database (Global Visibility)
func GetAllBookings() ([]models.Booking, error) {
	query := `
		SELECT id, user_id, room_name, booked_by, COALESCE(department, ''), meeting_title,
		       meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
		FROM meeting_bookings
		ORDER BY meeting_date DESC, start_time DESC
	`

	rows, err := config.DB.Query(query)
	if err != nil {
		return nil, fmt.Errorf("error querying all bookings: %w", err)
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

// GetBookingByID fetches a single booking by its ID (Anyone can view)
func GetBookingByID(id int) (*models.Booking, error) {
	query := `
		SELECT id, user_id, room_name, booked_by, COALESCE(department, ''), meeting_title,
		       meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
		FROM meeting_bookings
		WHERE id = $1
	`

	var b models.Booking
	err := config.DB.QueryRow(query, id).Scan(
		&b.ID, &b.UserID, &b.RoomName, &b.BookedBy, &b.Department, &b.MeetingTitle,
		&b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt, &b.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("error fetching booking: %w", err)
	}

	return &b, nil
}

// CreateBooking inserts a new booking into the database
func CreateBooking(userID int, req models.CreateBookingRequest) (*models.Booking, error) {
	status := req.Status
	if status == "" {
		status = "pending"
	}

	startTime := normalizeTime(req.StartTime)
	endTime := normalizeTime(req.EndTime)

	query := `
		INSERT INTO meeting_bookings
		  (user_id, room_name, booked_by, department, meeting_title, meeting_date,
		   start_time, end_time, number_of_people, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, user_id, room_name, booked_by, COALESCE(department, ''), meeting_title,
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

// UpdateBooking updates an existing booking (Only if owner)
func UpdateBooking(id, userID int, req models.UpdateBookingRequest) (*models.Booking, error) {
	// First check if user is the owner
	existing, err := GetBookingByID(id)
	if err != nil || existing == nil {
		return nil, fmt.Errorf("booking not found")
	}
	if existing.UserID != userID {
		return nil, fmt.Errorf("unauthorized: you can't edit someone else's booking")
	}

	startTime := req.StartTime
	endTime := req.EndTime
	if startTime != "" { startTime = normalizeTime(startTime) }
	if endTime != "" { endTime = normalizeTime(endTime) }

	query := `
		UPDATE meeting_bookings
		SET room_name = COALESCE(NULLIF($1, ''), room_name),
		    booked_by = COALESCE(NULLIF($2, ''), booked_by),
		    department = COALESCE(NULLIF($3, ''), department),
		    meeting_title = COALESCE(NULLIF($4, ''), meeting_title),
		    meeting_date = CASE WHEN $5::text != '' THEN $5::date ELSE meeting_date END,
		    start_time = CASE WHEN $6::text != '' THEN $6::time ELSE start_time END,
		    end_time = CASE WHEN $7::text != '' THEN $7::time ELSE end_time END,
		    number_of_people = COALESCE(NULLIF($8, 0), number_of_people),
		    status = COALESCE(NULLIF($9, ''), status),
		    updated_at = NOW()
		WHERE id = $10
		RETURNING id, user_id, room_name, booked_by, COALESCE(department, ''), meeting_title,
		          meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
	`

	var b models.Booking
	err = config.DB.QueryRow(
		query,
		req.RoomName, req.BookedBy, req.Department, req.MeetingTitle, req.MeetingDate,
		startTime, endTime, req.NumberOfPeople, req.Status,
		id,
	).Scan(
		&b.ID, &b.UserID, &b.RoomName, &b.BookedBy, &b.Department, &b.MeetingTitle,
		&b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt, &b.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("error updating booking: %w", err)
	}

	return &b, nil
}

// DeleteBooking removes a booking (Only if owner)
func DeleteBooking(id, userID int) (bool, error) {
	// Ownership check
	existing, err := GetBookingByID(id)
	if err != nil || existing == nil {
		return false, fmt.Errorf("booking not found")
	}
	if existing.UserID != userID {
		return false, fmt.Errorf("unauthorized: you can't delete someone else's booking")
	}

	query := `DELETE FROM meeting_bookings WHERE id = $1`
	result, err := config.DB.Exec(query, id)
	if err != nil {
		return false, fmt.Errorf("error deleting booking: %w", err)
	}

	rowsAffected, _ := result.RowsAffected()
	return rowsAffected > 0, nil
}

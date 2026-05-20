// repositories/booking_repository.go - Direct database operations
package repositories

import (
	"database/sql"
	"fmt"

	"meeting-room-booking/config"
	"meeting-room-booking/models"
)

// GetAllBookings fetches all bookings for the authenticated user
func GetAllBookings(userID string) ([]models.Booking, error) {
	// Convert userID string to int
	var uid int
	_, err := fmt.Sscanf(userID, "%d", &uid)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID format: %w", err)
	}

	query := `
		SELECT id, user_id, room_name, meeting_title,
		       meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
		FROM meeting_bookings
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := config.DB.Query(query, uid)
	if err != nil {
		return nil, fmt.Errorf("error querying bookings: %w", err)
	}
	defer rows.Close()

	var bookings []models.Booking

	for rows.Next() {
		var b models.Booking
		err := rows.Scan(
			&b.ID, &b.UserID, &b.RoomName, &b.MeetingTitle,
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
func GetBookingByID(id, userID string) (*models.Booking, error) {
	// Convert id and userID strings to int
	var bid, uid int
	_, err := fmt.Sscanf(id, "%d", &bid)
	if err != nil {
		return nil, fmt.Errorf("invalid booking ID format: %w", err)
	}
	_, err = fmt.Sscanf(userID, "%d", &uid)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID format: %w", err)
	}

	query := `
		SELECT id, user_id, room_name, meeting_title,
		       meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
		FROM meeting_bookings
		WHERE id = $1 AND user_id = $2
	`

	var b models.Booking
	err = config.DB.QueryRow(query, bid, uid).Scan(
		&b.ID, &b.UserID, &b.RoomName, &b.MeetingTitle,
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
func CreateBooking(userID string, req models.CreateBookingRequest) (*models.Booking, error) {
	// Convert userID string to int
	var uid int
	_, err := fmt.Sscanf(userID, "%d", &uid)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID format: %w", err)
	}

	// Default status to "pending" if not provided
	status := req.Status
	if status == "" {
		status = "pending"
	}

	query := `
		INSERT INTO meeting_bookings
		  (user_id, room_name, meeting_title, meeting_date,
		   start_time, end_time, number_of_people, status)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, user_id, room_name, meeting_title,
		          meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
	`

	var b models.Booking
	err = config.DB.QueryRow(
		query,
		uid, req.RoomName, req.MeetingTitle, req.MeetingDate,
		req.StartTime, req.EndTime, req.NumberOfPeople, status,
	).Scan(
		&b.ID, &b.UserID, &b.RoomName, &b.MeetingTitle,
		&b.MeetingDate, &b.StartTime, &b.EndTime,
		&b.NumberOfPeople, &b.Status, &b.CreatedAt, &b.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("error creating booking: %w", err)
	}

	return &b, nil
}

// UpdateBooking updates an existing booking in the database
func UpdateBooking(id, userID string, req models.UpdateBookingRequest) (*models.Booking, error) {
	// Convert id and userID strings to int
	var bid, uid int
	_, err := fmt.Sscanf(id, "%d", &bid)
	if err != nil {
		return nil, fmt.Errorf("invalid booking ID format: %w", err)
	}
	_, err = fmt.Sscanf(userID, "%d", &uid)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID format: %w", err)
	}

	query := `
		UPDATE meeting_bookings
		SET room_name = COALESCE(NULLIF($1, ''), room_name),
		    meeting_title = COALESCE(NULLIF($2, ''), meeting_title),
		    meeting_date = COALESCE(NULLIF($3, ''), meeting_date),
		    start_time = COALESCE(NULLIF($4, ''), start_time),
		    end_time = COALESCE(NULLIF($5, ''), end_time),
		    number_of_people = COALESCE(NULLIF($6, 0), number_of_people),
		    status = COALESCE(NULLIF($7, ''), status),
		    updated_at = NOW()
		WHERE id = $8 AND user_id = $9
		RETURNING id, user_id, room_name, meeting_title,
		          meeting_date, start_time, end_time, number_of_people, status, created_at, updated_at
	`

	var b models.Booking
	err = config.DB.QueryRow(
		query,
		req.RoomName, req.MeetingTitle, req.MeetingDate,
		req.StartTime, req.EndTime, req.NumberOfPeople, req.Status,
		bid, uid,
	).Scan(
		&b.ID, &b.UserID, &b.RoomName, &b.MeetingTitle,
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
func DeleteBooking(id, userID string) (bool, error) {
	// Convert id and userID strings to int
	var bid, uid int
	_, err := fmt.Sscanf(id, "%d", &bid)
	if err != nil {
		return false, fmt.Errorf("invalid booking ID format: %w", err)
	}
	_, err = fmt.Sscanf(userID, "%d", &uid)
	if err != nil {
		return false, fmt.Errorf("invalid user ID format: %w", err)
	}

	query := `DELETE FROM meeting_bookings WHERE id = $1 AND user_id = $2`

	result, err := config.DB.Exec(query, bid, uid)
	if err != nil {
		return false, fmt.Errorf("error deleting booking: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return false, err
	}

	return rowsAffected > 0, nil
}

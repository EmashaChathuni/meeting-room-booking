// repositories/user_repository.go - User database operations
package repositories

import (
	"database/sql"
	"fmt"

	"meeting-room-booking/config"
	"meeting-room-booking/models"
)

// CreateUser creates a new user in the database
func CreateUser(email, passwordHash, fullName, department string) (*models.User, error) {
	query := `
		INSERT INTO users (email, password_hash, full_name, department)
		VALUES ($1, $2, $3, $4)
		RETURNING id, email, full_name, department, created_at, updated_at
	`

	var user models.User
	err := config.DB.QueryRow(query, email, passwordHash, fullName, department).Scan(
		&user.ID, &user.Email, &user.FullName, &user.Department,
		&user.CreatedAt, &user.UpdatedAt,
	)

	if err != nil {
		if err.Error() == "pq: duplicate key value violates unique constraint \"users_email_key\"" {
			return nil, fmt.Errorf("email already registered")
		}
		return nil, fmt.Errorf("error creating user: %w", err)
	}

	return &user, nil
}

// GetUserByEmail retrieves a user by email
func GetUserByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, email, password_hash, full_name, department, created_at, updated_at
		FROM users
		WHERE email = $1
	`

	var user models.User
	err := config.DB.QueryRow(query, email).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.FullName,
		&user.Department, &user.CreatedAt, &user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("user not found")
	}
	if err != nil {
		return nil, fmt.Errorf("error fetching user: %w", err)
	}

	return &user, nil
}

// GetUserByID retrieves a user by ID
func GetUserByID(id string) (*models.User, error) {
	query := `
		SELECT id, email, full_name, department, created_at, updated_at
		FROM users
		WHERE id = $1
	`

	var user models.User
	err := config.DB.QueryRow(query, id).Scan(
		&user.ID, &user.Email, &user.FullName,
		&user.Department, &user.CreatedAt, &user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("user not found")
	}
	if err != nil {
		return nil, fmt.Errorf("error fetching user: %w", err)
	}

	return &user, nil
}

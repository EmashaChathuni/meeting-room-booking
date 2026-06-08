// config/database.go - Database connection configuration
package config

import (
	"database/sql"
	"log"
	"os"

	_ "github.com/lib/pq" // PostgreSQL driver
)

// DB is the global database connection pool
var DB *sql.DB

// ConnectDB opens a connection to the Supabase PostgreSQL database
func ConnectDB() {
	// Get the database URL from environment variable
	dbURL := os.Getenv("SUPABASE_DB_URL")
	if dbURL == "" {
		log.Println("SUPABASE_DB_URL environment variable is not set")
		return
	}

	// Open a connection to the database
	var err error
	DB, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Printf("Error opening database connection pool: %v", err)
		return
	}

	// Set connection limits
	DB.SetMaxOpenConns(15)
	DB.SetMaxIdleConns(5)

	// Verify the connection is alive (Non-fatal)
	if err = DB.Ping(); err != nil {
		log.Printf("⚠️ Could not reach Supabase yet. Error: %v", err)
	} else {
		log.Println("✅ Successfully connected to Supabase!")
	}
}

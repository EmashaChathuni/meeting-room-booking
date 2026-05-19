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
		log.Fatal("SUPABASE_DB_URL environment variable is not set")
	}

	// Open a connection to the database
	var err error
	DB, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to open database connection: %v", err)
	}

	// Verify the connection is alive
	if err = DB.Ping(); err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	log.Println("✅ Connected to Supabase PostgreSQL database")
}

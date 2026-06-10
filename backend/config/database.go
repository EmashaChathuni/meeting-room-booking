// config/database.go - Database connection configuration
package config

import (
	"database/sql"
	"fmt"
	"log"
	"net"
	"net/url"
	"os"
	"strings"

	_ "github.com/lib/pq" // PostgreSQL driver
)

const (
	directSupabaseHost = "db.ktfktivucihcyozvnfqo.supabase.co"
	supabaseProjectRef = "ktfktivucihcyozvnfqo"
	supabasePoolerHost = "aws-1-ap-southeast-2.pooler.supabase.com"
)

// DB is the global database connection pool
var DB *sql.DB

func normalizeDatabaseURL(rawURL string) (string, error) {
	parsed, err := url.Parse(rawURL)
	if err != nil {
		return "", fmt.Errorf("invalid SUPABASE_DB_URL: %w", err)
	}

	if strings.EqualFold(parsed.Hostname(), directSupabaseHost) {
		password, hasPassword := parsed.User.Password()
		if !hasPassword {
			return "", fmt.Errorf("SUPABASE_DB_URL is missing a password")
		}

		port := parsed.Port()
		if port == "" {
			port = "5432"
		}
		parsed.Host = net.JoinHostPort(supabasePoolerHost, port)
		parsed.User = url.UserPassword("postgres."+supabaseProjectRef, password)
	}

	query := parsed.Query()
	if query.Get("connect_timeout") == "" {
		query.Set("connect_timeout", "10")
	}
	parsed.RawQuery = query.Encode()

	return parsed.String(), nil
}

// ConnectDB opens a connection to the Supabase PostgreSQL database
func ConnectDB() {
	// Get the database URL from environment variable
	dbURL := os.Getenv("SUPABASE_DB_URL")
	if dbURL == "" {
		log.Println("SUPABASE_DB_URL environment variable is not set")
		return
	}

	dbURL, err := normalizeDatabaseURL(dbURL)
	if err != nil {
		log.Printf("Invalid database configuration: %v", err)
		return
	}

	// Open a connection to the database
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

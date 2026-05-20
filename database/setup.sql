-- Database schema setup for Meeting Room Booking System
-- Run this script in your Supabase PostgreSQL database

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  department VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create meeting_bookings table
CREATE TABLE IF NOT EXISTS meeting_bookings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  room_name VARCHAR(255) NOT NULL,
  booked_by VARCHAR(255),
  department VARCHAR(255),
  meeting_title VARCHAR(255) NOT NULL,
  meeting_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  number_of_people INTEGER NOT NULL DEFAULT 1,
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_meeting_bookings_user_id ON meeting_bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_meeting_bookings_meeting_date ON meeting_bookings(meeting_date);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

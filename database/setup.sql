-- ============================================================
-- SQL Setup Script for Meeting Room Booking App
-- Run this in Supabase Dashboard → SQL Editor
-- ============================================================

-- Step 1: Enable UUID generation (may already be enabled in Supabase)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Step 2: Create the meeting_bookings table
CREATE TABLE IF NOT EXISTS meeting_bookings (
    id               UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_name        VARCHAR(100)  NOT NULL,
    booked_by        VARCHAR(100)  NOT NULL,
    department       VARCHAR(100)  NOT NULL,
    meeting_title    VARCHAR(200)  NOT NULL,
    meeting_date     DATE          NOT NULL,
    start_time       TIME          NOT NULL,
    end_time         TIME          NOT NULL,
    number_of_people INTEGER       NOT NULL CHECK (number_of_people >= 1),
    status           VARCHAR(50)   NOT NULL DEFAULT 'pending'
                                   CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Step 3: Add an index for faster date-based queries
CREATE INDEX IF NOT EXISTS idx_meeting_bookings_date
    ON meeting_bookings(meeting_date);

-- Step 4: Add an index for faster status filtering
CREATE INDEX IF NOT EXISTS idx_meeting_bookings_status
    ON meeting_bookings(status);

-- ============================================================
-- Optional: Insert sample data to test the app
-- ============================================================
INSERT INTO meeting_bookings
    (room_name, booked_by, department, meeting_title, meeting_date, start_time, end_time, number_of_people, status)
VALUES
    ('Conference Room A', 'John Doe',    'Engineering', 'Sprint Planning Q3',       '2025-06-15', '09:00', '10:30', 8,  'confirmed'),
    ('Boardroom',         'Jane Smith',  'Marketing',   'Product Launch Review',    '2025-06-15', '11:00', '12:00', 5,  'pending'),
    ('Meeting Room 1',    'Bob Johnson', 'HR',           'Team Building Session',   '2025-06-16', '14:00', '16:00', 12, 'confirmed'),
    ('Conference Room B', 'Alice Brown', 'Sales',        'Client Presentation',     '2025-06-17', '10:00', '11:00', 4,  'pending'),
    ('Training Room',     'Charlie Lee', 'IT',           'Flutter Workshop',        '2025-06-18', '09:00', '17:00', 20, 'confirmed');

-- ============================================================
-- Verify the table was created correctly
-- ============================================================
SELECT * FROM meeting_bookings ORDER BY created_at DESC;

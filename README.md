# 🏢 Office Meeting Room Booking App

A full-stack mobile application for managing office meeting room bookings.

| Layer | Technology |
|---|---|
| **Mobile Frontend** | Flutter (Dart) |
| **Backend API** | Go + Gin Framework |
| **Database** | Supabase (PostgreSQL) |
| **API Docs** | Swagger / OpenAPI 3.0 |

---

## 📁 Project Structure

```
meeting-room-booking/
├── backend/                    ← Go REST API
│   ├── main.go                 ← Server entry point
│   ├── .env                    ← Environment variables (edit this!)
│   ├── go.mod                  ← Go modules
│   ├── config/
│   │   └── database.go         ← DB connection
│   ├── models/
│   │   └── booking.go          ← Data structures
│   ├── repositories/
│   │   └── booking_repository.go  ← SQL queries
│   ├── services/
│   │   └── booking_service.go  ← Business logic
│   ├── controllers/
│   │   └── booking_controller.go  ← HTTP handlers
│   ├── routes/
│   │   └── booking_routes.go   ← Route + middleware
│   └── docs/
│       ├── swagger.yaml        ← OpenAPI specification
│       └── swagger-ui/
│           └── index.html      ← Swagger UI
│
├── frontend/                   ← Flutter mobile app
│   ├── pubspec.yaml            ← Dependencies
│   └── lib/
│       ├── main.dart           ← App entry point
│       ├── constants/
│       │   └── api_constants.dart   ← API config
│       ├── models/
│       │   └── booking_model.dart   ← Booking class
│       ├── services/
│       │   └── booking_api_service.dart  ← HTTP calls
│       ├── screens/
│       │   ├── splash_screen.dart
│       │   ├── booking_list_screen.dart
│       │   ├── add_booking_screen.dart
│       │   ├── edit_booking_screen.dart
│       │   └── booking_detail_screen.dart
│       └── widgets/
│           └── booking_card.dart
│
└── database/
    └── setup.sql               ← Database setup script
```

---

## 🗄️ Step 1: Set Up Supabase Database

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. Go to **SQL Editor** in the left sidebar
4. Copy and paste the contents of `database/setup.sql` and run it
5. Your `meeting_bookings` table is now ready!

### Get your connection string:
- Go to: **Project Settings** → **Database** → **Connection string** tab → **URI**
- It looks like: `postgres://postgres:[YOUR-PASSWORD]@db.xxxx.supabase.co:5432/postgres`

---

## ⚙️ Step 2: Configure the Backend

### Edit `backend/.env`:
```env
SUPABASE_DB_URL=postgres://postgres:YOUR_PASSWORD@db.YOUR_PROJECT_REF.supabase.co:5432/postgres?sslmode=require
API_KEY=my-secret-api-key-change-this
PORT=8080
```

> ⚠️ **Important**: Replace `YOUR_PASSWORD` and `YOUR_PROJECT_REF` with your actual Supabase values!

---

## 🚀 Step 3: Run the Backend

### Prerequisites
- Install [Go](https://go.dev/dl/) (version 1.21+)
- Check: `go version`

### Commands:
```powershell
# Navigate to backend folder
cd meeting-room-booking\backend

# Download all dependencies
go mod tidy

# Run the server
go run main.go
```

### Expected output:
```
✅ Connected to Supabase PostgreSQL database
🚀 Server running on http://localhost:8080
📖 Swagger docs: http://localhost:8080/swagger/index.html
```

### Test the API (in a new terminal):
```powershell
# Health check (no API key needed)
curl http://localhost:8080/health

# Get all bookings (with API key)
curl -H "X-API-Key: my-secret-api-key-change-this" http://localhost:8080/api/bookings

# Create a booking
curl -X POST http://localhost:8080/api/bookings `
  -H "Content-Type: application/json" `
  -H "X-API-Key: my-secret-api-key-change-this" `
  -d '{
    "room_name": "Conference Room A",
    "booked_by": "John Doe",
    "department": "Engineering",
    "meeting_title": "Sprint Planning",
    "meeting_date": "2025-06-20",
    "start_time": "09:00",
    "end_time": "10:00",
    "number_of_people": 5,
    "status": "pending"
  }'
```

---

## 📱 Step 4: Configure and Run the Flutter App

### Prerequisites
- Install [Flutter](https://flutter.dev/docs/get-started/install) SDK
- Check: `flutter doctor`
- Have Android Studio / VS Code with Flutter extension

### Configure the API URL:

Edit `frontend/lib/constants/api_constants.dart`:

| Scenario | `baseUrl` value |
|---|---|
| Android Emulator | `http://10.0.2.2:8080` |
| iOS Simulator | `http://localhost:8080` |
| Physical Device | `http://YOUR_LOCAL_IP:8080` (e.g. `http://192.168.1.100:8080`) |
| Production | Your deployed server URL |

> 💡 To find your local IP on Windows: run `ipconfig` in Command Prompt

Also update `apiKey` to match your `.env` file:
```dart
static const String apiKey = 'my-secret-api-key-change-this';
```

### Commands:
```powershell
# Navigate to frontend folder
cd meeting-room-booking\frontend

# Get Flutter packages
flutter pub get

# Run on connected device or emulator
flutter run

# Or run on specific device
flutter run -d android
flutter run -d ios
```

---

## 📖 API Documentation (Swagger)

Once the backend is running, open your browser and go to:
```
http://localhost:8080/swagger/index.html
```

1. Click **Authorize** button (🔒)
2. Enter your API key: `my-secret-api-key-change-this`
3. You can now test all endpoints directly from the browser!

### API Endpoints

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| GET | `/health` | Server health check | ❌ |
| GET | `/api/bookings` | Get all bookings | ✅ |
| GET | `/api/bookings/:id` | Get single booking | ✅ |
| POST | `/api/bookings` | Create new booking | ✅ |
| PUT | `/api/bookings/:id` | Update booking | ✅ |
| DELETE | `/api/bookings/:id` | Delete booking | ✅ |

---

## 📱 App Screens

| Screen | Description |
|---|---|
| **Splash Screen** | Animated intro screen, navigates to list |
| **Booking List** | Shows all bookings as cards, FAB to add new |
| **Add Booking** | Form with date/time pickers, room dropdown |
| **Edit Booking** | Pre-filled form to update an existing booking |
| **Booking Detail** | Full details with edit/delete buttons |

---

## 🔐 Authentication

The app uses **API Key Authentication**:
- Every API request must include the header: `X-API-Key: your-api-key`
- Key is configured in `backend/.env` → `API_KEY=...`
- Key is configured in `frontend/lib/constants/api_constants.dart` → `apiKey`
- Both must match!

---

## 🏷️ Booking Status Values

| Status | Meaning |
|---|---|
| `pending` | Booking requested, not yet confirmed |
| `confirmed` | Booking is confirmed |
| `cancelled` | Booking has been cancelled |

---

## 🛠️ Backend Architecture (Layered)

```
HTTP Request
    ↓
[Controller] - Parses HTTP, returns JSON response
    ↓
[Service]    - Business logic and validation
    ↓
[Repository] - SQL queries against the database
    ↓
[Database]   - Supabase PostgreSQL
```

---

## ✅ Troubleshooting

| Problem | Solution |
|---|---|
| `SUPABASE_DB_URL not set` | Check your `.env` file exists and has the right value |
| `Failed to connect to database` | Check your Supabase URL, password, and network |
| Flutter `Connection refused` | Make sure backend is running; check `baseUrl` in `api_constants.dart` |
| `401 Unauthorized` | API key in Flutter doesn't match backend `.env` |
| `flutter pub get` fails | Run `flutter doctor` to check Flutter installation |
| `go mod tidy` fails | Run `go version` to check Go is installed |

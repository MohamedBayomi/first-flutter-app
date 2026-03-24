# Migration Plan: Separate Backend from Flutter App

## Problem

The current Flutter project contains JavaScript (Node.js) API files (`api/` folder) directly inside the Flutter app directory. According to domain expert Seif, this is **not recommended** for Flutter apps. The best practice is:

- **Flutter app** = pure Flutter/Dart code, consumes a Web API
- **Backend service** = standalone Node.js/Express project, communicates with MongoDB

## Current Architecture (Before)

```
first_flutter_application/
├── api/                          ← JS backend code INSIDE Flutter app (BAD)
│   ├── _mongodb.js               ← MongoDB connection helper
│   ├── get-clicks.js             ← GET /api/get-clicks endpoint
│   ├── increment-clicks.js       ← POST /api/increment-clicks endpoint
│   └── package.json              ← Node.js dependencies (mongodb ^6.19.0)
├── lib/
│   ├── main.dart                 ← Flutter app entry point
│   ├── config/
│   │   └── mongodb_config.dart   ← Stores Vercel API base URL
│   └── services/
│       └── mongodb_service.dart  ← HTTP calls to /api/* routes
├── vercel.json                   ← Vercel deployment config (serves both web + API)
└── pubspec.yaml                  ← Flutter dependencies (http: ^1.2.0)
```

**Issues:**
1. JS files mixed with Flutter project — violates separation of concerns
2. `vercel.json` couples Flutter web build with API routing
3. Config class is named `MongoDbConfig` but it's really an API URL config
4. Service class is named `MongoDbService` but it does HTTP calls, not MongoDB calls

## Target Architecture (After)

```
mobile-app/
├── first_flutter_application/     ← PURE Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/
│   │   │   └── api_config.dart    ← Renamed: backend API base URL
│   │   └── services/
│   │       └── api_service.dart   ← Renamed: HTTP client for backend API
│   └── pubspec.yaml
│
└── backend/                       ← STANDALONE Node.js backend service
    ├── server.js                  ← Express server entry point
    ├── package.json               ← Node.js dependencies (express, mongodb, cors, dotenv)
    ├── .env.example               ← Environment variables template
    └── routes/
        └── clicks.js              ← Click counter route handlers
```

## Migration Steps

### Step 1: Create Standalone Backend (`backend/` folder)

Create a new `backend/` directory **outside** the Flutter app (sibling folder at `mobile-app/backend/`):

| File | Purpose |
|------|---------|
| `package.json` | Dependencies: express, mongodb, cors, dotenv |
| `.env.example` | Template for `MONGODB_URI`, `MONGO_DATABASE`, `MONGO_COLLECTION`, `PORT` |
| `server.js` | Express app with CORS, listens on configurable port |
| `routes/clicks.js` | `GET /api/get-clicks` and `POST /api/increment-clicks` handlers |

### Step 2: Refactor Flutter App

| Action | File | Details |
|--------|------|---------|
| Rename | `mongodb_config.dart` → `api_config.dart` | Update class name to `ApiConfig`, point to backend URL |
| Rename | `mongodb_service.dart` → `api_service.dart` | Update class name to `ApiService`, update imports |
| Update | `main.dart` | Update import to use new service name |
| Delete | `api/` folder | Remove JS files from Flutter app |
| Delete | `vercel.json` | No longer needed (backend is separate) |

### Step 3: Update Flutter Config for All Platforms

| Platform | Base URL |
|----------|----------|
| Android Emulator | `http://10.0.2.2:3000` |
| iOS Simulator | `http://localhost:3000` |
| Web (browser) | `http://localhost:3000` |
| Production | Your deployed backend URL |

## Execution Checklist

- [ ] Create `backend/` folder with Express server
- [ ] Create `backend/package.json` with dependencies
- [ ] Create `backend/.env.example` with required env vars
- [ ] Create `backend/server.js` with Express + CORS + MongoDB
- [ ] Create `backend/routes/clicks.js` with GET/POST handlers
- [ ] Rename `lib/config/mongodb_config.dart` → `lib/config/api_config.dart`
- [ ] Rename `lib/services/mongodb_service.dart` → `lib/services/api_service.dart`
- [ ] Update `lib/main.dart` imports and references
- [ ] Remove `api/` folder from Flutter app
- [ ] Remove `vercel.json` from Flutter app

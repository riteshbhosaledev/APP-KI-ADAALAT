# Firebase Emulator Setup for Nyaay Dhrishti

This document provides instructions for setting up and using Firebase emulators for local development and testing.

## Prerequisites

1. Node.js (version 16 or higher)
2. Firebase CLI
3. Java Runtime Environment (for Firestore emulator)

## Installation

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase in your project

```bash
firebase init
```

Select the following services:
- Firestore
- Authentication
- Storage
- Emulators

## Emulator Configuration

Create a `firebase.json` file in your project root:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    },
    "singleProjectMode": true
  }
}
```

## Starting the Emulators

### Start all emulators
```bash
firebase emulators:start
```

### Start specific emulators
```bash
firebase emulators:start --only firestore,auth,storage
```

### Start with data import
```bash
firebase emulators:start --import=./emulator-data
```

### Start with data export on shutdown
```bash
firebase emulators:start --export-on-exit=./emulator-data
```

## Using Emulators in Flutter App

### Development Mode
To use emulators during development, update `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AppInitializationService().initialize(
    useEmulator: true, // Enable emulator mode
  );
  
  runApp(const MainApp());
}
```

### Environment-based Configuration
You can also use environment variables or build configurations:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const bool useEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
  
  await AppInitializationService().initialize(
    useEmulator: useEmulator,
  );
  
  runApp(const MainApp());
}
```

## Emulator URLs

When emulators are running, you can access:

- **Emulator UI**: http://localhost:4000
- **Firestore**: http://localhost:8080
- **Authentication**: http://localhost:9099
- **Storage**: http://localhost:9199

## Testing with Emulators

### Running Tests
```bash
# Start emulators in background
firebase emulators:exec --only firestore,auth "flutter test"
```

### Seeding Test Data
Create test data scripts to populate emulators:

```bash
# Create seed data
firebase emulators:exec --only firestore "node seed-data.js"
```

## Security Rules

### Firestore Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access during development
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Storage Rules (`storage.rules`)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

## Best Practices

1. **Always use emulators for development** - Never develop against production Firebase
2. **Export/Import data** - Use `--export-on-exit` to preserve data between sessions
3. **Separate test data** - Use different data sets for different test scenarios
4. **Clear data regularly** - Reset emulator data when needed for clean testing
5. **Version control** - Include emulator configuration in version control

## Troubleshooting

### Port Conflicts
If ports are in use, modify `firebase.json` to use different ports:

```json
{
  "emulators": {
    "firestore": {
      "port": 8081
    }
  }
}
```

### Connection Issues
- Ensure emulators are running before starting the app
- Check firewall settings
- Verify correct ports in app configuration

### Data Persistence
- Use `--export-on-exit` to save data
- Import data with `--import` flag
- Clear data with `firebase emulators:exec "rm -rf ./emulator-data"`

## Commands Reference

```bash
# Start emulators
firebase emulators:start

# Start with UI
firebase emulators:start --ui

# Start specific emulators
firebase emulators:start --only firestore,auth

# Export data on exit
firebase emulators:start --export-on-exit=./data

# Import existing data
firebase emulators:start --import=./data

# Run tests with emulators
firebase emulators:exec "flutter test"

# Kill all emulator processes
firebase emulators:kill
```
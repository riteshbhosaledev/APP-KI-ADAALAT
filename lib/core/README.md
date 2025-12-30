# Core Firebase Infrastructure

This directory contains the core Firebase infrastructure for the Nyaay Dhrishti court management system.

## Architecture Overview

The core infrastructure is organized into several key components:

### Services
- **FirebaseService**: Manages Firebase initialization and configuration
- **ConnectionService**: Monitors network connectivity and Firebase connection state
- **SyncService**: Handles data synchronization between offline and online states
- **AppInitializationService**: Coordinates initialization of all core services

### Repositories
- **BaseRepository**: Abstract base class providing common Firestore operations
- **ExampleRepository**: Concrete implementation demonstrating the repository pattern

### Configuration
- **FirebaseConfig**: Contains Firebase configuration for different platforms

### Utilities
- **EmulatorUtils**: Utilities for Firebase emulator setup and management

## Key Features

### 1. Offline Support
- Automatic offline persistence using Firestore's built-in capabilities
- Queue management for pending operations
- Conflict resolution using timestamp-based priority
- Sync status indication for users

### 2. Connection Management
- Real-time network connectivity monitoring
- Firebase connection state tracking
- Automatic reconnection handling
- Graceful degradation when offline

### 3. Repository Pattern
- Consistent data access layer across the application
- Type-safe CRUD operations
- Built-in error handling and logging
- Support for real-time streams and batch operations

### 4. Development Support
- Firebase emulator integration for local development
- Comprehensive testing utilities
- Debug logging and status monitoring
- Environment-based configuration

## Usage Examples

### Basic Repository Usage

```dart
// Create a repository instance
final repository = ExampleRepository();

// Create a new document
final model = ExampleModel(
  id: 'unique-id',
  name: 'Example Name',
  createdAt: DateTime.now(),
);
await repository.createWithId('unique-id', model);

// Read a document
final retrieved = await repository.getById('unique-id');

// Update a document
final updated = ExampleModel(
  id: 'unique-id',
  name: 'Updated Name',
  createdAt: retrieved!.createdAt,
);
await repository.update('unique-id', updated);

// Stream real-time updates
repository.streamById('unique-id').listen((model) {
  print('Model updated: ${model?.name}');
});
```

### Service Initialization

```dart
// Initialize all services
await AppInitializationService().initialize(
  useEmulator: true, // For development
);

// Check initialization status
final status = AppInitializationService().getInitializationStatus();
print('Initialized: ${status['isInitialized']}');
```

### Connection Monitoring

```dart
// Listen to connection changes
ConnectionService().addListener(() {
  final isOnline = ConnectionService().isOnline;
  final canSync = ConnectionService().canSyncData;
  print('Online: $isOnline, Can Sync: $canSync');
});
```

### Sync Management

```dart
// Force synchronization
try {
  await SyncService().forceSync();
  print('Sync completed successfully');
} catch (e) {
  print('Sync failed: $e');
}

// Check sync status
final syncStatus = SyncService().getSyncStatus();
print('Syncing: ${syncStatus['isSyncing']}');
print('Pending operations: ${syncStatus['pendingOperations']}');
```

## Development Setup

### 1. Firebase Emulator
For local development, use the Firebase emulator:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Start emulators
firebase emulators:start --only firestore,auth,storage
```

### 2. App Configuration
Enable emulator mode in your app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AppInitializationService().initialize(
    useEmulator: true, // Enable for development
  );
  
  runApp(const MainApp());
}
```

### 3. Testing
Run tests to verify the infrastructure:

```bash
flutter test test/core
```

## Error Handling

The infrastructure includes comprehensive error handling:

- **Network Errors**: Automatic retry with exponential backoff
- **Permission Errors**: Clear error messages and graceful degradation
- **Data Validation**: Client-side and server-side validation
- **Concurrent Access**: Optimistic locking and conflict resolution

## Security Considerations

- Role-based access control at the database level
- Data encryption for sensitive information
- Comprehensive audit logging
- Secure authentication with MFA support

## Performance Optimization

- Efficient query patterns with proper indexing
- Pagination for large result sets
- Caching strategies for frequently accessed data
- Batch operations for bulk updates

## Monitoring and Debugging

- Comprehensive logging throughout the system
- Connection state monitoring
- Sync status tracking
- Performance metrics collection

## Future Enhancements

- Advanced caching strategies
- Background sync optimization
- Enhanced conflict resolution
- Performance analytics integration
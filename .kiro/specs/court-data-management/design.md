# Design Document: Court Data Management System

## Overview

This design document outlines the Firebase Firestore database structure for the Nyaay Dhrishti court management system. The design replaces hardcoded mock data with a scalable, secure, and efficient database architecture that supports three user roles (Lawyers, Court Masters, Judges) and their specific workflows.

The database design follows Firebase best practices for NoSQL document-oriented storage, emphasizing security, performance, and maintainability. The structure supports real-time updates, offline capabilities, and role-based access control essential for court operations.

## Architecture

### Database Technology Stack
- **Primary Database**: Firebase Firestore (NoSQL document database)
- **File Storage**: Firebase Storage for document attachments
- **Authentication**: Firebase Authentication with custom claims for role management
- **Real-time Updates**: Firestore real-time listeners for live tracking
- **Offline Support**: Firestore offline persistence

### High-Level Architecture Principles
1. **Document-Oriented Design**: Each entity (user, case, hearing) is a document with nested data
2. **Collection Hierarchy**: Top-level collections for main entities, subcollections for related data
3. **Denormalization**: Strategic data duplication for query performance
4. **Security-First**: Role-based access control at the database level
5. **Real-time Capable**: Structure optimized for live updates and notifications

## Components and Interfaces

### Core Collections Structure

```
/users/{userId}
/cases/{caseId}
  /hearings/{hearingId}
  /documents/{documentId}
  /activities/{activityId}
/courts/{courtId}
  /causeList/{date}
  /sessions/{sessionId}
/notifications/{notificationId}
/analytics/{reportId}
```

### 1. Users Collection (`/users/{userId}`)

**Purpose**: Store user profiles for all three roles with role-specific data

**Document Structure**:
```dart
{
  // Common fields
  "userId": "string",
  "email": "string", 
  "displayName": "string",
  "role": "lawyer|court_master|judge", // enum
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "profileImageUrl": "string?",
  
  // Role-specific fields (conditional based on role)
  "lawyerProfile": {
    "barCouncilId": "string",
    "barCouncilState": "string",
    "practiceAreas": ["string"], // array of specializations
    "enrollmentYear": "number",
    "firmName": "string?",
    "address": "string",
    "phoneNumber": "string"
  },
  
  "courtMasterProfile": {
    "employeeId": "string",
    "courtId": "string", // reference to court
    "designation": "string",
    "permissions": ["string"], // array of permissions
    "assignedCourtrooms": ["string"]
  },
  
  "judgeProfile": {
    "judgeId": "string",
    "designation": "string", // "District Judge", "High Court Judge", etc.
    "courtId": "string", // reference to court
    "assignedCourtrooms": ["string"],
    "appointmentDate": "timestamp",
    "specialization": ["string"]
  },
  
  // Preferences and settings
  "notificationPreferences": {
    "pushNotifications": "boolean",
    "emailNotifications": "boolean",
    "smsNotifications": "boolean",
    "hearingReminders": "boolean"
  },
  
  // Statistics (denormalized for quick access)
  "stats": {
    "totalCases": "number",
    "activeCases": "number",
    "completedCases": "number",
    "lastLoginAt": "timestamp"
  }
}
```

### 2. Cases Collection (`/cases/{caseId}`)

**Purpose**: Store all case information with comprehensive legal details

**Document Structure**:
```dart
{
  "caseId": "string", // e.g., "CRL-2024-008"
  "caseNumber": "string", // court-assigned number
  "caseType": "string", // "Bail Application", "Writ Petition", etc.
  "caseTitle": "string", // "Petitioner vs Respondent"
  
  // Parties involved
  "petitioner": {
    "name": "string",
    "address": "string",
    "contactInfo": "string?",
    "lawyerId": "string" // reference to lawyer user
  },
  
  "respondent": {
    "name": "string",
    "address": "string",
    "contactInfo": "string?",
    "lawyerId": "string?" // reference to lawyer user if represented
  },
  
  // Case details
  "filingDate": "timestamp",
  "status": "string", // "filed", "under_scrutiny", "listed", "disposed", "defective"
  "priority": "string", // "high", "medium", "low"
  "tags": ["string"], // ["URGENT", "IN_CUSTODY", "MEDICAL"]
  
  // Court assignment
  "courtId": "string",
  "assignedJudgeId": "string?",
  "courtroom": "string?",
  
  // Legal information
  "sections": ["string"], // IPC sections, acts involved
  "summary": "string", // case summary
  "reliefSought": "string",
  "facts": "string",
  
  // Administrative details
  "affidavitId": "string?",
  "vakalatnamaNumber": "string?",
  "courtFee": {
    "amount": "number",
    "status": "string", // "paid", "pending", "exempted"
    "receiptNumber": "string?"
  },
  
  // Tracking information
  "hearingCount": "number",
  "lastHearingDate": "timestamp?",
  "nextHearingDate": "timestamp?",
  "estimatedDuration": "number", // in minutes
  
  // Metadata
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "createdBy": "string", // userId who created
  "lastModifiedBy": "string"
}
```

### 3. Hearings Subcollection (`/cases/{caseId}/hearings/{hearingId}`)

**Purpose**: Track individual hearing sessions for each case

**Document Structure**:
```dart
{
  "hearingId": "string",
  "caseId": "string", // parent case reference
  "hearingDate": "timestamp",
  "scheduledTime": "timestamp",
  "actualStartTime": "timestamp?",
  "actualEndTime": "timestamp?",
  
  // Hearing details
  "itemNumber": "number", // position in cause list
  "courtroom": "string",
  "judgeId": "string",
  "status": "string", // "scheduled", "running", "completed", "adjourned", "passed_over"
  
  // Participants
  "presentLawyers": ["string"], // array of lawyer userIds
  "absentLawyers": ["string"],
  "otherParticipants": ["string"],
  
  // Hearing outcome
  "outcome": "string", // "disposed", "adjourned", "part_heard", "dismissed"
  "nextHearingDate": "timestamp?",
  "orderSummary": "string?",
  "remarks": "string?",
  
  // Time tracking
  "estimatedDuration": "number", // minutes
  "actualDuration": "number?", // minutes
  "timeExtensions": [{
    "extensionMinutes": "number",
    "reason": "string",
    "grantedAt": "timestamp"
  }],
  
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 4. Documents Subcollection (`/cases/{caseId}/documents/{documentId}`)

**Purpose**: Manage case-related document attachments

**Document Structure**:
```dart
{
  "documentId": "string",
  "caseId": "string",
  "fileName": "string",
  "originalFileName": "string",
  "fileType": "string", // "pdf", "doc", "image", etc.
  "fileSize": "number", // bytes
  "storageUrl": "string", // Firebase Storage URL
  
  // Document metadata
  "documentType": "string", // "petition", "affidavit", "evidence", "order"
  "description": "string?",
  "tags": ["string"],
  
  // Access control
  "uploadedBy": "string", // userId
  "accessLevel": "string", // "public", "parties_only", "court_only"
  "allowedUsers": ["string"], // specific user access
  
  // Version control
  "version": "number",
  "isLatestVersion": "boolean",
  "parentDocumentId": "string?", // for versioning
  
  "uploadedAt": "timestamp",
  "lastAccessedAt": "timestamp?"
}
```

### 5. Courts Collection (`/courts/{courtId}`)

**Purpose**: Store court information and configuration

**Document Structure**:
```dart
{
  "courtId": "string",
  "courtName": "string",
  "courtType": "string", // "District Court", "High Court", "Supreme Court"
  "location": {
    "address": "string",
    "city": "string",
    "state": "string",
    "pincode": "string"
  },
  
  // Court configuration
  "courtrooms": [{
    "courtroomId": "string",
    "name": "string",
    "capacity": "number",
    "facilities": ["string"] // ["video_conferencing", "recording", etc.]
  }],
  
  // Working hours
  "workingHours": {
    "startTime": "string", // "10:00"
    "endTime": "string", // "17:00"
    "lunchBreak": {
      "startTime": "string",
      "endTime": "string"
    }
  },
  
  // Holidays and closures
  "holidays": ["timestamp"],
  "specialClosures": [{
    "date": "timestamp",
    "reason": "string"
  }],
  
  "isActive": "boolean",
  "createdAt": "timestamp"
}
```

### 6. Cause List Subcollection (`/courts/{courtId}/causeList/{date}`)

**Purpose**: Daily cause list management

**Document Structure**:
```dart
{
  "date": "string", // "2024-12-30"
  "courtId": "string",
  "courtroom": "string",
  "judgeId": "string",
  
  // Case list
  "cases": [{
    "itemNumber": "number",
    "caseId": "string",
    "caseTitle": "string",
    "caseType": "string",
    "lawyerIds": ["string"],
    "estimatedTime": "number", // minutes
    "scheduledTime": "string", // "10:30"
    "status": "string", // "waiting", "running", "completed", "adjourned"
    "priority": "string"
  }],
  
  // List metadata
  "totalCases": "number",
  "completedCases": "number",
  "currentItemNumber": "number",
  "estimatedEndTime": "string",
  
  // Status tracking
  "listStatus": "string", // "not_started", "running", "completed", "suspended"
  "startedAt": "timestamp?",
  "completedAt": "timestamp?",
  
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "createdBy": "string" // court master userId
}
```

### 7. Notifications Collection (`/notifications/{notificationId}`)

**Purpose**: Manage user notifications and alerts

**Document Structure**:
```dart
{
  "notificationId": "string",
  "recipientId": "string", // userId
  "type": "string", // "case_update", "hearing_reminder", "system_alert"
  "title": "string",
  "message": "string",
  "data": "map", // additional structured data
  
  // Notification state
  "isRead": "boolean",
  "isDelivered": "boolean",
  "deliveryMethod": ["string"], // ["push", "email", "sms"]
  
  // Related entities
  "relatedCaseId": "string?",
  "relatedHearingId": "string?",
  
  // Scheduling
  "scheduledFor": "timestamp?", // for future notifications
  "expiresAt": "timestamp?",
  
  "createdAt": "timestamp",
  "readAt": "timestamp?"
}
```

## Data Models

### User Role Hierarchy
```dart
enum UserRole {
  lawyer,
  court_master,
  judge
}

enum CaseStatus {
  filed,
  under_scrutiny,
  listed,
  running,
  disposed,
  defective,
  adjourned
}

enum HearingStatus {
  scheduled,
  running,
  completed,
  adjourned,
  passed_over,
  cancelled
}
```

### Security Rules Structure

The Firebase Security Rules will implement role-based access control:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own profile and update specific fields
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId
        && validateUserUpdate(resource.data, request.resource.data);
    }
    
    // Cases access based on role and involvement
    match /cases/{caseId} {
      allow read: if isAuthorizedForCase(caseId);
      allow create: if request.auth != null && hasRole('lawyer');
      allow update: if isAuthorizedForCaseUpdate(caseId);
    }
    
    // Court masters can manage cause lists
    match /courts/{courtId}/causeList/{date} {
      allow read: if request.auth != null;
      allow write: if hasRole('court_master') && isAssignedToCourt(courtId);
    }
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Let me analyze the acceptance criteria to determine which ones can be tested as properties:

### Property-Based Testing Overview

Property-based testing validates software correctness by testing universal properties across many generated inputs. Each property is a formal specification that should hold for all valid inputs.

Based on the prework analysis, the following correctness properties will ensure the system behaves correctly across all scenarios:

### Property 1: User Profile Creation Completeness
*For any* valid user registration data with a specified role, creating a user profile should result in a document containing all required role-specific fields and common user fields
**Validates: Requirements 1.1, 1.3**

### Property 2: Authentication and Session Persistence
*For any* valid user credentials, successful authentication should maintain session state across application restarts
**Validates: Requirements 1.2, 1.5**

### Property 3: Profile Update Persistence
*For any* user profile update operation, the changes should be immediately persisted to Firebase and reflected in subsequent reads
**Validates: Requirements 1.4**

### Property 4: Case Creation with Required Fields
*For any* valid case filing data, creating a case should result in a document with unique identifier and all mandatory fields (petitioner, respondent, case type, filing date)
**Validates: Requirements 2.1, 2.3**

### Property 5: Case Version History Maintenance
*For any* case update operation, the system should create a version history entry while preserving the previous state
**Validates: Requirements 2.2**

### Property 6: Case Status Propagation
*For any* case status change, all related hearing records should be updated to reflect the new status consistently
**Validates: Requirements 2.4**

### Property 7: Referential Integrity for Case Assignments
*For any* case record, the assigned lawyer and judge references should point to valid user documents with appropriate roles
**Validates: Requirements 2.5**

### Property 8: Document Storage with Security
*For any* document upload operation, the system should store the file with complete metadata and maintain proper access control references
**Validates: Requirements 2.6, 5.1, 5.3**

### Property 9: Hearing Creation Completeness
*For any* hearing scheduling operation, the system should create a hearing document with all required fields (date, time, courtroom) and proper case linkage
**Validates: Requirements 3.1**

### Property 10: Cause List Ordering
*For any* cause list generation, cases should be ordered by priority (high to low) and then by estimated duration (shortest first)
**Validates: Requirements 3.2**

### Property 11: Hearing Status Tracking
*For any* hearing record, the status field should only contain valid values from the defined enum and transitions should follow business rules
**Validates: Requirements 3.3**

### Property 12: Time Extension Calculations
*For any* hearing time extension, the estimated completion time should be recalculated by adding the extension minutes to the current estimate
**Validates: Requirements 3.4**

### Property 13: Hearing History Preservation
*For any* case, all associated hearing records should be preserved and accessible through the hearings subcollection
**Validates: Requirements 3.5**

### Property 14: Automatic Rescheduling for Passed Over Cases
*For any* case marked as "passed over", the system should automatically create a new hearing record with a future date
**Validates: Requirements 3.6**

### Property 15: Live Status Updates
*For any* hearing status change (start, complete), the live tracker should immediately update the status and broadcast to relevant users
**Validates: Requirements 4.1, 4.4**

### Property 16: Wait Time Calculations
*For any* change in current item number, the system should recalculate estimated wait times for all subsequent cases in the queue
**Validates: Requirements 4.2**

### Property 17: Live Update Broadcasting
*For any* case or hearing update, notifications should be sent to all users who have access to that case (lawyers, assigned judge, court master)
**Validates: Requirements 4.3**

### Property 18: Queue Position Accuracy
*For any* cause list, each case's queue position should accurately reflect its order in the list and update when cases are completed or passed over
**Validates: Requirements 4.5**

### Property 19: Document Access Control
*For any* document access attempt, the system should verify that the requesting user has appropriate permissions based on their role and case involvement
**Validates: Requirements 5.2, 10.1**

### Property 20: Document Format Support
*For any* file upload with supported format (PDF, DOC, images), the system should successfully store and process the document
**Validates: Requirements 5.5**

### Property 21: Document Sharing Permission Tracking
*For any* document sharing operation, the system should create permission records that accurately reflect who can access the document
**Validates: Requirements 5.4**

### Property 22: Scrutiny Workflow Automation
*For any* new case filing, the case should automatically appear in the scrutiny inbox with "under_scrutiny" status
**Validates: Requirements 6.1**

### Property 23: Case Review Data Completeness
*For any* case in scrutiny review, all required case details should be accessible to the court master
**Validates: Requirements 6.2**

### Property 24: Approval Workflow Transitions
*For any* case approval or rejection, the case status should change appropriately and notifications should be sent to the filing lawyer
**Validates: Requirements 6.3, 6.4**

### Property 25: Scrutiny Metrics Tracking
*For any* point in time, the system should maintain accurate counts of pending cases and timing information for the scrutiny process
**Validates: Requirements 6.5**

### Property 26: Comprehensive Notification System
*For any* significant system event (status changes, approaching hearings, urgent cases), appropriate notifications should be sent to relevant users based on their preferences
**Validates: Requirements 7.1, 7.2, 7.4, 7.5**

### Property 27: Notification Delivery Methods
*For any* notification, the system should deliver it through the user's preferred channels (push, in-app, email) as configured
**Validates: Requirements 7.3**

### Property 28: Data Synchronization
*For any* data change operation, when online the system should sync to Firebase immediately, and when offline should queue changes for later sync
**Validates: Requirements 8.1, 8.3**

### Property 29: Offline Data Access
*For any* essential data previously loaded, the system should provide read access even when offline
**Validates: Requirements 8.2**

### Property 30: Conflict Resolution
*For any* data conflict during synchronization, the system should resolve using timestamp-based priority (most recent wins)
**Validates: Requirements 8.4**

### Property 31: Sync Status Indication
*For any* synchronization operation, the system should display the current sync status to users
**Validates: Requirements 8.5**

### Property 32: Report Data Aggregation
*For any* report generation request, the system should aggregate data from the appropriate Firebase collections and calculate metrics correctly
**Validates: Requirements 9.1, 9.2**

### Property 33: Report Formatting and Privacy
*For any* data export operation, the system should format reports according to specifications while protecting sensitive information
**Validates: Requirements 9.3, 9.5**

### Property 34: Historical Data Preservation
*For any* system operation, historical data should be preserved and remain accessible for trend analysis
**Validates: Requirements 9.4**

### Property 35: Data Encryption
*For any* sensitive data storage operation, the system should encrypt the data before storing in Firebase
**Validates: Requirements 10.2**

### Property 36: Audit Trail Logging
*For any* data access or modification operation, the system should create appropriate audit log entries
**Validates: Requirements 10.3**

### Property 37: Secure Authentication
*For any* authentication attempt, the system should follow security best practices including support for multi-factor authentication
**Validates: Requirements 10.4**

## Error Handling

### Database Connection Errors
- **Offline Mode**: Implement Firestore offline persistence to handle network disconnections
- **Retry Logic**: Exponential backoff for failed operations
- **User Feedback**: Clear indicators when operations fail due to connectivity

### Data Validation Errors
- **Client-Side Validation**: Validate data before sending to Firebase
- **Server-Side Rules**: Use Firestore security rules for additional validation
- **Error Messages**: Provide specific, actionable error messages to users

### Permission Errors
- **Role Verification**: Check user roles before allowing operations
- **Graceful Degradation**: Show appropriate UI based on user permissions
- **Security Logging**: Log unauthorized access attempts

### Concurrent Access Errors
- **Optimistic Locking**: Use Firestore transactions for critical operations
- **Conflict Resolution**: Implement merge strategies for concurrent edits
- **User Notification**: Alert users when their changes conflict with others

## Testing Strategy

### Dual Testing Approach
The system will use both unit testing and property-based testing for comprehensive coverage:

**Unit Tests** will verify:
- Specific examples of data transformations
- Edge cases like empty inputs or boundary values
- Integration points between Firebase and the Flutter app
- Error conditions and exception handling

**Property-Based Tests** will verify:
- Universal properties across all valid inputs (minimum 100 iterations per test)
- Data consistency and integrity rules
- Security and access control properties
- Performance characteristics under various loads

### Property-Based Testing Configuration
- **Testing Framework**: Use `test` package with custom property testing utilities for Dart/Flutter
- **Minimum Iterations**: 100 test cases per property to ensure comprehensive coverage
- **Test Data Generation**: Smart generators that create realistic court data (cases, users, hearings)
- **Test Tagging**: Each property test tagged with format: **Feature: court-data-management, Property {number}: {property_text}**

### Firebase Testing Strategy
- **Emulator Suite**: Use Firebase Emulator for local testing without affecting production data
- **Security Rules Testing**: Dedicated tests for Firestore security rules validation
- **Performance Testing**: Monitor query performance and optimize indexes
- **Integration Testing**: End-to-end tests covering complete user workflows

### Test Data Management
- **Mock Data Generation**: Create realistic test data that mirrors production scenarios
- **Data Cleanup**: Automated cleanup of test data after test runs
- **Seed Data**: Consistent seed data for reproducible tests
- **Privacy Protection**: Ensure no real user data is used in tests
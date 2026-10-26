# Authentication Integration for Reservations API

## Overview

The reservations API has been successfully integrated with the existing authentication system. All API calls now automatically include authentication tokens and handle authentication errors gracefully.

## Changes Made

### 1. ReservationService Updates (`lib/services/reservation_service.dart`)

#### Token Integration
- Added SharedPreferences import for token management
- Modified `headers` getter to be async and include Bearer token
- Token is automatically retrieved from `'auth_token'` key in SharedPreferences

#### Enhanced Error Handling
- **401 Unauthorized**: "Authentication failed. Please login again."
- **403 Forbidden**: "Access denied. You do not have permission to access reservations."
- **Other errors**: Generic error messages with status codes

#### New Methods
```dart
Future<bool> isAuthenticated()        // Check if user has valid token
Future<void> clearAuthentication()    // Remove token from storage
```

### 2. BookingsPage Updates (`lib/Reservations.dart`)

#### Authentication Checking
- Added `_checkAuthenticationAndLoadReservations()` method
- Verifies authentication before attempting to load data
- Shows appropriate error message if not authenticated

#### Error Handling
- Added `_handleAuthenticationError()` method
- Shows SnackBar with login option on session expiry
- Updates error UI to show login button instead of retry for auth errors

#### UI Improvements
- Error state now shows "Login" button for authentication errors
- "Retry" button for other types of errors
- Session expiry SnackBar with direct login action

### 3. Translation Updates

#### English (`assets/translations/en.json`)
```json
{
  "authentication_required": "Please login to view your reservations",
  "session_expired": "Session expired. Please login again.",
  "access_denied": "Access denied. You do not have permission to access reservations.",
  "login_button": "Login"
}
```

#### Arabic (`assets/translations/ar.json`)
```json
{
  "authentication_required": "يرجى تسجيل الدخول لعرض حجوزاتك",
  "session_expired": "انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.",
  "access_denied": "تم رفض الوصول. ليس لديك إذن للوصول إلى الحجوزات.",
  "login_button": "تسجيل الدخول"
}
```

## Authentication Flow

### 1. Initial Load
```
BookingsPage.initState()
↓
_checkAuthenticationAndLoadReservations()
↓
ReservationService.isAuthenticated()
↓
If authenticated: _loadReservations()
If not authenticated: Show error message with login button
```

### 2. API Request Flow
```
_loadReservations()
↓
ReservationService.getReservations()
↓
Get token from SharedPreferences
↓
Add "Authorization: Bearer <token>" header
↓
Make HTTP request
↓
Handle response:
- 200: Success
- 401: Authentication failed → Show login prompt
- 403: Access denied → Show error
- Other: Generic error
```

### 3. Error Handling Flow
```
API Error (401/403)
↓
_handleAuthenticationError()
↓
Show SnackBar with "Session expired" message
↓
User clicks "Login" action
↓
Navigate to login page
```

## Security Features

### Token Storage
- Tokens stored securely in SharedPreferences
- Automatic token retrieval for all API calls
- Clean token removal on logout

### Error Handling
- Graceful handling of expired tokens
- Clear user feedback on authentication issues
- Automatic redirection to login when needed

### Session Management
- Authentication state checking before API calls
- Proper cleanup of authentication state
- User-friendly session expiry handling

## Usage Examples

### Check Authentication Status
```dart
final reservationService = ReservationService();
final isAuth = await reservationService.isAuthenticated();
if (!isAuth) {
  // Redirect to login
}
```

### Handle Authentication Errors
```dart
try {
  final reservations = await reservationService.getReservations();
  // Process reservations
} catch (e) {
  if (e.toString().contains('Authentication failed')) {
    // Handle auth error - redirect to login
  } else {
    // Handle other errors
  }
}
```

### Clear Authentication (Logout)
```dart
await reservationService.clearAuthentication();
// Redirect to login page
```

## Testing Authentication

### Test Cases
1. **Valid Token**: API calls should succeed with proper data
2. **Invalid Token**: Should show "Session expired" message
3. **No Token**: Should show "Please login" message
4. **Expired Token**: Should trigger logout flow
5. **Network Error**: Should show retry option

### Manual Testing
1. Login with valid credentials
2. Navigate to Bookings page
3. Verify reservations load properly
4. Clear token manually and refresh
5. Verify login prompt appears
6. Test logout and re-login flow

## Troubleshooting

### Common Issues
1. **No data loading**: Check if user is logged in
2. **Continuous login prompts**: Verify token storage
3. **API errors**: Check network connectivity and token validity

### Debugging
- Check SharedPreferences for `'auth_token'` key
- Verify API headers include Authorization header
- Monitor HTTP response codes for authentication issues

## Future Enhancements

1. **Token Refresh**: Implement automatic token refresh on expiry
2. **Biometric Auth**: Add fingerprint/face ID for quick login
3. **Offline Mode**: Cache data for offline viewing
4. **Multi-factor Auth**: Support for additional security layers

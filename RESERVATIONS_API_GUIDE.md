# Reservations API Integration Guide

This guide explains how the Minas Agency reservations API has been integrated into the Flutter app with full pagination support.

## Overview

The integration includes:
- Complete API models for handling reservation data
- Service class for API communication
- Pagination with infinite scroll
- Real-time filtering by service type, status, and date
- Error handling and loading states
- Attachment download functionality

## API Endpoint

```
GET https://minasagency.com/api/reservations
```

### Query Parameters
- `page`: Page number for pagination (default: 1)
- `service_id`: Filter by service ID (optional)
- `status`: Filter by reservation status (optional)
- `date`: Filter by date (optional)

## Files Added/Modified

### New Files
1. **`lib/models/reservation_model.dart`**
   - `ReservationResponse`: Main response wrapper
   - `ReservationsData`: Pagination data container
   - `ReservationModel`: Individual reservation data
   - `ServiceModel`: Service information with localized names
   - `LocalizedName`: Handles Arabic/English translations
   - `CompanyModel` & `CurrencyModel`: Company and currency data
   - `PaginationLink`: Navigation links for pagination

2. **`lib/services/reservation_service.dart`**
   - `ReservationService`: Main API service class
   - `getReservations()`: Fetch reservations with filtering and pagination
   - `getServices()`: Get available services
   - `ReservationException`: Custom exception handling

### Modified Files
1. **`lib/Reservations.dart`**
   - Complete refactor to use real API data
   - Infinite scroll pagination
   - Dynamic filtering with real-time updates
   - Error handling and loading states
   - Attachment download functionality

2. **`pubspec.yaml`**
   - Added `url_launcher: ^6.2.4` for opening PDF attachments

3. **`assets/translations/en.json` & `assets/translations/ar.json`**
   - Added new translation keys:
     - `all_services`, `all_status`, `completed`, `no_reservations_found`

## Features

### Pagination
- **Infinite Scroll**: Automatically loads more data when scrolling near the bottom
- **Loading Indicators**: Shows loading states for initial load and load-more operations
- **Error Handling**: Graceful error handling with retry functionality

### Filtering
- **Service Filter**: Dropdown with all available services from API
- **Status Filter**: Filter by reservation status (created, completed, cancelled)
- **Date Filter**: Date picker for filtering by specific dates
- **Real-time Updates**: Filters apply immediately and reset pagination

### UI Features
- **Pull-to-Refresh**: Swipe down to refresh data
- **Empty State**: Friendly message when no reservations found
- **Error State**: Clear error messages with retry options
- **Status Colors**: Color-coded status indicators
- **Attachment Downloads**: Direct download links for PDF attachments

### Localization
- **RTL Support**: Full right-to-left support for Arabic
- **Dynamic Service Names**: Service names load from API in user's language
- **Formatted Dates**: Proper date formatting
- **Currency Display**: Shows cost with proper currency symbols

## Authentication

The API service is now fully integrated with the app's authentication system:

### Token Management
- Tokens are automatically retrieved from SharedPreferences (`auth_token` key)
- All API requests include the `Authorization: Bearer <token>` header when available
- Authentication state is checked before making API calls

### Authentication Flow
1. **Login**: User tokens are stored in SharedPreferences during login
2. **API Calls**: Tokens are automatically included in all reservation API requests
3. **Session Expiry**: 401/403 responses trigger automatic logout flow
4. **Error Handling**: Users are redirected to login page when authentication fails

### Authentication Methods
```dart
// Check if user is authenticated
await reservationService.isAuthenticated()

// Clear authentication (logout)
await reservationService.clearAuthentication()
```

## Error Handling

The integration includes comprehensive error handling:
- **Network Errors**: Connection and timeout issues
- **API Errors**: Server response errors
- **Parsing Errors**: JSON parsing failures
- **User Feedback**: Clear error messages in UI

## Performance Considerations

- **Lazy Loading**: Only loads data as needed
- **Memory Management**: Proper disposal of resources
- **Efficient Scrolling**: Optimized ListView.builder
- **State Management**: Minimal rebuilds with targeted setState calls

## Future Enhancements

Potential improvements:
1. **Caching**: Implement local caching for offline support
2. **Real-time Updates**: WebSocket integration for live updates
3. **Advanced Filtering**: More filter options (date ranges, multiple services)
4. **Search**: Full-text search functionality
5. **Sorting**: Multiple sorting options (date, cost, status)

## Testing the Integration

To test the integration:
1. Ensure you have internet connectivity
2. Run the app and navigate to the Bookings page
3. Try different filters and observe real-time updates
4. Scroll to the bottom to test pagination
5. Pull down to test refresh functionality
6. Test attachment downloads if available

## Troubleshooting

Common issues and solutions:
1. **No data loading**: Check internet connection and API endpoint
2. **Infinite loading**: Verify API response format matches models
3. **Attachment not opening**: Ensure device has PDF viewer installed
4. **Filter not working**: Check if API supports the filter parameters

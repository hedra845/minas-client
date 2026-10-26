# Offers API Integration Guide

This guide explains how the Minas Agency offers API has been integrated into the Flutter app with full pagination support and token authentication.

## Overview

The integration includes:
- Complete API models for handling offers data
- Service class for API communication with token authentication
- Pagination with infinite scroll
- Real-time filtering by service type, status, and date
- Error handling and loading states
- Enhanced offer cards with discount display

## API Endpoint

```
GET https://minasagency.com/api/offers
```

### Authentication
All requests include the Bearer token from the user's session:
```
Authorization: Bearer <token>
```

### Query Parameters
- `page`: Page number for pagination (default: 1)
- `service_id`: Filter by service ID (optional)
- `status`: Filter by offer status (optional)
- `date`: Filter by date (optional)
- `search`: Search term for offers (optional)

### Response Structure
```json
{
  "services": [
    {
      "id": 1,
      "name": {
        "ar": "حجوزات تذاكر",
        "en": "Book tickets"
      },
      "icon": "string",
      "description": "string"
    }
  ],
  "serviceoffers": {
    "data": [
      {
        "id": 1,
        "title": "Special Visa Offer",
        "description": "Get 50% off on visa processing",
        "price": 250.00,
        "original_price": 500.00,
        "discount_percentage": 50,
        "image": "https://example.com/image.jpg",
        "service": {
          "id": 1,
          "name": {
            "ar": "التاشيرات",
            "en": "VISA"
          }
        },
        "valid_until": "2025-12-31T23:59:59.000000Z",
        "status": "active",
        "metadata": {}
      }
    ],
    "total": 25,
    "links": [
      {
        "url": null,
        "label": "&laquo; Previous",
        "active": false
      }
    ],
    "per_page": 10,
    "current_page": 1
  },
  "filters": []
}
```

## Files Added/Modified

### New Files

1. **`lib/models/offer_model.dart`**
   - `OffersResponse`: Main response wrapper
   - `ServiceOffersData`: Pagination data container
   - `OfferModel`: Individual offer data with discount calculations
   - `ServiceModel`: Service information with localized names
   - `LocalizedName`: Handles Arabic/English translations
   - `PaginationLink`: Navigation links for pagination

2. **`lib/services/offers_service.dart`**
   - `OffersService`: Main API service class with token authentication
   - `getOffers()`: Fetch offers with filtering and pagination
   - `getServices()`: Get available services for filtering
   - `getOfferById()`: Get specific offer details
   - `OffersException`: Custom exception handling

### Modified Files

1. **`lib/offers.dart`**
   - Complete refactor to use real API data
   - Infinite scroll pagination
   - Dynamic filtering with real-time updates
   - Error handling and loading states
   - Enhanced offer cards with discount display

2. **Translation Files**
   - Added new translation keys for offers functionality

## Features

### API Integration
- **Token Authentication**: All requests automatically include Bearer token
- **Error Handling**: Comprehensive handling of 401/403 authentication errors
- **Network Resilience**: Graceful handling of network errors

### Pagination
- **Infinite Scroll**: Automatically loads more data when scrolling near the bottom
- **Loading Indicators**: Shows loading states for initial load and load-more operations
- **Error Recovery**: Graceful error handling with retry functionality

### Filtering
- **Service Filter**: Dropdown with all available services from API
- **Status Filter**: Filter by offer status (active, inactive, expired)
- **Date Filter**: Date picker for filtering by specific dates
- **Real-time Updates**: Filters apply immediately and reset pagination

### Offer Display
- **Dynamic Images**: Network images with fallback to local assets
- **Discount Badges**: Visual discount percentage indicators
- **Price Display**: Original and discounted prices with strikethrough
- **Validity Dates**: Shows offer expiration dates
- **Service Labels**: Localized service names

### UI Features
- **Pull-to-Refresh**: Swipe down to refresh data
- **Empty State**: Friendly message when no offers found
- **Error State**: Clear error messages with retry options
- **Loading States**: Proper loading indicators
- **Responsive Design**: Adapts to different screen sizes

### Localization
- **RTL Support**: Full right-to-left support for Arabic
- **Dynamic Content**: Service names and offer details in user's language
- **Formatted Dates**: Proper date formatting
- **Currency Display**: Shows prices with proper currency symbols

## Model Structure

### OfferModel Properties
```dart
class OfferModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final String? image;
  final ServiceModel service;
  final DateTime? validUntil;
  final String status;
  final Map<String, dynamic>? metadata;

  // Computed properties
  bool get hasDiscount;
  double get discountAmount;
  int get calculatedDiscountPercentage;
}
```

### ServiceModel Properties
```dart
class ServiceModel {
  final int? id;
  final LocalizedName name;
  final String? icon;
  final String? description;
}
```

## Error Handling

The integration includes comprehensive error handling:

### Authentication Errors
- **401 Unauthorized**: "Authentication failed. Please login again."
- **403 Forbidden**: "Access denied. You do not have permission to access offers."
- **Auto-redirect**: Automatic navigation to login page on auth failure

### Network Errors
- **Connection Issues**: Clear error messages with retry options
- **Server Errors**: Specific error codes and messages
- **Timeout Handling**: Graceful timeout error handling

### User Feedback
- **SnackBar Messages**: Clear error notifications
- **Loading States**: Visual feedback during operations
- **Empty States**: Helpful messages when no data available

## Usage Examples

### Basic Usage
```dart
final offersService = OffersService();

// Get offers with pagination
final response = await offersService.getOffers(page: 1);

// Get offers with filters
final filteredResponse = await offersService.getOffers(
  page: 1,
  serviceId: 2,
  status: 'active',
  date: '2025-01-01',
);

// Get specific offer
final offer = await offersService.getOfferById(123);
```

### Error Handling
```dart
try {
  final offers = await offersService.getOffers();
  // Process offers
} on OffersException catch (e) {
  if (e.message.contains('Authentication failed')) {
    // Handle auth error - redirect to login
  } else {
    // Handle other errors
  }
} catch (e) {
  // Handle unexpected errors
}
```

## Translation Keys

### English
```json
{
  "no_offers_found": "No offers found",
  "active": "Active",
  "inactive": "Inactive",
  "expired": "Expired",
  "valid_until": "Valid until"
}
```

### Arabic
```json
{
  "no_offers_found": "لم يتم العثور على عروض",
  "active": "نشط",
  "inactive": "غير نشط",
  "expired": "منتهي الصلاحية",
  "valid_until": "صالح حتى"
}
```

## Performance Considerations

- **Lazy Loading**: Only loads data as needed
- **Memory Management**: Proper disposal of resources
- **Efficient Scrolling**: Optimized ListView.builder
- **Image Caching**: Network images with error fallbacks
- **State Management**: Minimal rebuilds with targeted setState calls

## Testing the Integration

### Manual Testing Steps
1. Ensure you have internet connectivity and are logged in
2. Navigate to the Offers page
3. Verify offers load from the API
4. Test different filters and observe real-time updates
5. Scroll to the bottom to test pagination
6. Pull down to test refresh functionality
7. Test authentication error handling by logging out

### Test Cases
1. **Valid Authentication**: Offers should load successfully
2. **Invalid Token**: Should show authentication error and redirect to login
3. **Network Error**: Should show retry option
4. **Empty Results**: Should show "No offers found" message
5. **Pagination**: Should load more offers when scrolling
6. **Filtering**: Should update results when filters change

## Future Enhancements

Potential improvements:
1. **Favorites**: Allow users to save favorite offers
2. **Push Notifications**: Notify users of new offers
3. **Advanced Search**: Full-text search with autocomplete
4. **Sorting Options**: Multiple sorting criteria
5. **Offer Details**: Dedicated offer detail pages
6. **Booking Integration**: Direct booking from offers
7. **Social Sharing**: Share offers with friends
8. **Offline Support**: Cache offers for offline viewing

## Troubleshooting

### Common Issues
1. **No data loading**: Check authentication status and network connectivity
2. **Images not loading**: Verify image URLs and network permissions
3. **Filters not working**: Check if API supports the filter parameters
4. **Pagination issues**: Verify API response format matches models

### Debug Information
```dart
// Check authentication
final isAuth = await offersService.isAuthenticated();
print('Is authenticated: $isAuth');

// Check API response
try {
  final response = await offersService.getOffers();
  print('Total offers: ${response.serviceoffers.total}');
  print('Current page: ${response.serviceoffers.currentPage}');
} catch (e) {
  print('API Error: $e');
}
```

## Security Considerations

- **Token Management**: Automatic token inclusion in all requests
- **Session Validation**: Proper handling of expired sessions
- **Error Exposure**: Safe error messages that don't expose sensitive data
- **Input Validation**: Proper validation of filter parameters

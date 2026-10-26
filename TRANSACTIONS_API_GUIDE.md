# Transactions API Integration Guide

This guide documents the integration of the Transactions API with token authentication in the Minas Client Flutter app.

## API Endpoint

**URL:** `https://minasagency.com/api/transactions`  
**Method:** GET  
**Authentication:** Bearer Token (required)

## API Response Structure

```json
{
  "transactions": [
    {
      "id": 51,
      "transaction_id": "RES-000029",
      "type": "reservation",
      "amount": "110.00",
      "status": "approved",
      "description": "Reservation for التاشيرات",
      "attachment": null,
      "attachment_type": null,
      "customer_id": 108,
      "payment_method_id": null,
      "created_at": "2025-09-30T14:52:56.000000Z",
      "updated_at": "2025-09-30T14:52:56.000000Z",
      "transaction_attachment": "https://minasagency.com/storage/",
      "transaction_image": "https://minasagency.com/storage/",
      "payment_method": null
    }
  ]
}
```

## Implementation Details

### 1. Data Models

**File:** `lib/models/transaction_model.dart`

#### TransactionsResponse
- Contains a list of transactions from the API response

#### TransactionModel
- Maps all transaction fields from the API
- Includes computed properties for formatting and localization:
  - `amountAsDouble`: Converts string amount to double
  - `formattedAmount`: Formats amount with 2 decimal places
  - `statusColor`: Returns appropriate color based on status
  - `localizedStatus`: Returns Arabic translation for status
  - `localizedType`: Returns Arabic translation for type
  - `formattedDate`: Formats date as dd/MM/yyyy
  - `formattedTime`: Formats time as HH:mm
  - `hasAttachment`: Checks if transaction has attachments
  - `attachmentUrl`: Returns the attachment URL if available

#### PaymentMethodModel
- Represents payment method information
- Contains id, name, type, and icon fields

### 2. Service Layer

**File:** `lib/services/transactions_service.dart`

#### TransactionsService
- Handles all API communication for transactions
- Uses `AuthService` for token management
- Includes methods:
  - `getTransactions()`: Fetches transactions with optional filtering
  - `getTransactionById()`: Fetches a specific transaction
  - `isAuthenticated()`: Checks authentication status
  - `clearAuthentication()`: Clears stored tokens

#### Authentication
- All requests include Bearer token in Authorization header
- Handles 401 (Unauthorized) and 403 (Forbidden) responses
- Integrates with existing `AuthService` for token management

#### Error Handling
- Custom `TransactionsException` for API-specific errors
- Network error handling with user-friendly messages
- Authentication error detection and handling

### 3. UI Implementation

**File:** `lib/presentaion/all_transactions.dart`

#### TransactionsPage
- Fetches and displays transactions from the API
- Includes loading states and error handling
- Features:
  - Pull-to-refresh functionality
  - Authentication status checking
  - Error messages with retry/login options
  - Empty state when no transactions found

#### TransactionCard
- Displays individual transaction information
- Supports both Arabic and English localization
- Shows:
  - Transaction type and status with color coding
  - Amount and transaction ID
  - Payment method information
  - Date and time formatting
  - Description (if available)
  - Attachment link (if available)

### 4. Authentication Integration

The transactions API integration uses the existing authentication system:

- **Token Storage:** Uses `AuthService` to manage authentication tokens
- **Header Management:** Automatically includes Bearer token in requests
- **Session Handling:** Detects expired sessions and prompts for re-login
- **Error Handling:** Provides appropriate feedback for authentication errors

### 5. Localization Support

The implementation includes full localization support:

#### English Translations
- "No transactions found"
- Status labels: "approved", "pending", "rejected", "cancelled"
- Type labels: "reservation", "payment", "refund", "deposit"
- UI labels: "Amount", "Payment Method", "Date", "Time", "Description"

#### Arabic Translations
- "لا توجد معاملات" (No transactions found)
- Status labels: "موافقة", "قيد الانتظار", "مرفوض", "ملغي"
- Type labels: "حجز", "دفع", "استرداد", "إيداع"
- UI labels: "الكمية", "طريقة الدفع", "التاريخ", "الوقت", "الوصف"

## Usage Examples

### Basic Usage
```dart
final transactionsService = TransactionsService();
final response = await transactionsService.getTransactions();
final transactions = response.transactions;
```

### With Filtering
```dart
final response = await transactionsService.getTransactions(
  status: 'approved',
  type: 'reservation',
  dateFrom: '2025-01-01',
  dateTo: '2025-12-31',
);
```

### Error Handling
```dart
try {
  final response = await transactionsService.getTransactions();
  // Handle success
} catch (e) {
  if (e is TransactionsException) {
    // Handle API-specific errors
    print('API Error: ${e.message}');
  } else {
    // Handle other errors
    print('Unexpected error: $e');
  }
}
```

## Status Mapping

The API returns status values that are mapped to colors and localized text:

| API Status | Color | English | Arabic |
|------------|-------|---------|--------|
| approved | Green (#035C01) | Approved | موافقة |
| pending | Orange (#FF8C00) | Pending | قيد الانتظار |
| rejected | Red (#D60000) | Rejected | مرفوض |
| cancelled | Red (#D60000) | Cancelled | ملغي |

## Type Mapping

Transaction types are also localized:

| API Type | English | Arabic |
|----------|---------|--------|
| reservation | Reservation | حجز |
| payment | Payment | دفع |
| refund | Refund | استرداد |
| deposit | Deposit | إيداع |

## Features

### 1. Real-time Data
- Fetches live transaction data from the API
- Supports pull-to-refresh for updated information

### 2. Authentication
- Secure token-based authentication
- Automatic session management
- Graceful handling of expired sessions

### 3. Error Handling
- Network error detection and recovery
- Authentication error handling with login prompts
- User-friendly error messages

### 4. Localization
- Full Arabic and English support
- RTL layout support for Arabic
- Localized date and time formatting

### 5. Attachments
- Support for transaction attachments
- Direct link to view/download attachments
- Handles both `attachment` and `transaction_attachment` fields

## Dependencies

The transactions API integration uses these packages:
- `http`: For API communication
- `easy_localization`: For internationalization
- `url_launcher`: For opening attachment links
- `intl`: For date/time formatting

## Testing

To test the transactions API integration:

1. Ensure you have a valid authentication token
2. Navigate to the transactions page in the app
3. Verify that transactions load correctly
4. Test pull-to-refresh functionality
5. Test error scenarios (network issues, authentication failures)
6. Verify localization works in both languages
7. Test attachment links (if available)

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure user is logged in
   - Check token validity
   - Verify API endpoint accessibility

2. **Network Errors**
   - Check internet connectivity
   - Verify API server status
   - Check for firewall/proxy issues

3. **Data Display Issues**
   - Verify API response format matches models
   - Check localization keys are properly defined
   - Ensure date/time parsing works correctly

### Debug Tips

1. Enable network logging to see API requests/responses
2. Check authentication token in requests
3. Verify error handling paths are working
4. Test with different transaction statuses and types

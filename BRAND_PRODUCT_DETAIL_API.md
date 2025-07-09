# Brand Product Detail API Implementation

This document describes the implementation of the brand product detail API based on the URL structure: `https://www.minsellprice.com/api/brands/Bull Grills/44000?product_id=203034`

## Overview

The implementation includes:
1. **API Model**: `BrandProductDetailResponse` with nested models for product details and vendor information
2. **Network Service**: Methods in `NetworkCalls` to fetch brand product details
3. **BLoC Pattern**: State management for handling API calls and responses
4. **Sample Screen**: Example implementation showing how to use the API

## API Endpoint

```
GET https://www.minsellprice.com/api/brands/{brandName}/{brandId}?product_id={productId}
```

### Parameters
- `brandName`: The name of the brand (e.g., "Bull Grills")
- `brandId`: The brand ID (e.g., "44000")
- `productId`: The specific product ID (e.g., 203034)

## Models

### BrandProductDetailResponse
Main response model containing:
- `brandName`: Brand name
- `brandKey`: Brand key identifier
- `brandId`: Brand ID
- `productDetail`: Product information
- `vendorProducts`: List of vendor products

### ProductDetail
Product information model containing:
- `productId`: Product ID
- `productName`: Product name
- `productMpn`: Product MPN
- `productImage`: Product image URL
- `msrp`: Manufacturer's suggested retail price
- `brandName`: Brand name
- `brandKey`: Brand key

### VendorProductDetail
Vendor product information model containing:
- `vendorProductId`: Vendor product ID
- `vendorName`: Vendor name
- `vendorUrl`: Vendor URL
- `vendorpricePrice`: Vendor price
- `vendorpriceDate`: Price date
- `vendorpriceShipping`: Shipping cost
- `vendorpriceExtraDiscount`: Extra discount
- `vendorSku`: Vendor SKU
- `deliveryText`: Delivery information
- `vendorpriceStockText`: Stock text
- `vendorpriceStock`: Stock quantity
- `vendorpriceIsbackorder`: Backorder status
- `vendorpriceOffers`: Special offers
- `vendorpriceDeliveryDate`: Delivery date
- `isSuspicious`: Suspicious activity flag
- `vendorPricingId`: Vendor pricing ID

## Usage Examples

### 1. Direct API Call

```dart
import 'package:minsellprice/reposotory_services/network_reposotory.dart';
import 'package:minsellprice/model/brand_product_detail_model.dart';

// Fetch brand product detail
final response = await NetworkCalls().getBrandProductDetail(
  'Bull Grills', // brandName
  '44000', // brandId
  203034, // productId
);

if (response != null) {
  print('Product: ${response.productDetail.productName}');
  print('Vendors: ${response.vendorProducts.length}');
  
  // Access vendor information
  for (final vendor in response.vendorProducts) {
    print('Vendor: ${vendor.vendorName} - Price: ${vendor.vendorpricePrice}');
  }
}
```

### 2. Using BLoC Pattern

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minsellprice/bloc/brand_product_detail_bloc/brand_product_detail_bloc.dart';
import 'package:minsellprice/bloc/brand_product_detail_bloc/brand_product_detail_event.dart';
import 'package:minsellprice/bloc/brand_product_detail_bloc/brand_product_detail_state.dart';

// In your widget
BlocProvider(
  create: (context) => BrandProductDetailBloc(),
  child: BlocBuilder<BrandProductDetailBloc, BrandProductDetailState>(
    builder: (context, state) {
      if (state is BrandProductDetailLoading) {
        return CircularProgressIndicator();
      } else if (state is BrandProductDetailLoaded) {
        return _buildProductDetail(state.brandProductDetail);
      } else if (state is BrandProductDetailError) {
        return Text('Error: ${state.message}');
      }
      return Container();
    },
  ),
);

// Trigger the API call
context.read<BrandProductDetailBloc>().add(
  FetchBrandProductDetail(
    brandName: 'Bull Grills',
    brandId: '44000',
    productId: 203034,
  ),
);
```

### 3. Complete Screen Example

See `lib/screens/brand_product_detail_screen.dart` for a complete implementation example.

## Integration with Existing Code

The new API can be integrated with your existing product screens:

1. **Import the required models and services**
2. **Add the API call method** to fetch brand product details
3. **Update your UI** to display the additional vendor information
4. **Handle loading and error states** appropriately

## Error Handling

The implementation includes comprehensive error handling:
- Network timeouts and connection errors
- Invalid response data
- API error responses
- Retry mechanism for failed requests

## Testing

To test the API implementation:

1. Use the provided sample screen: `BrandProductDetailScreen`
2. Test with different brand names and product IDs
3. Verify error handling with invalid parameters
4. Check the console logs for API response details

## Future Enhancements

Potential improvements:
- Caching mechanism for API responses
- Pagination for large vendor lists
- Filtering and sorting options
- Real-time price updates
- Push notifications for price changes 
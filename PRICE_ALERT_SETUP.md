# Price Alert System Setup Guide

## Overview
The updated price alert system now properly passes real API prices to Firebase and automatically monitors price changes using Firebase Functions.

## What's New

### 1. **Real API Price Integration**
- App now passes the actual `vendorpricePrice` from API to Firebase
- Default threshold is calculated based on real current price (10% below)
- Firebase stores both current price and threshold for comparison

### 2. **Automatic Price Monitoring**
- Firebase Functions run every 30 minutes to check all product prices
- Calls your MinSellPrice API to get real-time prices
- Compares current prices with user thresholds
- Sends notifications when prices drop below thresholds

## Setup Instructions

### Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Initialize Firebase Functions (if not already done)
```bash
firebase init functions
```

### Step 4: Install Dependencies
```bash
cd functions
npm install
```

### Step 5: Deploy Firebase Functions
```bash
firebase deploy --only functions
```

## How It Works

### 1. **User Sets Price Alert**
```
User opens product → Sees real price from API → 
Sets threshold (default: 10% below current) → 
App sends to Firebase: currentPrice + threshold
```

### 2. **Automatic Monitoring**
```
Every 30 minutes → Firebase Function runs → 
Calls MinSellPrice API → Gets real current price → 
Compares with user thresholds → Sends notifications if price drops
```

### 3. **Price Comparison Logic**
```javascript
// Firebase Function compares:
if (currentPrice <= alert.priceThreshold) {
  // Send notification
  // Mark alert as inactive
}
```

## API Integration

The Firebase Functions call your MinSellPrice API:
```javascript
const response = await axios.get(`https://growth.matridtech.net/api/product-details/${productId}`);
```

### API Response Expected Format:
```json
{
  "success": true,
  "data": {
    "vendorProductData": [
      {
        "vendorpricePrice": "299.99",
        "vendorName": "Amazon"
      },
      {
        "vendorpricePrice": "289.99", 
        "vendorName": "Walmart"
      }
    ]
  }
}
```

The system automatically finds the **lowest price** from all vendors.

## Firebase Database Structure

### Price Alerts Table:
```json
{
  "priceAlerts": {
    "alertId1": {
      "deviceToken": "user_device_token",
      "productId": "12345",
      "priceThreshold": 270.00,
      "currentPrice": 299.99,
      "productName": "Weber Grill",
      "productImage": "https://...",
      "productMpn": "WEB123",
      "platform": "android",
      "timestamp": 1234567890,
      "isActive": true
    }
  }
}
```

### Price Drop History:
```json
{
  "priceDropHistory": {
    "historyId1": {
      "productId": "12345",
      "productName": "Weber Grill",
      "deviceToken": "user_device_token",
      "oldPrice": 299.99,
      "newPrice": 269.99,
      "timestamp": 1234567890
    }
  }
}
```

## Testing the System

### 1. **Set Up a Test Alert**
- Open any product in the app
- Tap "Get Price Alerts"
- Set a threshold above current price
- Confirm subscription

### 2. **Trigger Manual Check**
```bash
curl -X POST https://your-project.cloudfunctions.net/triggerPriceCheck
```

### 3. **Check Specific Product**
```bash
curl -X POST https://your-project.cloudfunctions.net/checkProductPrice \
  -H "Content-Type: application/json" \
  -d '{"productId": "12345"}'
```

## Monitoring

### Firebase Console
- Go to Firebase Console → Functions → Logs
- Monitor function execution and errors
- Check price drop history

### Function Logs
```bash
firebase functions:log
```

## Customization Options

### 1. **Change Check Frequency**
Edit `functions/index.js`:
```javascript
// Every 15 minutes
exports.checkAllProductPrices = functions.pubsub.schedule('every 15 minutes').onRun(async (context) => {

// Every hour  
exports.checkAllProductPrices = functions.pubsub.schedule('every 1 hours').onRun(async (context) => {
```

### 2. **Modify API Endpoint**
Edit the `getCurrentPriceFromAPI` function in `functions/index.js`:
```javascript
const response = await axios.get(`https://your-custom-api.com/products/${productId}`);
```

### 3. **Add Price History Tracking**
```javascript
// Store price history for each product
await admin.database().ref(`priceHistory/${productId}`).push({
  price: currentPrice,
  timestamp: admin.database.ServerValue.TIMESTAMP,
});
```

## Troubleshooting

### Common Issues:

1. **Functions not deploying**
   - Check Node.js version (should be 18)
   - Verify Firebase project selection
   - Check billing is enabled

2. **API calls failing**
   - Verify API endpoint is correct
   - Check network connectivity
   - Review API response format

3. **Notifications not sending**
   - Verify device tokens are valid
   - Check Firebase Messaging setup
   - Review notification permissions

### Debug Commands:
```bash
# Check function status
firebase functions:list

# View logs
firebase functions:log --only checkAllProductPrices

# Test function locally
firebase emulators:start --only functions
```

## Cost Optimization

- **Free tier:** 2 million invocations/month
- **Typical usage:** 1,000 products × 48 checks/day = 48,000 invocations/month
- **Estimated cost:** ~$0.019/month

## Security Considerations

1. **API Rate Limiting**
   - Functions include delays between API calls
   - Consider implementing exponential backoff

2. **Data Privacy**
   - Device tokens are encrypted
   - Price data is anonymized in logs

3. **Access Control**
   - Functions run with Firebase Admin SDK
   - Database rules should restrict access

## Support

For issues or questions:
1. Check Firebase Console logs
2. Review function execution history
3. Test API endpoints manually
4. Verify database structure

---

**The price alert system is now fully automated and will monitor prices 24/7!** 🎉 
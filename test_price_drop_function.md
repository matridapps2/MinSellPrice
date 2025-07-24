 Test Price Drop Function

## **🧪 Add This to Your Firebase Functions**

Add this function to your `functions/index.js` file:

```javascript
// Test function to simulate price drops
exports.testPriceDrop = functions.https.onRequest(async (req, res) => {
  try {
    const { productId, newPrice } = req.body;
    
    if (!productId) {
      res.status(400).json({ error: 'Product ID required' });
      return;
    }

    // Use provided price or default test price
    const testPrice = newPrice || 4300.0;
    
    console.log(`Testing price drop for product ${productId} to $${testPrice}`);

    // Get all alerts for this product
    const alertsSnapshot = await admin.database()
      .ref('priceAlerts')
      .orderByChild('productId')
      .equalTo(productId)
      .once('value');
    
    const alerts = alertsSnapshot.val();
    const triggeredAlerts = [];

    if (alerts) {
      for (const alertId in alerts) {
        const alert = alerts[alertId];
        
        if (alert.isActive && testPrice <= alert.priceThreshold) {
          console.log(`Triggering alert for ${alert.productName} at $${testPrice}`);
          
          // Send test notification
          await sendPriceDropNotification(alert, testPrice);
          
          // Mark alert as inactive
          await admin.database().ref(`priceAlerts/${alertId}/isActive`).set(false);
          
          triggeredAlerts.push({
            alertId: alertId,
            productName: alert.productName,
            threshold: alert.priceThreshold,
            newPrice: testPrice
          });
        }
      }
    }

    res.json({ 
      success: true, 
      productId: productId,
      testPrice: testPrice,
      triggeredAlerts: triggeredAlerts,
      message: `Test completed. ${triggeredAlerts.length} alerts triggered.`
    });
  } catch (error) {
    console.error('Error in test price drop:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Test function to check all products
exports.testAllPriceDrops = functions.https.onRequest(async (req, res) => {
  try {
    console.log('Testing price drops for all active alerts...');
    
    // Get all active alerts
    const alertsSnapshot = await admin.database().ref('priceAlerts').once('value');
    const alerts = alertsSnapshot.val();

    if (!alerts) {
      res.json({ success: true, message: 'No alerts to test' });
      return;
    }

    const testResults = [];

    // Test each alert with a random price drop
    for (const alertId in alerts) {
      const alert = alerts[alertId];
      
      if (alert.isActive) {
        // Generate a test price (random drop between 10-30%)
        const originalPrice = alert.priceThreshold * 1.2; // Assume original was 20% higher
        const dropPercentage = 0.1 + (Math.random() * 0.2); // 10-30% drop
        const testPrice = originalPrice * (1 - dropPercentage);
        
        if (testPrice <= alert.priceThreshold) {
          console.log(`Testing: ${alert.productName} - ${originalPrice} → ${testPrice}`);
          
          // Send test notification
          await sendPriceDropNotification(alert, testPrice);
          
          // Mark alert as inactive
          await admin.database().ref(`priceAlerts/${alertId}/isActive`).set(false);
          
          testResults.push({
            productName: alert.productName,
            originalPrice: originalPrice.toFixed(2),
            testPrice: testPrice.toFixed(2),
            threshold: alert.priceThreshold,
            triggered: true
          });
        } else {
          testResults.push({
            productName: alert.productName,
            originalPrice: originalPrice.toFixed(2),
            testPrice: testPrice.toFixed(2),
            threshold: alert.priceThreshold,
            triggered: false
          });
        }
      }
    }

    res.json({ 
      success: true, 
      testResults: testResults,
      totalAlerts: Object.keys(alerts).length,
      triggeredCount: testResults.filter(r => r.triggered).length,
      message: `Test completed. ${testResults.filter(r => r.triggered).length} alerts triggered.`
    });
  } catch (error) {
    console.error('Error in test all price drops:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

## **🚀 How to Test**

### **1. Deploy the Functions:**
```bash
firebase deploy --only functions
```

### **2. Test Single Product:**
```bash
curl -X POST https://your-project.cloudfunctions.net/testPriceDrop \
  -H "Content-Type: application/json" \
  -d '{"productId": "grill-123", "newPrice": 4300}'
```

### **3. Test All Products:**
```bash
curl -X POST https://your-project.cloudfunctions.net/testAllPriceDrops
```

### **4. Test from Your App:**
Use the "Test Drop" button I added to your product details screen.

## **📱 Test Scenarios**

### **Scenario 1: Price Drops Below Threshold**
```
Original Price: $4798
User Sets Alert: $4318
Test Price: $4300
Result: ✅ Notification Sent
```

### **Scenario 2: Price Drops Above Threshold**
```
Original Price: $4798
User Sets Alert: $4318
Test Price: $4500
Result: ❌ No Notification
```

### **Scenario 3: No Active Alert**
```
User has no alert set
Test Price: $4300
Result: ❌ No Notification
```

## **🔍 Monitor Test Results**

### **1. Check Firebase Console:**
- Go to **Functions** → **Logs**
- Look for test function executions
- Check notification sends

### **2. Check Database:**
- Go to **Realtime Database**
- Look for alerts marked as `isActive: false`
- Check `priceDropHistory` for test records

### **3. Check Your Phone:**
- Look for push notifications
- Check notification content
- Test notification tap behavior

## **🎯 Expected Results**

### **When Test Succeeds:**
```
✅ Notification received on phone
✅ Alert marked as inactive in Firebase
✅ Price drop history recorded
✅ Success message in function logs
```

### **When Test Fails:**
```
❌ No notification received
❌ Alert remains active
❌ Error message in function logs
```

This test setup will help you verify that your price alert system works correctly before connecting to real APIs! 
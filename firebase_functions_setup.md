# Firebase Functions Setup for Automatic Price Alerts

## Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
```

## Step 2: Login to Firebase
```bash
firebase login
```

## Step 3: Initialize Firebase Functions
```bash
firebase init functions
```

## Step 4: Create Firebase Functions for Automatic Price Monitoring

Create `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// ===== AUTOMATIC PRICE MONITORING =====

// Function that runs every 30 minutes to check all product prices
exports.checkAllProductPrices = functions.pubsub.schedule('every 30 minutes').onRun(async (context) => {
  try {
    console.log('Starting automatic price check...');
    
    // Get all active price alerts
    const alertsSnapshot = await admin.database().ref('priceAlerts').once('value');
    const alerts = alertsSnapshot.val();

    if (!alerts) {
      console.log('No price alerts found');
      return null;
    }

    // Group alerts by product ID to avoid duplicate API calls
    const productAlerts = {};
    for (const alertId in alerts) {
      const alert = alerts[alertId];
      if (alert.isActive) {
        if (!productAlerts[alert.productId]) {
          productAlerts[alert.productId] = [];
        }
        productAlerts[alert.productId].push({ alertId, ...alert });
      }
    }

    // Check each unique product
    for (const productId in productAlerts) {
      try {
        const currentPrice = await getCurrentPriceFromAPI(productId);
        
        if (currentPrice !== null) {
          // Check all alerts for this product
          for (const alert of productAlerts[productId]) {
            if (currentPrice <= alert.priceThreshold) {
              // Price dropped! Send notification
              await sendPriceDropNotification(alert, currentPrice);
              
              // Mark alert as inactive
              await admin.database().ref(`priceAlerts/${alert.alertId}/isActive`).set(false);
              
              console.log(`Price alert triggered for product ${productId}: ${alert.priceThreshold} -> ${currentPrice}`);
            }
          }
        }
      } catch (error) {
        console.error(`Error checking product ${productId}:`, error);
      }
    }

    console.log('Automatic price check completed');
    return null;
  } catch (error) {
    console.error('Error in automatic price check:', error);
    return null;
  }
});

// Function to get current price from your API
async function getCurrentPriceFromAPI(productId) {
  try {
    // Replace this with your actual API endpoint
    const response = await axios.get(`https://your-api.com/products/${productId}`, {
      timeout: 10000, // 10 second timeout
      headers: {
        'User-Agent': 'MinSellPrice-Bot/1.0',
        // Add any required API keys or headers
        // 'Authorization': 'Bearer YOUR_API_KEY',
      }
    });

    if (response.data && response.data.price) {
      return parseFloat(response.data.price);
    } else if (response.data && response.data.currentPrice) {
      return parseFloat(response.data.currentPrice);
    } else if (response.data && response.data.priceData) {
      return parseFloat(response.data.priceData.current);
    }

    console.log(`No price found in API response for product ${productId}`);
    return null;
  } catch (error) {
    console.error(`API error for product ${productId}:`, error.message);
    return null;
  }
}

// Function to send price drop notification
async function sendPriceDropNotification(alert, currentPrice) {
  try {
    const message = {
      token: alert.deviceToken,
      notification: {
        title: '🎉 Price Drop Alert!',
        body: `${alert.productName} is now $${currentPrice.toFixed(2)}!`,
      },
      data: {
        productId: alert.productId,
        currentPrice: currentPrice.toString(),
        priceThreshold: alert.priceThreshold.toString(),
        type: 'price_drop',
      },
      android: {
        notification: {
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          channelId: 'price_alerts',
          priority: 'high',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log('Price drop notification sent:', response);
    
    // Log the price drop event
    await admin.database().ref('priceDropHistory').push({
      productId: alert.productId,
      productName: alert.productName,
      deviceToken: alert.deviceToken,
      oldPrice: alert.priceThreshold,
      newPrice: currentPrice,
      timestamp: admin.database.ServerValue.TIMESTAMP,
    });
    
  } catch (error) {
    console.error('Error sending price drop notification:', error);
  }
}

// ===== MANUAL TRIGGERS =====

// HTTP function to manually check a specific product
exports.checkProductPrice = functions.https.onRequest(async (req, res) => {
  try {
    const { productId } = req.body;
    
    if (!productId) {
      res.status(400).json({ error: 'Product ID required' });
      return;
    }

    console.log(`Manual price check for product: ${productId}`);
    
    const currentPrice = await getCurrentPriceFromAPI(productId);
    
    if (currentPrice === null) {
      res.status(404).json({ error: 'Price not available' });
      return;
    }

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
        
        if (alert.isActive && currentPrice <= alert.priceThreshold) {
          await sendPriceDropNotification(alert, currentPrice);
          await admin.database().ref(`priceAlerts/${alertId}/isActive`).set(false);
          triggeredAlerts.push(alertId);
        }
      }
    }

    res.json({ 
      success: true, 
      currentPrice: currentPrice,
      triggeredAlerts: triggeredAlerts.length,
      message: `Checked price: $${currentPrice.toFixed(2)}`
    });
  } catch (error) {
    console.error('Error in manual price check:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// HTTP function to check all products immediately
exports.triggerPriceCheck = functions.https.onRequest(async (req, res) => {
  try {
    console.log('Manual trigger of price check...');
    
    // Get all active alerts
    const alertsSnapshot = await admin.database().ref('priceAlerts').once('value');
    const alerts = alertsSnapshot.val();

    if (!alerts) {
      res.json({ success: true, message: 'No alerts to check' });
      return;
    }

    // Group by product ID
    const productAlerts = {};
    for (const alertId in alerts) {
      const alert = alerts[alertId];
      if (alert.isActive) {
        if (!productAlerts[alert.productId]) {
          productAlerts[alert.productId] = [];
        }
        productAlerts[alert.productId].push({ alertId, ...alert });
      }
    }

    let checkedProducts = 0;
    let triggeredAlerts = 0;

    // Check each product
    for (const productId in productAlerts) {
      try {
        const currentPrice = await getCurrentPriceFromAPI(productId);
        checkedProducts++;
        
        if (currentPrice !== null) {
          for (const alert of productAlerts[productId]) {
            if (currentPrice <= alert.priceThreshold) {
              await sendPriceDropNotification(alert, currentPrice);
              await admin.database().ref(`priceAlerts/${alert.alertId}/isActive`).set(false);
              triggeredAlerts++;
            }
          }
        }
      } catch (error) {
        console.error(`Error checking product ${productId}:`, error);
      }
    }

    res.json({ 
      success: true, 
      checkedProducts,
      triggeredAlerts,
      message: `Checked ${checkedProducts} products, triggered ${triggeredAlerts} alerts`
    });
  } catch (error) {
    console.error('Error in trigger price check:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===== UTILITY FUNCTIONS =====

// Function to clean up old alerts (runs daily)
exports.cleanupOldAlerts = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  try {
    const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
    
    const alertsSnapshot = await admin.database()
      .ref('priceAlerts')
      .orderByChild('timestamp')
      .endAt(thirtyDaysAgo)
      .once('value');
    
    const oldAlerts = alertsSnapshot.val();
    
    if (oldAlerts) {
      for (const alertId in oldAlerts) {
        await admin.database().ref(`priceAlerts/${alertId}`).remove();
      }
      console.log(`Cleaned up ${Object.keys(oldAlerts).length} old alerts`);
    }
    
    return null;
  } catch (error) {
    console.error('Error cleaning up old alerts:', error);
    return null;
  }
});

// Function to get price history for analytics
exports.getPriceHistory = functions.https.onRequest(async (req, res) => {
  try {
    const { productId, days = 7 } = req.query;
    
    if (!productId) {
      res.status(400).json({ error: 'Product ID required' });
      return;
    }

    const startTime = Date.now() - (parseInt(days) * 24 * 60 * 60 * 1000);
    
    const historySnapshot = await admin.database()
      .ref('priceDropHistory')
      .orderByChild('productId')
      .equalTo(productId)
      .once('value');
    
    const history = historySnapshot.val();
    const filteredHistory = [];

    if (history) {
      for (const recordId in history) {
        const record = history[recordId];
        if (record.timestamp >= startTime) {
          filteredHistory.push(record);
        }
      }
    }

    res.json({ 
      success: true, 
      productId,
      history: filteredHistory,
      count: filteredHistory.length
    });
  } catch (error) {
    console.error('Error getting price history:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

## Step 5: Install Dependencies
```bash
cd functions
npm install axios
```

## Step 6: Configure Your API Endpoint

Update the `getCurrentPriceFromAPI` function with your actual API:

```javascript
// Example for different API formats:

// Format 1: Simple price field
const response = await axios.get(`https://your-api.com/products/${productId}`);
return parseFloat(response.data.price);

// Format 2: Nested price structure
const response = await axios.get(`https://your-api.com/products/${productId}`);
return parseFloat(response.data.product.price);

// Format 3: Multiple price options
const response = await axios.get(`https://your-api.com/products/${productId}`);
return parseFloat(response.data.prices.current);

// Format 4: With authentication
const response = await axios.get(`https://your-api.com/products/${productId}`, {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY',
    'X-API-Key': 'YOUR_API_KEY',
  }
});
return parseFloat(response.data.price);
```

## Step 7: Deploy Functions
```bash
firebase deploy --only functions
```

## Step 8: Test Automatic Monitoring

1. **Set up a price alert in your app**
2. **Wait for the scheduled function to run** (every 30 minutes)
3. **Or trigger manually:**
   ```bash
   curl -X POST https://your-project.cloudfunctions.net/triggerPriceCheck
   ```

## Step 9: Monitor Function Execution

Check Firebase Console → Functions → Logs to see:
- When functions run
- API responses
- Notification sends
- Any errors

## ⚡ **How It Works:**

### **Automatic Flow:**
```
Every 30 minutes → Check all active alerts → 
Get prices from your API → Compare with thresholds → 
Send notifications if price drops → Mark alerts as inactive
```

### **Manual Trigger:**
```
User action → HTTP function → Check specific product → 
Send notification immediately
```

## 🔧 **Customization Options:**

### **1. Change Check Frequency:**
```javascript
// Every 15 minutes
exports.checkAllProductPrices = functions.pubsub.schedule('every 15 minutes').onRun(async (context) => {

// Every hour
exports.checkAllProductPrices = functions.pubsub.schedule('every 1 hours').onRun(async (context) => {

// Every 6 hours
exports.checkAllProductPrices = functions.pubsub.schedule('every 6 hours').onRun(async (context) => {
```

### **2. Add Price Tracking:**
```javascript
// Store price history
await admin.database().ref(`priceHistory/${productId}`).push({
  price: currentPrice,
  timestamp: admin.database.ServerValue.TIMESTAMP,
});
```

### **3. Add Multiple API Sources:**
```javascript
async function getCurrentPriceFromAPI(productId) {
  // Try primary API
  let price = await getPriceFromPrimaryAPI(productId);
  
  // Fallback to secondary API
  if (price === null) {
    price = await getPriceFromSecondaryAPI(productId);
  }
  
  return price;
}
```

## 💰 **Cost Optimization:**

- **Free tier:** 2 million invocations/month
- **Typical usage:** 1,000 products × 48 checks/day = 48,000 invocations/month
- **Cost:** ~$0.019/month (very affordable!)

Your price alert system will now automatically monitor prices and send notifications when they drop, without any manual intervention! 
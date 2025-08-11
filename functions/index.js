// const functions = require('firebase-functions');
// const admin = require('firebase-admin');
// const axios = require('axios');

// admin.initializeApp();

// // ===== AUTOMATIC PRICE MONITORING =====

// // Function that runs every 30 minutes to check all product prices
// exports.checkAllProductPrices = functions.pubsub.schedule('every 30 minutes').onRun(async (context) => {
//   try {
//     console.log('Starting automatic price check...');
    
//     // Get all active price alerts
//     const alertsSnapshot = await admin.database().ref('priceAlerts').once('value');
//     const alerts = alertsSnapshot.val();

//     if (!alerts) {
//       console.log('No price alerts found');
//       return null;
//     }

//     // Group alerts by product ID to avoid duplicate API calls
//     const productAlerts = {};
//     for (const alertId in alerts) {
//       const alert = alerts[alertId];
//       if (alert.isActive) {
//         if (!productAlerts[alert.productId]) {
//           productAlerts[alert.productId] = [];
//         }
//         productAlerts[alert.productId].push({ alertId, ...alert });
//       }
//     }

//     // Check each unique product
//     for (const productId in productAlerts) {
//       try {
//         const currentPrice = await getCurrentPriceFromAPI(productId);
        
//         if (currentPrice !== null) {
//           // Check all alerts for this product
//           for (const alert of productAlerts[productId]) {
//             if (currentPrice <= alert.priceThreshold) {
//               // Price dropped! Send notification
//               await sendPriceDropNotification(alert, currentPrice);
              
//               // Mark alert as inactive
//               await admin.database().ref(`priceAlerts/${alert.alertId}/isActive`).set(false);
              
//               console.log(`Price alert triggered for product ${productId}: ${alert.priceThreshold} -> ${currentPrice}`);
//             }
//           }
//         }
//       } catch (error) {
//         console.error(`Error checking product ${productId}:`, error);
//       }
//     }

//     console.log('Automatic price check completed');
//     return null;
//   } catch (error) {
//     console.error('Error in automatic price check:', error);
//     return null;
//   }
// });

// // Function to get current price from MinSellPrice API
// async function getCurrentPriceFromAPI(productId) {
//   try {
//     // Call MinSellPrice API to get current product price
//     const response = await axios.get(`https://growth.matridtech.net/api/product-details/${productId}`, {
//       timeout: 10000, // 10 second timeout
//       headers: {
//         'User-Agent': 'MinSellPrice-Bot/1.0',
//         'Content-Type': 'application/json',
//       }
//     });

//     if (response.data && response.data.success) {
//       const productData = response.data.data;
      
//       // Get the lowest price from vendor products
//       if (productData.vendorProductData && productData.vendorProductData.length > 0) {
//         let lowestPrice = null;
        
//         for (const vendor of productData.vendorProductData) {
//           if (vendor.vendorpricePrice && vendor.vendorpricePrice !== '--') {
//             const price = parseFloat(vendor.vendorpricePrice);
//             if (!isNaN(price) && (lowestPrice === null || price < lowestPrice)) {
//               lowestPrice = price;
//             }
//           }
//         }
        
//         return lowestPrice;
//       }
//     }

//     console.log(`No price found in API response for product ${productId}`);
//     return null;
//   } catch (error) {
//     console.error(`API error for product ${productId}:`, error.message);
//     return null;
//   }
// }

// // Function to send price drop notification
// async function sendPriceDropNotification(alert, currentPrice) {
//   try {
//     const message = {
//       token: alert.deviceToken,
//       notification: {
//         title: '🎉 Price Drop Alert!',
//         body: `${alert.productName} is now $${currentPrice.toFixed(2)}!`,
//       },
//       data: {
//         productId: alert.productId,
//         currentPrice: currentPrice.toString(),
//         priceThreshold: alert.priceThreshold.toString(),
//         type: 'price_drop',
//       },
//       android: {
//         notification: {
//           clickAction: 'FLUTTER_NOTIFICATION_CLICK',
//           channelId: 'price_alerts',
//           priority: 'high',
//           sound: 'default',
//         },
//       },
//       apns: {
//         payload: {
//           aps: {
//             sound: 'default',
//             badge: 1,
//           },
//         },
//       },
//     };

//     const response = await admin.messaging().send(message);
//     console.log('Price drop notification sent:', response);
    
//     // Log the price drop event
//     await admin.database().ref('priceDropHistory').push({
//       productId: alert.productId,
//       productName: alert.productName,
//       deviceToken: alert.deviceToken,
//       oldPrice: alert.currentPrice || alert.priceThreshold,
//       newPrice: currentPrice,
//       timestamp: admin.database.ServerValue.TIMESTAMP,
//     });
    
//   } catch (error) {
//     console.error('Error sending price drop notification:', error);
//   }
// }

// // ===== MANUAL TRIGGERS =====

// // HTTP function to manually check a specific product
// exports.checkProductPrice = functions.https.onRequest(async (req, res) => {
//   try {
//     const { productId } = req.body;
    
//     if (!productId) {
//       res.status(400).json({ error: 'Product ID required' });
//       return;
//     }

//     console.log(`Manual price check for product: ${productId}`);
    
//     const currentPrice = await getCurrentPriceFromAPI(productId);
    
//     if (currentPrice === null) {
//       res.status(404).json({ error: 'Price not available' });
//       return;
//     }

//     // Get all alerts for this product
//     const alertsSnapshot = await admin.database()
//       .ref('priceAlerts')
//       .orderByChild('productId')
//       .equalTo(productId)
//       .once('value');
    
//     const alerts = alertsSnapshot.val();
//     const triggeredAlerts = [];

//     if (alerts) {
//       for (const alertId in alerts) {
//         const alert = alerts[alertId];
        
//         if (alert.isActive && currentPrice <= alert.priceThreshold) {
//           await sendPriceDropNotification(alert, currentPrice);
//           await admin.database().ref(`priceAlerts/${alertId}/isActive`).set(false);
//           triggeredAlerts.push(alertId);
//         }
//       }
//     }

//     res.json({ 
//       success: true, 
//       currentPrice: currentPrice,
//       triggeredAlerts: triggeredAlerts.length,
//       message: `Checked price: $${currentPrice.toFixed(2)}`
//     });
//   } catch (error) {
//     console.error('Error in manual price check:', error);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });

// // HTTP function to check all products immediately
// exports.triggerPriceCheck = functions.https.onRequest(async (req, res) => {
//   try {
//     console.log('Manual trigger of price check...');
    
//     // Get all active alerts
//     const alertsSnapshot = await admin.database().ref('priceAlerts').once('value');
//     const alerts = alertsSnapshot.val();

//     if (!alerts) {
//       res.json({ success: true, message: 'No alerts to check' });
//       return;
//     }

//     // Group by product ID
//     const productAlerts = {};
//     for (const alertId in alerts) {
//       const alert = alerts[alertId];
//       if (alert.isActive) {
//         if (!productAlerts[alert.productId]) {
//           productAlerts[alert.productId] = [];
//         }
//         productAlerts[alert.productId].push({ alertId, ...alert });
//       }
//     }

//     let checkedProducts = 0;
//     let triggeredAlerts = 0;

//     // Check each product
//     for (const productId in productAlerts) {
//       try {
//         const currentPrice = await getCurrentPriceFromAPI(productId);
//         checkedProducts++;
        
//         if (currentPrice !== null) {
//           for (const alert of productAlerts[productId]) {
//             if (currentPrice <= alert.priceThreshold) {
//               await sendPriceDropNotification(alert, currentPrice);
//               await admin.database().ref(`priceAlerts/${alert.alertId}/isActive`).set(false);
//               triggeredAlerts++;
//             }
//           }
//         }
//       } catch (error) {
//         console.error(`Error checking product ${productId}:`, error);
//       }
//     }

//     res.json({ 
//       success: true, 
//       checkedProducts,
//       triggeredAlerts,
//       message: `Checked ${checkedProducts} products, triggered ${triggeredAlerts} alerts`
//     });
//   } catch (error) {
//     console.error('Error in trigger price check:', error);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });

// // ===== UTILITY FUNCTIONS =====

// // Function to clean up old alerts (runs daily)
// exports.cleanupOldAlerts = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
//   try {
//     console.log('Starting cleanup of old alerts...');
    
//     const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000); // 30 days ago
    
//     const alertsSnapshot = await admin.database().ref('priceAlerts').once('value');
//     const alerts = alertsSnapshot.val();
    
//     let deletedCount = 0;
    
//     if (alerts) {
//       for (const alertId in alerts) {
//         const alert = alerts[alertId];
        
//         // Delete alerts older than 30 days or inactive alerts older than 7 days
//         const alertAge = Date.now() - alert.timestamp;
//         const isOldAlert = alertAge > thirtyDaysAgo;
//         const isOldInactive = !alert.isActive && alertAge > (7 * 24 * 60 * 60 * 1000);
        
//         if (isOldAlert || isOldInactive) {
//           await admin.database().ref(`priceAlerts/${alertId}`).remove();
//           deletedCount++;
//         }
//       }
//     }
    
//     console.log(`Cleanup completed. Deleted ${deletedCount} old alerts.`);
//     return null;
//   } catch (error) {
//     console.error('Error in cleanup:', error);
//     return null;
//   }
// }); 
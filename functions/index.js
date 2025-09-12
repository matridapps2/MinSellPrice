const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

// Initialize Firebase Admin SDK
admin.initializeApp();

// ===== EXISTING HTTP FUNCTIONS =====
// (Your current functions remain the same)

// Cloud Function to send push notifications
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  try {
    const { 
      token, 
      title, 
      body, 
      data: notificationData, 
      type = 'general',
      productId,
      productName,
      oldPrice,
      newPrice,
      productImage,
      savings,
      savingsPercentage
    } = data;

    // Validate required fields
    if (!token || !title || !body) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    // Create notification payload based on type
    let payload = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: type,
        productId: productId?.toString() || '',
        productName: productName || '',
        oldPrice: oldPrice || '',
        newPrice: newPrice || '',
        productImage: productImage || '',
        savings: savings || '',
        savingsPercentage: savingsPercentage || '',
        timestamp: new Date().toISOString(),
        ...notificationData
      },
      token: token
    };

    // Add platform-specific configurations
    if (type === 'price_drop') {
      payload.notification = {
        ...payload.notification,
        imageUrl: productImage || '',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      };
      
      // Android-specific configuration
      payload.android = {
        notification: {
          icon: 'ic_launcher',
          color: '#d90310',
          sound: 'default',
          priority: 'high',
          visibility: 'public',
          notificationPriority: 'PRIORITY_HIGH',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        },
        priority: 'high'
      };

      // iOS-specific configuration
      payload.apns = {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
              subtitle: `Save $${savings || '0.00'} on ${productName || 'this product'}`
            },
            sound: 'default',
            badge: 1,
            category: 'PRICE_DROP',
            threadId: 'price_alerts',
            interruptionLevel: 'active'
          }
        }
      };
    } else if (type === 'welcome_alert') {
      payload.notification = {
        ...payload.notification,
        imageUrl: productImage || '',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      };
      
      // Android-specific configuration for welcome
      payload.android = {
        notification: {
          icon: 'ic_launcher',
          color: '#4CAF50',
          sound: 'default',
          priority: 'high',
          visibility: 'public',
          notificationPriority: 'PRIORITY_HIGH',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        },
        priority: 'high'
      };

      // iOS-specific configuration for welcome
      payload.apns = {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
              subtitle: `You'll be notified when prices drop for ${productName || 'this product'}`
            },
            sound: 'default',
            badge: 1,
            category: 'WELCOME_ALERT',
            threadId: 'welcome_alerts',
            interruptionLevel: 'active'
          }
        }
      };
    }

    // Send the notification
    const response = await admin.messaging().send(payload);
    
    console.log('Successfully sent message:', response);
    
    return {
      success: true,
      messageId: response,
      message: 'Notification sent successfully'
    };

  } catch (error) {
    console.error('Error sending notification:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send notification', error.message);
  }
});

// Cloud Function to send notifications to multiple tokens
exports.sendBulkPushNotification = functions.https.onCall(async (data, context) => {
  try {
    const { 
      tokens, 
      title, 
      body, 
      data: notificationData, 
      type = 'general',
      productId,
      productName,
      oldPrice,
      newPrice,
      productImage,
      savings,
      savingsPercentage
    } = data;

    // Validate required fields
    if (!tokens || !Array.isArray(tokens) || tokens.length === 0 || !title || !body) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    // Create notification payload based on type
    let payload = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: type,
        productId: productId?.toString() || '',
        productName: productName || '',
        oldPrice: oldPrice || '',
        newPrice: newPrice || '',
        productImage: productImage || '',
        savings: savings || '',
        savingsPercentage: savingsPercentage || '',
        timestamp: new Date().toISOString(),
        ...notificationData
      },
      tokens: tokens
    };

    // Add platform-specific configurations (same as single notification)
    if (type === 'price_drop') {
      payload.notification = {
        ...payload.notification,
        imageUrl: productImage || '',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      };
      
      payload.android = {
        notification: {
          icon: 'ic_launcher',
          color: '#d90310',
          sound: 'default',
          priority: 'high',
          visibility: 'public',
          notificationPriority: 'PRIORITY_HIGH',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        },
        priority: 'high'
      };

      payload.apns = {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
              subtitle: `Save $${savings || '0.00'} on ${productName || 'this product'}`
            },
            sound: 'default',
            badge: 1,
            category: 'PRICE_DROP',
            threadId: 'price_alerts',
            interruptionLevel: 'active'
          }
        }
      };
    } else if (type === 'welcome_alert') {
      payload.notification = {
        ...payload.notification,
        imageUrl: productImage || '',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      };
      
      payload.android = {
        notification: {
          icon: 'ic_launcher',
          color: '#4CAF50',
          sound: 'default',
          priority: 'high',
          visibility: 'public',
          notificationPriority: 'PRIORITY_HIGH',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        },
        priority: 'high'
      };

      payload.apns = {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
              subtitle: `You'll be notified when prices drop for ${productName || 'this product'}`
            },
            sound: 'default',
            badge: 1,
            category: 'WELCOME_ALERT',
            threadId: 'welcome_alerts',
            interruptionLevel: 'active'
          }
        }
      };
    }

    // Send the notification to multiple tokens
    const response = await admin.messaging().sendMulticast(payload);
    
    console.log('Successfully sent bulk message:', response);
    
    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
      message: `Bulk notification sent: ${response.successCount} successful, ${response.failureCount} failed`
    };

  } catch (error) {
    console.error('Error sending bulk notification:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send bulk notification', error.message);
  }
});

// Cloud Function to send topic-based notifications
exports.sendTopicNotification = functions.https.onCall(async (data, context) => {
  try {
    const { 
      topic, 
      title, 
      body, 
      data: notificationData, 
      type = 'general',
      productId,
      productName,
      oldPrice,
      newPrice,
      productImage,
      savings,
      savingsPercentage
    } = data;

    // Validate required fields
    if (!topic || !title || !body) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    // Create notification payload based on type
    let payload = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: type,
        productId: productId?.toString() || '',
        productName: productName || '',
        oldPrice: oldPrice || '',
        newPrice: newPrice || '',
        productImage: productImage || '',
        savings: savings || '',
        savingsPercentage: savingsPercentage || '',
        timestamp: new Date().toISOString(),
        ...notificationData
      },
      topic: topic
    };

    // Add platform-specific configurations (same as single notification)
    if (type === 'price_drop') {
      payload.notification = {
        ...payload.notification,
        imageUrl: productImage || '',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      };
      
      payload.android = {
        notification: {
          icon: 'ic_launcher',
          color: '#d90310',
          sound: 'default',
          priority: 'high',
          visibility: 'public',
          notificationPriority: 'PRIORITY_HIGH',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        },
        priority: 'high'
      };

      payload.apns = {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
              subtitle: `Save $${savings || '0.00'} on ${productName || 'this product'}`
            },
            sound: 'default',
            badge: 1,
            category: 'PRICE_DROP',
            threadId: 'price_alerts',
            interruptionLevel: 'active'
          }
        }
      };
    } else if (type === 'welcome_alert') {
      payload.notification = {
        ...payload.notification,
        imageUrl: productImage || '',
        sound: 'default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK'
      };
      
      payload.android = {
        notification: {
          icon: 'ic_launcher',
          color: '#4CAF50',
          sound: 'default',
          priority: 'high',
          visibility: 'public',
          notificationPriority: 'PRIORITY_HIGH',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        },
        priority: 'high'
      };

      payload.apns = {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
              subtitle: `You'll be notified when prices drop for ${productName || 'this product'}`
            },
            sound: 'default',
            badge: 1,
            category: 'WELCOME_ALERT',
            threadId: 'welcome_alerts',
            interruptionLevel: 'active'
          }
        }
      };
    }

    // Send the notification to topic
    const response = await admin.messaging().send(payload);
    
    console.log('Successfully sent topic message:', response);
    
    return {
      success: true,
      messageId: response,
      message: 'Topic notification sent successfully'
    };

  } catch (error) {
    console.error('Error sending topic notification:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send topic notification', error.message);
  }
});

// Cloud Function to subscribe user to topic
exports.subscribeToTopic = functions.https.onCall(async (data, context) => {
  try {
    const { token, topic } = data;

    if (!token || !topic) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    const response = await admin.messaging().subscribeToTopic([token], topic);
    
    console.log('Successfully subscribed to topic:', response);
    
    return {
      success: true,
      message: `Successfully subscribed to topic: ${topic}`
    };

  } catch (error) {
    console.error('Error subscribing to topic:', error);
    throw new functions.https.HttpsError('internal', 'Failed to subscribe to topic', error.message);
  }
});

// Cloud Function to unsubscribe user from topic
exports.unsubscribeFromTopic = functions.https.onCall(async (data, context) => {
  try {
    const { token, topic } = data;

    if (!token || !topic) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    const response = await admin.messaging().unsubscribeFromTopic([token], topic);
    
    console.log('Successfully unsubscribed from topic:', response);
    
    return {
      success: true,
      message: `Successfully unsubscribed from topic: ${topic}`
    };

  } catch (error) {
    console.error('Error unsubscribing from topic:', error);
    throw new functions.https.HttpsError('internal', 'Failed to unsubscribe from topic', error.message);
  }
});

// ===== NEW CRON JOB - EVERY 5 MINUTES =====

// Cron job that runs every 5 minutes to check for price drops
exports.checkPriceDropsEvery5Minutes = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
  console.log(' Running price drop check every 5 minutes...');
  console.log('⏰ Execution time:', new Date().toISOString());
  
  try {
    // Call the fetchPriceAlertProduct API to get notifications
    const response = await fetchPriceAlertProductFromAPI();
    
    if (!response || response === 'error' || response.length === 0) {
      console.log('📭 No price alert data found from API');
      return null;
    }
    
    console.log(`📊 API response length: ${response.length}`);
    
    let totalNotificationsSent = 0;
    let totalPriceDropsDetected = 0;
    
    // Process the API response data
    const result = await processApiDataForNotifications(response);
    totalNotificationsSent = result.notificationsSent;
    totalPriceDropsDetected = result.priceDropsDetected;
    
    console.log(`✅ Price drop check completed:`);
    console.log(`   📊 Total price drops detected: ${totalPriceDropsDetected}`);
    console.log(`   📱 Total notifications sent: ${totalNotificationsSent}`);
    
    return {
      success: true,
      totalPriceDropsDetected,
      totalNotificationsSent,
      executionTime: new Date().toISOString()
    };
    
  } catch (error) {
    console.error('❌ Error in price drop check:', error);
    throw error;
  }
});

// ===== HELPER FUNCTIONS =====

// Fetch price alert product data from API (based on app_notification_service.dart)
async function fetchPriceAlertProductFromAPI() {
  try {
    console.log('🔍 Fetching price alert product data from API...');
    
    // Call your API endpoint
    const response = await axios.post('https://growth.matridtech.net/api/fetchPriceAlertProduct', {
      // You can add any required parameters here
    }, {
      timeout: 30000, // 30 second timeout
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Firebase-Cloud-Function/1.0'
      }
    });
    
    if (response.data && response.data !== 'error' && response.data.length > 0) {
      console.log('✅ API call successful!');
      console.log(`📏 Response data length: ${response.data.length}`);
      return response.data;
    }
    
    console.log('❌ API call failed or returned error');
    return null;
    
  } catch (error) {
    console.error('❌ Error fetching price alert product data:', error.message);
    return null;
  }
}

// Process API response data for notifications (based on app_notification_service.dart)
async function processApiDataForNotifications(data) {
  console.log('🔧 Processing API data for notifications...');
  
  let notificationsSent = 0;
  let priceDropsDetected = 0;
  
  try {
    if (Array.isArray(data)) {
      console.log(`🔍 Processing List response with ${data.length} items`);
      for (let i = 0; i < data.length; i++) {
        const item = data[i];
        if (item && typeof item === 'object') {
          const result = await processNotificationItem(item);
          notificationsSent += result.notificationsSent;
          priceDropsDetected += result.priceDropsDetected;
        }
      }
    } else if (data && typeof data === 'object') {
      console.log(`🔍 Processing single object response: ${Object.keys(data)}`);
      const result = await processNotificationItem(data);
      notificationsSent += result.notificationsSent;
      priceDropsDetected += result.priceDropsDetected;
    } else {
      console.log(`⚠️ Response is neither Array nor Object, cannot process: ${typeof data}`);
    }
    
    console.log('✅ Data processing completed');
    return { notificationsSent, priceDropsDetected };
    
  } catch (error) {
    console.error('❌ Error processing API data:', error);
    return { notificationsSent: 0, priceDropsDetected: 0 };
  }
}

// Process individual notification item (based on app_notification_service.dart)
async function processNotificationItem(item) {
  console.log(`🔍 Processing notification item: ${Object.keys(item)}`);
  
  let notificationsSent = 0;
  let priceDropsDetected = 0;
  
  try {
    if (item.device_token !== undefined && item.product_id !== undefined) {
      const responseDeviceToken = item.device_token;
      const responseEmail = item.email;
      const isNotificationSent = parseInt(item.isNotificationSent?.toString() || '0') || 0;
      
      console.log('🔍 Processing notification data:');
      console.log(`   Response device token: ${responseDeviceToken}`);
      console.log(`   Response email: ${responseEmail}`);
      console.log(`   Notification already sent: ${isNotificationSent === 1 ? "YES" : "NO"}`);
      
      // Skip notifications that have already been sent
      if (isNotificationSent === 1) {
        console.log('⏭️ Skipping notification - already sent (isNotificationSent = 1)');
        return { notificationsSent: 0, priceDropsDetected: 0 };
      }
      
      // Validate the notification data
      if (validateNotificationData(item)) {
        console.log('�� NOTIFICATION APPROVED! Auto-triggering for product:', item.product_name);
        
        // Send the notification
        const notificationSent = await sendPriceDropNotification({
          productId: item.product_id,
          productName: item.product_name,
          oldPrice: parseFloat(item.OldPrice || '0'),
          newPrice: parseFloat(item.NewPrice || '0'),
          productImage: item.product_image || '',
          deviceToken: responseDeviceToken,
          email: responseEmail
        });
        
        if (notificationSent) {
          notificationsSent++;
          priceDropsDetected++;
          
          // Mark notification as sent via API
          await markNotificationAsSent(item, responseEmail, responseDeviceToken);
        }
      } else {
        console.log('❌ Data validation failed - skipping notification');
      }
    }
    
    return { notificationsSent, priceDropsDetected };
    
  } catch (error) {
    console.error('❌ Error processing notification item:', error);
    return { notificationsSent: 0, priceDropsDetected: 0 };
  }
}

// Validate notification data (based on app_notification_service.dart validation logic)
function validateNotificationData(data) {
  try {
    const requiredFields = [
      'product_name',
      'OldPrice',
      'NewPrice',
      'product_id',
      'product_image'
    ];
    
    // Check required fields
    for (const field of requiredFields) {
      const value = data[field];
      if (value === null || value === undefined || value.toString().trim() === '' || value.toString() === '---') {
        console.log(`❌ Validation failed: ${field} is empty or null (${value})`);
        return false;
      }
    }
    
    const oldPrice = parseFloat(data.OldPrice?.toString() || '');
    const newPrice = parseFloat(data.NewPrice?.toString() || '');
    
    if (isNaN(oldPrice) || isNaN(newPrice)) {
      console.log('❌ Validation failed: Invalid price format');
      console.log(`   Old Price: ${data.OldPrice}`);
      console.log(`   New Price: ${data.NewPrice}`);
      return false;
    }
    
    // Check if prices are actually different
    if (oldPrice === newPrice) {
      console.log('❌ Validation failed: Prices are the same - no price drop');
      console.log(`   Old Price: $${oldPrice.toFixed(2)}`);
      console.log(`   New Price: $${newPrice.toFixed(2)}`);
      console.log('   💡 Notification skipped - no actual price change detected');
      return false;
    }
    
    // Check if it's actually a price drop (new price < old price)
    if (newPrice > oldPrice) {
      console.log('❌ Validation failed: New price is higher than old price - not a drop');
      console.log(`   Old Price: $${oldPrice.toFixed(2)}`);
      console.log(`   New Price: $${newPrice.toFixed(2)}`);
      console.log(`   Price Difference: $${(newPrice - oldPrice).toFixed(2)} (price increased)`);
      console.log('   💡 Notification skipped - price increased, not decreased');
      return false;
    }
    
    const productId = parseInt(data.product_id?.toString() || '0') || 0;
    if (productId <= 0) {
      console.log(`❌ Validation failed: Invalid product ID: ${data.product_id}`);
      return false;
    }
    
    const imageUrl = data.product_image?.toString() || '';
    if (imageUrl.trim() === '' || !imageUrl.startsWith('http')) {
      console.log(`❌ Validation failed: Invalid image URL: ${imageUrl}`);
      return false;
    }
    
    // Check if notification has already been sent
    const isNotificationSent = parseInt(data.isNotificationSent?.toString() || '0') || 0;
    if (isNotificationSent === 1) {
      console.log('❌ Validation failed: Notification already sent (isNotificationSent = 1)');
      return false;
    }
    
    // Calculate savings
    const priceDifference = oldPrice - newPrice;
    const savingsPercentage = ((priceDifference / oldPrice) * 100);
    
    console.log('✅ Price drop detected!');
    console.log(`   Old Price: $${oldPrice.toFixed(2)}`);
    console.log(`   New Price: $${newPrice.toFixed(2)}`);
    console.log(`   💰 Savings: $${priceDifference.toFixed(2)}`);
    console.log(`   �� Savings Percentage: ${savingsPercentage.toFixed(1)}%`);
    
    // Check for minimum price difference (prevents $0.00 savings notifications)
    const minimumPriceDifference = 0.01; // $0.01 minimum difference
    if (priceDifference < minimumPriceDifference) {
      console.log('❌ Validation failed: Price difference too small');
      console.log(`   Price Difference: $${priceDifference.toFixed(2)}`);
      console.log(`   Minimum Required: $${minimumPriceDifference.toFixed(2)}`);
      console.log('   💡 Notification skipped - price change too small to notify');
      return false;
    }
    
    // Check for zero or negative prices
    if (oldPrice <= 0 || newPrice <= 0) {
      console.log('❌ Validation failed: Invalid price values (zero or negative)');
      console.log(`   Old Price: $${oldPrice.toFixed(2)}`);
      console.log(`   New Price: $${newPrice.toFixed(2)}`);
      console.log('   💡 Notification skipped - invalid price values');
      return false;
    }
    
    console.log('✅ All data validation checks passed');
    console.log(`📊 Notification status: isNotificationSent = ${isNotificationSent} (0 = not sent, 1 = sent)`);
    return true;
    
  } catch (error) {
    console.error('❌ Error during data validation:', error);
    return false;
  }
}

// Send price drop notification (based on app_notification_service.dart)
async function sendPriceDropNotification(notificationData) {
  try {
    const { productId, productName, oldPrice, newPrice, productImage, deviceToken, email } = notificationData;
    
    if (!deviceToken) {
      console.log(`❌ No device token available for product ${productId}`);
      return false;
    }
    
    const savings = oldPrice - newPrice;
    const savingsPercentage = ((savings / oldPrice) * 100).toFixed(1);
    
    const payload = {
      notification: {
        title: 'Price Drop Alert! 🎉',
        body: `${productName} dropped from $${oldPrice.toFixed(2)} to $${newPrice.toFixed(2)} (Save $${savings.toFixed(2)})`,
        imageUrl: productImage || ''
      },
      data: {
        type: 'price_drop',
        productId: productId.toString(),
        productName: productName,
        oldPrice: oldPrice.toString(),
        newPrice: newPrice.toString(),
        savings: savings.toFixed(2),
        savingsPercentage: savingsPercentage,
        timestamp: new Date().toISOString()
      },
      token: deviceToken,
      android: {
        notification: {
          icon: 'ic_launcher',
          color: '#d90310',
          sound: 'default',
          priority: 'high',
          visibility: 'public',
          notificationPriority: 'PRIORITY_HIGH',
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true
        },
        priority: 'high'
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: 'Price Drop Alert! 🎉',
              body: `${productName} dropped from $${oldPrice.toFixed(2)} to $${newPrice.toFixed(2)}`,
              subtitle: `Save $${savings.toFixed(2)} on ${productName}`
            },
            sound: 'default',
            badge: 1,
            category: 'PRICE_DROP',
            threadId: 'price_alerts',
            interruptionLevel: 'active'
          }
        }
      }
    };
    
    const response = await admin.messaging().send(payload);
    console.log(`✅ Price drop notification sent for product ${productId}: ${response}`);
    
    return true;
    
  } catch (error) {
    console.error(`❌ Error sending price drop notification for product ${productId}:`, error);
    return false;
  }
}

// Mark notification as sent in your API (based on app_notification_service.dart)
async function markNotificationAsSent(notificationData, email, deviceToken) {
  try {
    const productId = parseInt(notificationData.product_id?.toString() || '0') || 0;
    
    if (productId <= 0) {
      console.log(`⚠️ Cannot update notification status - missing product ID: ${productId}`);
      return;
    }
    
    console.log(`🔄 Updating notification sent status for product: ${productId}`);
    console.log(`📧 User email: ${email}`);
    console.log(`📱 Device token: ${deviceToken}`);
    
    // LOGIN CASE: Pass only email, device token should be empty
    // LOGGED OUT CASE: Pass only device token, email should be empty
    let finalEmailId = '';
    let finalDeviceId = '';
    
    if (email && email.trim() !== '') {
      // LOGIN CASE: Only pass email
      finalEmailId = email;
      finalDeviceId = ''; // Empty device token for login case
      console.log('🔐 LOGIN CASE: Passing only email, device token will be empty');
    } else {
      // LOGGED OUT CASE: Only pass device token
      finalEmailId = ''; // Empty email for logged out case
      finalDeviceId = deviceToken || '';
      console.log('🔓 LOGGED OUT CASE: Passing only device token, email will be empty');
    }
    
    // Call your API to mark notification as sent
    const response = await axios.post('https://growth.matridtech.net/api/notification-sent', {
      productId: productId,
      emailId: finalEmailId,
      deviceID: finalDeviceId,
      isNotificationSent: 1
    }, {
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    if (response.status === 200) {
      console.log(`✅ Marked notification as sent for product ${productId}`);
      console.log(`📤 API called with - Email: "${finalEmailId}", Device Token: "${finalDeviceId}"`);
    } else {
      console.log(`⚠️ Failed to mark notification as sent for product ${productId}`);
    }
    
  } catch (error) {
    console.error(`❌ Error marking notification as sent for product ${notificationData.product_id}:`, error);
  }
}
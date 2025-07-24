# API Configuration Examples for Automatic Price Monitoring

## **🔧 How to Configure Your API**

Replace the `getCurrentPriceFromAPI` function in your Firebase Functions with one of these examples based on your API structure.

## **Example 1: Simple REST API**

```javascript
async function getCurrentPriceFromAPI(productId) {
  try {
    const response = await axios.get(`https://your-api.com/products/${productId}`);
    
    // If your API returns: { "price": 4798.00 }
    if (response.data && response.data.price) {
      return parseFloat(response.data.price);
    }
    
    return null;
  } catch (error) {
    console.error(`API error for product ${productId}:`, error.message);
    return null;
  }
}
```

## **Example 2: Nested Price Structure**

```javascript
async function getCurrentPriceFromAPI(productId) {
  try {
    const response = await axios.get(`https://your-api.com/products/${productId}`);
    
    // If your API returns: { "product": { "price": 4798.00 } }
    if (response.data && response.data.product && response.data.product.price) {
      return parseFloat(response.data.product.price);
    }
    
    // Or if it returns: { "data": { "currentPrice": 4798.00 } }
    if (response.data && response.data.data && response.data.data.currentPrice) {
      return parseFloat(response.data.data.currentPrice);
    }
    
    return null;
  } catch (error) {
    console.error(`API error for product ${productId}:`, error.message);
    return null;
  }
}
```

## **Example 3: Multiple Price Options**

```javascript
async function getCurrentPriceFromAPI(productId) {
  try {
    const response = await axios.get(`https://your-api.com/products/${productId}`);
    
    // If your API returns: { "prices": { "current": 4798.00, "original": 5200.00 } }
    if (response.data && response.data.prices && response.data.prices.current) {
      return parseFloat(response.data.prices.current);
    }
    
    // Or if it returns: { "priceData": { "sale": 4798.00, "regular": 5200.00 } }
    if (response.data && response.data.priceData && response.data.priceData.sale) {
      return parseFloat(response.data.priceData.sale);
    }
    
    return null;
  } catch (error) {
    console.error(`API error for product ${productId}:`, error.message);
    return null;
  }
}
```

## **Example 4: API with Authentication**

```javascript
async function getCurrentPriceFromAPI(productId) {
  try {
    const response = await axios.get(`https://your-api.com/products/${productId}`, {
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'X-API-Key': 'YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
      timeout: 10000, // 10 second timeout
    });
    
    if (response.data && response.data.price) {
      return parseFloat(response.data.price);
    }
    
    return null;
  } catch (error) {
    console.error(`API error for product ${productId}:`, error.message);
    return null;
  }
}
```

## **Example 5: POST Request with Body**

```javascript
async function getCurrentPriceFromAPI(productId) {
  try {
    const response = await axios.post(`https://your-api.com/products/price`, {
      productId: productId,
      includeTax: false,
      currency: 'USD',
    }, {
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
    });
    
    if (response.data && response.data.price) {
      return parseFloat(response.data.price);
    }
    
    return null;
  } catch (error) {
    console.error(`API error for product ${productId}:`, error.message);
    return null;
  }
}
```

## **Example 6: Multiple API Endpoints (Fallback)**

```javascript
async function getCurrentPriceFromAPI(productId) {
  // Try primary API first
  try {
    const response = await axios.get(`https://primary-api.com/products/${productId}`);
    if (response.data && response.data.price) {
      return parseFloat(response.data.price);
    }
  } catch (error) {
    console.log(`Primary API failed for product ${productId}, trying secondary API...`);
  }
  
  // Fallback to secondary API
  try {
    const response = await axios.get(`https://secondary-api.com/products/${productId}`);
    if (response.data && response.data.price) {
      return parseFloat(response.data.price);
    }
  } catch (error) {
    console.error(`Secondary API also failed for product ${productId}:`, error.message);
  }
  
  return null;
}
```

## **Example 7: GraphQL API**

```javascript
async function getCurrentPriceFromAPI(productId) {
  try {
    const query = `
      query GetProductPrice($productId: ID!) {
        product(id: $productId) {
          id
          name
          price
          currentPrice
        }
      }
    `;
    
    const response = await axios.post('https://your-graphql-api.com/graphql', {
      query: query,
      variables: { productId: productId },
    }, {
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
    });
    
    if (response.data && response.data.data && response.data.data.product) {
      const product = response.data.data.product;
      return parseFloat(product.currentPrice || product.price);
    }
    
    return null;
  } catch (error) {
    console.error(`GraphQL API error for product ${productId}:`, error.message);
    return null;
  }
}
```

## **Example 8: Web Scraping (if no API available)**

```javascript
const cheerio = require('cheerio');

async function getCurrentPriceFromAPI(productId) {
  try {
    const response = await axios.get(`https://your-website.com/product/${productId}`, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
    });
    
    const $ = cheerio.load(response.data);
    
    // Extract price from HTML (adjust selectors based on your website)
    const priceText = $('.product-price').text().trim();
    const price = parseFloat(priceText.replace(/[^0-9.]/g, ''));
    
    if (price && !isNaN(price)) {
      return price;
    }
    
    return null;
  } catch (error) {
    console.error(`Web scraping error for product ${productId}:`, error.message);
    return null;
  }
}
```

## **🔍 How to Find Your API Structure**

### **1. Check Your API Documentation**
Look for endpoints like:
- `GET /products/{id}`
- `GET /api/products/{id}`
- `POST /products/price`

### **2. Test Your API**
```bash
# Test with curl
curl -X GET "https://your-api.com/products/123"

# Or with Postman/Insomnia
GET https://your-api.com/products/123
```

### **3. Check Response Format**
Your API might return:
```json
{
  "price": 4798.00
}
```
or
```json
{
  "product": {
    "id": "123",
    "name": "Evo Professional Tabletop Grill",
    "price": 4798.00
  }
}
```
or
```json
{
  "data": {
    "currentPrice": 4798.00,
    "originalPrice": 5200.00
  }
}
```

## **⚙️ Environment Variables**

Store your API keys securely:

```javascript
// In Firebase Functions, use environment variables
const API_KEY = process.env.YOUR_API_KEY;
const API_BASE_URL = process.env.API_BASE_URL;

async function getCurrentPriceFromAPI(productId) {
  try {
    const response = await axios.get(`${API_BASE_URL}/products/${productId}`, {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
      },
    });
    
    return parseFloat(response.data.price);
  } catch (error) {
    console.error(`API error:`, error.message);
    return null;
  }
}
```

Set environment variables:
```bash
firebase functions:config:set api.key="YOUR_API_KEY" api.base_url="https://your-api.com"
```

## **🚀 Testing Your API Configuration**

1. **Deploy your functions:**
   ```bash
   firebase deploy --only functions
   ```

2. **Test manually:**
   ```bash
   curl -X POST https://your-project.cloudfunctions.net/checkProductPrice \
     -H "Content-Type: application/json" \
     -d '{"productId": "your-test-product-id"}'
   ```

3. **Check logs:**
   ```bash
   firebase functions:log
   ```

Choose the example that matches your API structure and update the Firebase Functions accordingly! 
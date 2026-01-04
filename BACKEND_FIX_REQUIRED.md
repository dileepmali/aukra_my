# 🔧 BACKEND FIX REQUIRED - Merchant API

## Problem
Backend is returning **500 Internal Server Error** when:
- `mobileNumber == masterMobileNumber` (same number)
- `otp` field is `null` or not present

## Current Behavior (WRONG ❌)
```json
// Request Payload
{
  "merchantName": "John Doe",
  "businessName": "ABC Store",
  "mobileNumber": "9016688526",
  "masterMobileNumber": "9016688526",  // ❌ SAME number
  "address": "123 Main St",
  "country": "INDIA"
  // ❌ NO "otp" field
}

// Backend Response
{
  "statusCode": 500,
  "message": "Request failed. Please try again or contact admin."
}
```

## Expected Behavior (CORRECT ✅)

### Case 1: Same Numbers (NO OTP)
```json
// Request Payload
{
  "merchantName": "John Doe",
  "businessName": "ABC Store",
  "mobileNumber": "9016688526",
  "masterMobileNumber": "9016688526",  // ✅ SAME number
  "address": "123 Main St",
  "country": "INDIA"
  // ✅ NO "otp" field (not required)
}

// Backend Response (SUCCESS)
{
  "message": "Merchant added successfully",
  "merchantId": 32
}
```

### Case 2: Different Numbers (WITH OTP)
```json
// Request Payload
{
  "merchantName": "John Doe",
  "businessName": "ABC Store",
  "mobileNumber": "9016688526",
  "masterMobileNumber": "9227980883",  // ✅ DIFFERENT number
  "address": "123 Main St",
  "country": "INDIA",
  "otp": "1234"  // ✅ OTP included and verified
}

// Backend Response (SUCCESS)
{
  "message": "Merchant added successfully",
  "merchantId": 32
}
```

## Required Backend Changes

### Pseudo-code Logic
```javascript
// POST /api/merchant endpoint

async function createMerchant(req, res) {
  try {
    const {
      merchantName,
      businessName,
      mobileNumber,
      masterMobileNumber,
      address,
      country,
      otp
    } = req.body;

    // ✅ Validate required fields
    if (!merchantName || !businessName || !mobileNumber || !masterMobileNumber || !address) {
      return res.status(400).json({
        message: "Missing required fields"
      });
    }

    // ✅ CRITICAL FIX: Check if numbers are same or different
    const isSameNumber = (mobileNumber === masterMobileNumber);

    if (isSameNumber) {
      // ✅ Same number - NO OTP verification needed
      console.log('✅ Same number detected - Skipping OTP verification');

      // Proceed with merchant creation
      const merchant = await createMerchantInDatabase({
        merchantName,
        businessName,
        mobileNumber,
        masterMobileNumber,
        address,
        country
      });

      return res.status(200).json({
        message: "Merchant added successfully",
        merchantId: merchant.id
      });

    } else {
      // ✅ Different numbers - OTP verification REQUIRED
      console.log('🔐 Different numbers detected - OTP verification required');

      // Validate OTP is provided
      if (!otp || otp.trim() === '') {
        return res.status(400).json({
          message: "OTP is required for different master mobile number"
        });
      }

      // ✅ Verify OTP for masterMobileNumber
      const isOtpValid = await verifyOTP(masterMobileNumber, otp);

      if (!isOtpValid) {
        return res.status(400).json({
          message: "Invalid OTP for master mobile number"
        });
      }

      console.log('✅ OTP verified successfully');

      // Proceed with merchant creation
      const merchant = await createMerchantInDatabase({
        merchantName,
        businessName,
        mobileNumber,
        masterMobileNumber,
        address,
        country
      });

      return res.status(200).json({
        message: "Merchant added successfully",
        merchantId: merchant.id
      });
    }

  } catch (error) {
    console.error('❌ Error creating merchant:', error);
    return res.status(500).json({
      message: "Request failed. Please try again or contact admin.",
      error: error.message  // ✅ Include error message for debugging
    });
  }
}
```

## Testing Checklist

### Test Case 1: Same Number (No OTP)
```bash
POST /api/merchant
{
  "merchantName": "Test User",
  "businessName": "Test Shop",
  "mobileNumber": "9016688526",
  "masterMobileNumber": "9016688526",
  "address": "Test Address 123",
  "country": "INDIA"
}

Expected: ✅ 200 OK - Merchant created successfully
```

### Test Case 2: Different Number (With Valid OTP)
```bash
POST /api/merchant
{
  "merchantName": "Test User",
  "businessName": "Test Shop",
  "mobileNumber": "9016688526",
  "masterMobileNumber": "9227980883",
  "address": "Test Address 123",
  "country": "INDIA",
  "otp": "1234"
}

Expected: ✅ 200 OK - Merchant created successfully
```

### Test Case 3: Different Number (No OTP - Should Fail)
```bash
POST /api/merchant
{
  "merchantName": "Test User",
  "businessName": "Test Shop",
  "mobileNumber": "9016688526",
  "masterMobileNumber": "9227980883",
  "address": "Test Address 123",
  "country": "INDIA"
}

Expected: ❌ 400 Bad Request - "OTP is required for different master mobile number"
```

### Test Case 4: Different Number (Invalid OTP - Should Fail)
```bash
POST /api/merchant
{
  "merchantName": "Test User",
  "businessName": "Test Shop",
  "mobileNumber": "9016688526",
  "masterMobileNumber": "9227980883",
  "address": "Test Address 123",
  "country": "INDIA",
  "otp": "9999"
}

Expected: ❌ 400 Bad Request - "Invalid OTP for master mobile number"
```

## Summary

**Frontend Changes (✅ DONE):**
- Properly validates phone numbers
- Only sends OTP when numbers are different
- Doesn't send OTP field when numbers are same

**Backend Changes (⚠️ REQUIRED):**
- Handle same numbers WITHOUT OTP verification
- Handle different numbers WITH OTP verification
- Return proper error messages (not generic 500)
- Add proper validation and error handling

**Priority:** HIGH - This is blocking merchant creation for users with same registered/owner numbers.

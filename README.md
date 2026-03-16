# Fence AI - Intelligent Land Research & Development Platform

![Fence AI](assets/images/fence.ai_app_icon.png)

Fence AI is a comprehensive land research and development platform that combines AI-powered analysis with interactive mapping to help users make informed decisions about land acquisition, development, and investment. The platform features a Flutter mobile application and a Next.js backend server with integrated payment processing via InterSwitch.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Mobile App Setup](#mobile-app-setup)
  - [Server Setup](#server-setup)
- [Payment Integration](#payment-integration)
- [Freemium Model](#freemium-model)
- [API Documentation](#api-documentation)
- [Environment Variables](#environment-variables)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

---

## ✨ Features

### Core Features
- 🗺️ **Interactive Map Discovery** - Browse locations on Google Maps and select land plots for AI analysis
- 🤖 **AI-Powered Land Analysis** - Get comprehensive development recommendations using OpenAI GPT-4
- 💬 **Conversational AI Chat** - Ask questions about land, real estate, agriculture, and property development
- 📊 **Research Conversations** - Organize your land research into structured conversations with history
- 📍 **Location Intelligence** - Enriched location data including nearby amenities, infrastructure, and demographics
- 🔒 **Secure Authentication** - User authentication powered by Supabase

### Premium Features
- 💳 **Freemium Model** - Free tier with 3 research prompts and 1 chat message
- 💰 **InterSwitch Payment Integration** - Seamless payment processing for premium subscriptions
- 🚀 **Unlimited Access** - Premium users get unlimited research and chat capabilities
- 📈 **Advanced Analytics** - Detailed insights and export capabilities (Premium)
- 🎯 **Priority Support** - Dedicated support for premium users

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Fence AI Platform                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │  Flutter Mobile  │◄────────┤   Next.js Server │          │
│  │      App         │  REST   │    (Backend)     │          │
│  └────────┬─────────┘         └────────┬─────────┘          │
│           │                            │                     │
│           │                            │                     │
│  ┌────────▼─────────┐         ┌───────▼──────────┐          │
│  │   Supabase       │         │  InterSwitch     │          │
│  │  (Auth + DB)     │         │  Payment Gateway │          │
│  └──────────────────┘         └──────────────────┘          │
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │  Google Maps API │         │   OpenAI API     │          │
│  │  (Location Data) │         │  (AI Analysis)   │          │
│  └──────────────────┘         └──────────────────┘          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User Authentication**: Supabase handles user registration and authentication
2. **Map Interaction**: Users select land plots on Google Maps
3. **Location Enrichment**: Google Maps API provides detailed location data
4. **AI Analysis**: OpenAI GPT-4 analyzes location data and generates recommendations
5. **Data Storage**: Conversations and messages stored in Supabase PostgreSQL
6. **Payment Processing**: InterSwitch handles premium subscription payments
7. **Usage Tracking**: Local storage tracks free tier usage limits

---

## 🛠️ Tech Stack

### Mobile App (Flutter)
- **Framework**: Flutter 3.8.1+
- **State Management**: Riverpod 2.6.1
- **Database**: Supabase Flutter 2.9.1
- **Maps**: Google Maps Flutter 2.9.0
- **Location**: Geolocator 13.0.2
- **HTTP**: http 1.4.0
- **UI**: Material Design 3, Google Fonts
- **Storage**: SharedPreferences 2.5.3
- **Markdown**: Flutter Markdown 0.7.4+1

### Backend Server (Next.js)
- **Framework**: Next.js 16.1.6 (App Router)
- **Runtime**: Node.js
- **Language**: TypeScript
- **Payment**: InterSwitch Web Checkout API

### External Services
- **AI**: OpenAI GPT-4 Turbo
- **Maps**: Google Maps Platform (Maps, Places, Geocoding APIs)
- **Authentication**: Supabase Auth
- **Database**: Supabase PostgreSQL
- **Payment Gateway**: InterSwitch Payment Gateway

---

## 📁 Project Structure

```
fence/
├── mobile/                          # Flutter mobile application
│   ├── lib/
│   │   ├── auth/                   # Authentication logic
│   │   │   └── providers/          # Auth state providers
│   │   ├── core/
│   │   │   ├── models/             # Data models
│   │   │   ├── providers/          # Riverpod providers
│   │   │   └── services/           # Business logic services
│   │   │       ├── chat_ai_service.dart
│   │   │       ├── fence_ai_service.dart
│   │   │       ├── map_service.dart
│   │   │       ├── usage_tracking_service.dart
│   │   │       └── research_messages_service.dart
│   │   ├── view/
│   │   │   ├── pages/              # App screens
│   │   │   │   ├── main/           # Main app pages
│   │   │   │   │   ├── home.dart
│   │   │   │   │   ├── map.dart
│   │   │   │   │   └── research_chat.dart
│   │   │   │   └── payment/        # Payment pages
│   │   │   │       └── upgrade_page.dart
│   │   │   └── widgets/            # Reusable widgets
│   │   │       ├── upgrade_prompt_sheet.dart
│   │   │       └── side_bar.dart
│   │   ├── constants/              # App constants
│   │   └── main.dart               # App entry point
│   ├── assets/                     # Images, icons, animations
│   ├── .env                        # Environment variables (gitignored)
│   ├── .env.example                # Environment template
│   ├── pubspec.yaml                # Flutter dependencies
│   └── QUICK_START_MAPS.md         # Google Maps setup guide
│
├── server/                          # Next.js backend server
│   ├── app/
│   │   ├── api/
│   │   │   └── payments/
│   │   │       └── interswitch/
│   │   │           ├── initialize/
│   │   │           │   └── route.ts    # Payment initialization endpoint
│   │   │           └── verify/
│   │   │               └── route.ts    # Payment verification endpoint
│   │   └── page.tsx                # Home page
│   ├── lib/
│   │   └── interswitch.ts          # InterSwitch helper functions
│   ├── .env                        # Server environment variables (gitignored)
│   ├── .env.example                # Server environment template
│   ├── package.json                # Node dependencies
│   ├── tsconfig.json               # TypeScript config
│   └── next.config.ts              # Next.js configuration
│
└── README.md                        # This file
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: 3.8.1 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Node.js**: 18.x or higher ([Install Node.js](https://nodejs.org/))
- **Dart**: Comes with Flutter
- **Android Studio** or **Xcode**: For mobile development
- **Git**: For version control

### Required API Keys & Services

You'll need accounts and API keys for:

1. **Supabase** ([supabase.com](https://supabase.com))
   - Create a project
   - Get your project URL and anon key

2. **OpenAI** ([platform.openai.com](https://platform.openai.com))
   - Create an API key
   - Ensure you have GPT-4 access

3. **Google Cloud Platform** ([console.cloud.google.com](https://console.cloud.google.com))
   - Enable Maps SDK for Android
   - Enable Maps SDK for iOS
   - Enable Places API
   - Enable Geocoding API
   - Create API keys with appropriate restrictions

4. **InterSwitch** ([sandbox.interswitchng.com](https://sandbox.interswitchng.com))
   - Sign up for a merchant account
   - Get test credentials for development
   - Get production credentials for live deployment

---

## 📱 Mobile App Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd fence/mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Create a `.env` file in the `mobile/` directory:

```bash
cp .env.example .env
```

Edit `.env` and add your API keys:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
OPENAI_API_KEY=sk-your_openai_api_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

### 4. Configure Google Maps

#### For Android

Edit `mobile/android/local.properties`:

```properties
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

The API key is automatically injected into `AndroidManifest.xml` during build.

#### For iOS

Edit `mobile/ios/Runner/Info.plist` and add your API key:

```xml
<key>GMSApiKey</key>
<string>your_google_maps_api_key_here</string>
```

Or set it as a build setting in Xcode:
- Open `ios/Runner.xcworkspace`
- Select Runner target
- Build Settings → Add User-Defined Setting
- Name: `GOOGLE_MAPS_API_KEY`
- Value: `your_google_maps_api_key_here`

### 5. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run

# For specific device
flutter devices
flutter run -d <device-id>
```

### 6. Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🖥️ Server Setup

### 1. Navigate to Server Directory

```bash
cd fence/server
```

### 2. Install Dependencies

```bash
npm install
# or
yarn install
```

### 3. Configure Environment Variables

Create a `.env` file in the `server/` directory:

```bash
cp .env.example .env
```

Edit `.env` and add your InterSwitch credentials:

```env
# InterSwitch General Integration Credentials
INTERSWITCH_MERCHANT_CODE=MX6072
INTERSWITCH_PAY_ITEM_ID=9405967
INTERSWITCH_REDIRECT_URL=https://your-domain.com/payment-response
INTERSWITCH_MODE=TEST

# Optional: Card Payment API Credentials (if using direct card API)
# INTERSWITCH_CARD_API_MERCHANT_CODE=MX21696
# INTERSWITCH_CARD_API_PAY_ITEM_ID=4177785
# INTERSWITCH_CARD_API_CLIENT_ID=your_client_id
# INTERSWITCH_CARD_API_SECRET=your_secret
```

**Important Notes:**
- Use `TEST` mode for development with test credentials
- Use `LIVE` mode for production with live credentials
- Update `INTERSWITCH_REDIRECT_URL` to your actual domain

### 4. Run Development Server

```bash
npm run dev
# or
yarn dev
```

The server will start on `http://localhost:3000`

### 5. Build for Production

```bash
npm run build
npm start
# or
yarn build
yarn start
```

---

## 💳 Payment Integration

Fence AI uses **InterSwitch Payment Gateway** for processing premium subscription payments. InterSwitch is a leading African payment processing company that supports multiple payment methods.

### Payment Flow

```
┌─────────────┐         ┌─────────────┐         ┌──────────────┐
│   Mobile    │         │   Next.js   │         │ InterSwitch  │
│     App     │────────▶│   Server    │────────▶│   Gateway    │
└─────────────┘         └─────────────┘         └──────────────┘
      │                       │                        │
      │  1. Select Plan       │                        │
      │──────────────────────▶│                        │
      │                       │  2. Initialize Payment │
      │                       │───────────────────────▶│
      │                       │                        │
      │                       │  3. Return Checkout URL│
      │                       │◀───────────────────────│
      │  4. Open Checkout     │                        │
      │◀──────────────────────│                        │
      │                       │                        │
      │  5. Complete Payment  │                        │
      │───────────────────────────────────────────────▶│
      │                       │                        │
      │  6. Redirect Back     │                        │
      │◀───────────────────────────────────────────────│
      │                       │                        │
      │  7. Verify Payment    │                        │
      │──────────────────────▶│  8. Verify Transaction │
      │                       │───────────────────────▶│
      │                       │                        │
      │                       │  9. Return Status      │
      │                       │◀───────────────────────│
      │  10. Update User      │                        │
      │◀──────────────────────│                        │
      │                       │                        │
```

### InterSwitch API Endpoints

#### 1. Initialize Payment

**Endpoint**: `POST /api/payments/interswitch/initialize`

**Request Body**:
```json
{
  "amount": 5000,
  "serviceId": "fence_ai_monthly",
  "customerEmail": "user@example.com",
  "customerName": "John Doe",
  "currency": 566,
  "redirectUrl": "https://your-app.com/payment-response",
  "transactionReference": "fence_1234567890_abc123",
  "metadata": {
    "userId": "user123",
    "plan": "monthly"
  }
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "transactionReference": "fence_1234567890_abc123",
    "checkoutUrl": "https://newwebpay.qa.interswitchng.com/collections/w/pay",
    "redirectUrl": "https://your-app.com/payment-response",
    "mode": "TEST",
    "formFields": {
      "merchant_code": "MX6072",
      "pay_item_id": "9405967",
      "site_redirect_url": "https://your-app.com/payment-response",
      "txn_ref": "fence_1234567890_abc123",
      "amount": "5000",
      "currency": "566",
      "cust_email": "user@example.com",
      "cust_name": "John Doe",
      "payment_item": "fence_ai_monthly"
    }
  }
}
```

#### 2. Verify Payment

**Endpoint**: `GET /api/payments/interswitch/verify?transactionReference=<txn_ref>&amount=<amount>`

**Response**:
```json
{
  "success": true,
  "data": {
    "ResponseCode": "00",
    "ResponseDescription": "Approved Successful",
    "Amount": "5000",
    "MerchantReference": "fence_1234567890_abc123",
    "PaymentReference": "FBN|WEB|MX6072|12-12-2024|123456",
    "RetrievalReferenceNumber": "000012345678",
    "TransactionDate": "2024-12-12 10:30:00"
  }
}
```

### Test Credentials

InterSwitch provides test credentials for development:

**General Integration Test Credentials:**
- Merchant Code: `MX6072`
- Pay Item ID: `9405967`
- Mode: `TEST`

**Card Payment API Test Credentials:**
- Merchant Code: `MX21696`
- Pay Item ID: `4177785`
- Client ID: `IKIA3B827951EA3EC2E193C51DA1D22988F055FD27DE`
- Secret: `ajkdpGiF6PHVrwK`

**Test Cards:**
```
Visa: 4111111111111111
Mastercard: 5399838383838381
Verve: 5061020000000000094
CVV: 123
Expiry: Any future date
PIN: 1234
OTP: 123456
```

### Production Setup

1. **Get Live Credentials**:
   - Contact InterSwitch to get production credentials
   - Complete merchant onboarding process
   - Receive live merchant code and pay item ID

2. **Update Environment Variables**:
   ```env
   INTERSWITCH_MERCHANT_CODE=<your_live_merchant_code>
   INTERSWITCH_PAY_ITEM_ID=<your_live_pay_item_id>
   INTERSWITCH_REDIRECT_URL=https://your-production-domain.com/payment-response
   INTERSWITCH_MODE=LIVE
   ```

3. **Update Checkout URL**:
   - Test: `https://newwebpay.qa.interswitchng.com/collections/w/pay`
   - Live: `https://newwebpay.interswitchng.com/collections/w/pay`

4. **Implement Webhook Handler**:
   - Set up a webhook endpoint to receive payment notifications
   - Verify payment status server-side
   - Update user subscription status in database

---

## 🎯 Freemium Model

Fence AI operates on a freemium business model with the following tiers:

### Free Tier

**Limits:**
- ✅ 3 land research prompts (map-based AI analysis)
- ✅ 1 AI chat message
- ✅ Basic features access
- ✅ Conversation history

**When Limits Are Reached:**
- Non-dismissible upgrade prompt appears
- User must upgrade to continue using AI features
- All other app features remain accessible

### Premium Tier

**Monthly Plan: ₦5,000/month**
- ✅ Unlimited land research prompts
- ✅ Unlimited AI chat conversations
- ✅ Advanced analytics & insights
- ✅ Priority support
- ✅ Export reports & data

**Yearly Plan: ₦50,000/year (17% savings)**
- ✅ Everything in Monthly Plan
- ✅ Save ₦10,000 annually
- ✅ Early access to new features
- ✅ Dedicated account manager
- ✅ Custom integrations

### Usage Tracking

Usage is tracked locally using `SharedPreferences`:

```dart
// Check if user can send research prompt
final canSend = await UsageTrackingService().canSendResearchPrompt();

// Increment usage counter
await UsageTrackingService().incrementResearchPromptCount();

// Get usage statistics
final stats = await UsageTrackingService().getUsageStats();
// Returns: {
//   researchCount: 2,
//   chatCount: 1,
//   researchRemaining: 1,
//   chatRemaining: 0,
//   hasReachedLimit: false
// }

// Reset usage (for testing)
await UsageTrackingService().resetUsage();
```

---

## 📚 API Documentation

### Mobile App Services

#### FenceAIService

Handles AI-powered land analysis:

```dart
final fenceAI = FenceAIService();

// Comprehensive land analysis
final analysis = await fenceAI.analyzeLandDevelopmentPotential(
  latitude: 6.5244,
  longitude: 3.3792,
  landSize: 5000, // square meters
  soilType: 'Sandy loam',
  existingVegetation: 'Grassland',
);

// Quick assessment
final assessment = await fenceAI.quickLandAssessment(
  latitude: 6.5244,
  longitude: 3.3792,
);

// Specific development recommendations
final recommendations = await fenceAI.getSpecificDevelopmentRecommendations(
  latitude: 6.5244,
  longitude: 3.3792,
  developmentType: 'residential',
  budget: 50000000,
  timeline: '2 years',
);
```

#### ChatAIService

Handles conversational AI:

```dart
final chatAI = ChatAIService();

// Generate chat response
final result = await chatAI.generateChatResponse(
  userMessage: 'What are the best crops for sandy soil?',
  conversationHistory: [
    {'role': 'user', 'content': 'Previous message'},
    {'role': 'assistant', 'content': 'Previous response'},
  ],
);

// result contains:
// {
//   'response': 'AI response text',
//   'locations': [list of detected locations],
//   'has_locations': true/false
// }
```

#### MapService

Handles location data enrichment:

```dart
final mapService = MapService();

// Get comprehensive location data
final locationData = await mapService.getComprehensiveLocationData(
  latitude: 6.5244,
  longitude: 3.3792,
);

// Returns detailed information including:
// - Formatted address
// - City, state, country
// - Elevation
// - Nearby businesses
// - Nearby schools
// - Nearby hospitals
// - And more...
```

### Server API Endpoints

#### POST /api/payments/interswitch/initialize

Initialize a payment transaction.

**Request:**
```json
{
  "amount": 5000,
  "serviceId": "fence_ai_monthly",
  "customerEmail": "user@example.com",
  "customerName": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "transactionReference": "fence_1234567890_abc123",
    "checkoutUrl": "https://newwebpay.qa.interswitchng.com/collections/w/pay",
    "formFields": { ... }
  }
}
```

#### GET /api/payments/interswitch/verify

Verify a payment transaction.

**Query Parameters:**
- `transactionReference`: Transaction reference from initialization
- `amount`: Transaction amount

**Response:**
```json
{
  "success": true,
  "data": {
    "ResponseCode": "00",
    "ResponseDescription": "Approved Successful",
    "Amount": "5000"
  }
}
```

---

## 🔐 Environment Variables

### Mobile App (.env)

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key

# OpenAI API
OPENAI_API_KEY=sk-your_openai_api_key

# Google Maps API
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### Server (.env)

```env
# InterSwitch Payment Gateway
INTERSWITCH_MERCHANT_CODE=MX6072
INTERSWITCH_PAY_ITEM_ID=9405967
INTERSWITCH_REDIRECT_URL=https://your-domain.com/payment-response
INTERSWITCH_MODE=TEST

# Optional: Card Payment API
# INTERSWITCH_CARD_API_MERCHANT_CODE=MX21696
# INTERSWITCH_CARD_API_PAY_ITEM_ID=4177785
# INTERSWITCH_CARD_API_CLIENT_ID=your_client_id
# INTERSWITCH_CARD_API_SECRET=your_secret
```

---

## 🧪 Testing

### Mobile App Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Testing Freemium Flow

1. **Reset Usage Counters**:
   ```dart
   await UsageTrackingService().resetUsage();
   ```

2. **Test Research Limit**:
   - Go to map page
   - Trigger 3 land research analyses
   - On 4th attempt, verify non-dismissible upgrade prompt appears

3. **Test Chat Limit**:
   - Send 1 chat message
   - On 2nd attempt, verify non-dismissible upgrade prompt appears

4. **Test Payment Flow**:
   - Click "Upgrade Now"
   - Select a plan
   - Use test card details
   - Verify redirect and payment verification

### Server Testing

```bash
# Test payment initialization
curl -X POST http://localhost:3000/api/payments/interswitch/initialize \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000,
    "serviceId": "test_service",
    "customerEmail": "test@example.com"
  }'

# Test payment verification
curl "http://localhost:3000/api/payments/interswitch/verify?transactionReference=fence_123&amount=5000"
```

---

## 🚢 Deployment

### Mobile App Deployment

#### Android (Google Play Store)

1. **Build App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

2. **Sign the App**:
   - Create keystore
   - Configure `android/key.properties`
   - Update `android/app/build.gradle`

3. **Upload to Play Console**:
   - Create app listing
   - Upload app bundle
   - Complete store listing
   - Submit for review

#### iOS (App Store)

1. **Build iOS App**:
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**:
   - Open `ios/Runner.xcworkspace`
   - Product → Archive
   - Upload to App Store Connect

3. **Submit for Review**:
   - Complete app information
   - Add screenshots
   - Submit for review

### Server Deployment

#### Vercel (Recommended for Next.js)

1. **Install Vercel CLI**:
   ```bash
   npm i -g vercel
   ```

2. **Deploy**:
   ```bash
   cd server
   vercel
   ```

3. **Set Environment Variables**:
   - Go to Vercel dashboard
   - Add all environment variables
   - Redeploy

#### Alternative: Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

```bash
docker build -t fence-server .
docker run -p 3000:3000 --env-file .env fence-server
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- **Flutter**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- **TypeScript**: Follow [TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- Run linters before committing:
  ```bash
  # Flutter
  flutter analyze
  dart format .
  
  # TypeScript
  npm run lint
  ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

For support, email support@fenceai.com or join our Slack channel.

---

## 🙏 Acknowledgments

- **OpenAI** for GPT-4 API
- **Google** for Maps Platform
- **Supabase** for backend infrastructure
- **InterSwitch** for payment processing
- **Flutter** and **Next.js** communities

---

## 📊 Project Status

- ✅ Core Features: Complete
- ✅ Payment Integration: Complete
- ✅ Freemium Model: Complete
- 🚧 Advanced Analytics: In Progress
- 📋 Compare Plots Feature: Planned

---

**Built with ❤️ by the Fence AI Team**

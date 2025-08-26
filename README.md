# MSP E-commerce Platform

A comprehensive Flutter-based e-commerce platform that provides a seamless shopping experience for tools and appliances, with a focus on grills and outdoor cooking equipment.

## Features

### Core Functionality
- 🛍️ Product browsing and search with advanced filtering
- 💝 Product wishlist and liked products management
- 🔍 Brand-based product categorization and search
- 📱 Responsive design for all devices (mobile, web, desktop)
- 🔐 Secure user authentication with Firebase
- 🛒 Product comparison system
- 👥 User account management and preferences
- 📊 Dashboard with analytics and charts
- 🔔 Push notifications and in-app messaging

### Technical Features
- 🔥 **Firebase Integration**
  - Real-time database (Firebase Realtime Database)
  - Cloud messaging (FCM)
  - Analytics and remote configuration
  - In-app messaging
  - Authentication services
  - Cloud Functions backend
- 💾 **Local Database**
  - SQLite for offline data storage
  - Product preferences and comparison data
  - User settings and filters
- 🔄 **Background Services**
  - Data synchronization
  - Push notification handling
  - Offline data management
- 🌐 **Cross-Platform Support**
  - Android, iOS, Web, Windows, macOS, Linux
  - Responsive web design
  - Platform-specific optimizations

### User Interface
- 🎨 Material Design 3 with custom branding
- 🎭 Custom theme with MSP brand colors
- 📱 Responsive layouts for all screen sizes
- 🎬 Smooth animations and transitions
- 🔍 Advanced search with filters
- 📊 Interactive charts and analytics
- 💫 Custom product image galleries
- 🎯 Category-based navigation

## Getting Started

### Prerequisites
- Flutter SDK (>=3.1.3)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Node.js 18+ (for Cloud Functions)

### Installation
1. Clone the repository
```bash
git clone https://github.com/yourusername/minsellprice.git
cd minsellprice
```

2. Install Flutter dependencies
```bash
flutter pub get
```

3. Install Firebase Functions dependencies
```bash
cd functions
npm install
cd ..
```

4. Configure Firebase
- Add your Firebase configuration files:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `lib/core/utils/firebase/firebase_options.dart`
- Update Firebase project settings in `firebase.json`

5. Run the app
```bash
flutter run
```

## Project Structure
```
lib/
├── core/                    # Core utilities and configurations
│   ├── apis/              # API integration and constants
│   └── utils/             # Utility functions and constants
│       ├── constants/      # App constants and colors
│       ├── device_and_resolution_checkers/  # Platform detection
│       └── firebase/      # Firebase configuration
├── screens/                # Application screens
│   ├── account_screen/    # User account management
│   ├── categories_screen/ # Product categories
│   ├── comparison_screen/ # Product comparison
│   ├── dashboard_screen/  # Analytics dashboard
│   ├── home_page/         # Main home screen
│   ├── liked_product_screen/ # Wishlist management
│   ├── loging_page/       # Authentication screens
│   ├── product_details_screen/ # Product information
│   ├── product_list_screen/ # Product listings
│   ├── search_screen/     # Search functionality
│   └── splash_screen/     # App initialization
├── model/                  # Data models
├── reposotory_services/    # Database operations
├── service_new/           # Local database services
├── services/              # Business logic services
├── widgets/               # Reusable UI components
└── res/                   # Resources and assets
```

## Key Dependencies

### State Management & Architecture
- `flutter_bloc`: State management
- `provider`: Dependency injection
- `equatable`: Value equality

### Firebase & Backend
- `firebase_core`: Core Firebase functionality
- `firebase_auth`: User authentication
- `firebase_messaging`: Push notifications
- `firebase_database`: Real-time database
- `firebase_analytics`: Usage analytics
- `firebase_remote_config`: Dynamic configuration

### UI & Design
- `google_fonts`: Typography
- `lottie`: Animated graphics
- `shimmer`: Loading effects
- `flutter_animate`: Smooth animations
- `syncfusion_flutter_charts`: Data visualization

### Data & Storage
- `sqflite`: Local SQLite database
- `shared_preferences`: Local preferences
- `cached_network_image`: Image caching
- `http`: HTTP requests

### Platform & Utilities
- `flutter_inappwebview`: Web content integration
- `permission_handler`: Device permissions
- `device_info_plus`: Device information
- `flutter_background_service`: Background processing

## Firebase Configuration

### Cloud Functions
The project includes Firebase Cloud Functions for backend operations:
- Product data management
- User analytics
- Notification services
- Data synchronization

### Database Rules
Firebase Realtime Database rules are configured in `database.rules.json` for secure data access.

### Remote Config
Dynamic configuration management for app features and settings.

## Development

### Code Style
- Follows Flutter best practices
- Uses consistent naming conventions
- Implements proper error handling
- Comprehensive logging system

### Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for critical flows

### Performance
- Image caching and optimization
- Lazy loading for large datasets
- Background data synchronization
- Efficient database queries

## Deployment

### Android
- Configure signing keys in `android/app/build.gradle`
- Update version in `pubspec.yaml`
- Build APK: `flutter build apk --release`

### iOS
- Configure certificates in Xcode
- Update version in `ios/Runner/Info.plist`
- Build: `flutter build ios --release`

### Web
- Build: `flutter build web`
- Deploy to Firebase Hosting or any web server

### Cloud Functions
```bash
cd functions
npm run deploy
```

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Support
For support and questions:
- Email: support@msp.com
- GitHub Issues: [Create an issue](https://github.com/yourusername/minsellprice/issues)
- Documentation: Check the project wiki

## Version
Current version: 1.0.0+1

---

**Built with ❤️ using Flutter and Firebase**



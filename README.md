## Getting Started
This project is a starting point for a Flutter application.

## Environment

flutter SDK : 3.29.3

## Build Web

fvm flutter pub get
fvm flutter build web --release

Project Structure:

# Clone repo
git clone <repository-url>
cd flutter_food_tracker

# Install dependencies
flutter pub get

# Configure API Key
OPENAI_API_KEY = ''
GEMINI_API_KEY = 'AIzaSyC8GoEoxxLZFPbTrl-F5OvWwukEs5MPsiA'

# Run the application
flutter run -d chrome


food_gpt_web/
├── web/                   
│   └── # Directory containing configuration and source code related to the Web application.
├── lib/                   
│   ├── providers/            # Contains controller files used to define fixed values, function, etc.
│   ├── screens/              # Contains all screens of project
│   ├── services/             # Contains services that handle backend connection and logic processing.
│   ├── shared/               # Contains components shared across the entire application.
│   │   └── utils/            # Common utilities and helper functions such as string manipulation, time formatting.
│   │   └── constants.dart    # Contains constants used throughout the application (API keys, URLs, etc.).
│   └── main.dart             # The main file that launches the application.
├── test/                  
│   └── # Contains unit test files for each part of the application.
└── pubspec.yaml           
└── # Flutter project configuration file that declares packages (dependencies), assets, and application information.
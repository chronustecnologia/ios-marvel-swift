# Marvel Characters App

An iOS application that displays Marvel characters, allows viewing character details, and managing favorites.

## Features

- Browse Marvel characters with infinite scrolling
- Search characters by name
- View detailed character information
- Save favorite characters for offline viewing
- Share character images

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures representing characters and API responses
- **Views**: UIKit elements for displaying the UI
- **ViewModels**: Business logic layer that connects models and views
- **Services**: Handle API communication and local data persistence

## Technologies Used

- Swift 5.0+
- UIKit
- URLSession for networking
- UserDefaults for data persistence
- XCTest for unit testing

## Key Components

### Network Layer
- `APIClient`: Generic network client for making API requests
- `MarvelAPI`: Endpoints and authentication for the Marvel API

### Data Persistence
- `FavoriteService`: Manages saving and retrieving favorite characters using UserDefaults

### UI Components
- Tab-based interface with Characters and Favorites tabs
- Search functionality for filtering characters
- Pull-to-refresh for updating content
- Empty states for no content, errors, and offline mode

## Setup Instructions

1. Clone the repository
2. Open `MarvelApp.xcodeproj` in Xcode
3. Add your Marvel API keys in `MarvelAPI.swift`:
   ```swift
   private static let publicKey = "YOUR_PUBLIC_KEY"
   private static let privateKey = "YOUR_PRIVATE_KEY"

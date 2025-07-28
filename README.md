# StustApp


https://github.com/user-attachments/assets/c9903d0c-fbfc-4417-be63-41904fe7a886



**南台通Beta v1.0** - A Flutter-based student portal application for Southern Taiwan University of Science and Technology (STUST).

## Overview

StustApp is a comprehensive mobile and web application designed to streamline student academic activities and campus life management. The app provides a modern, neumorphic-styled interface for accessing various university services and information.

## Features

### Core Functionality
- **Latest Events** (最新事件) - Stay updated with current campus activities and assignments
- **Latest Announcements** (最新公告) - Access official university bulletins and notices 
- **Absence Tracking** (缺席) - Monitor and manage class attendance records 
- **Reflection Submissions** (未繳心得) - Track and submit required academic reflections 
- **Leave Requests** (請假) - Submit and manage leave applications 
- **Quick Homework Submission** (快速繳交作業) - Streamlined assignment submission process

### Technical Features
- **Persistent Authentication** - Automatic login with saved credentials using SharedPreferences 
- **Responsive Design** - Optimized layouts for both mobile and desktop interfaces
- **Neumorphic UI** - Modern design with soft, tactile interface elements 
- **Cross-Platform Support** - Built with Flutter for Android, iOS, Web, Windows, macOS, and Linux 

## Technology Stack

### Framework & Language
- **Flutter** - Cross-platform development framework 
- **Dart** - Programming language (SDK >=2.18.5 <3.0.0)

### Key Dependencies
- **HTTP Client** - Network requests for API communication 
- **HTML Rendering** - Dynamic content display with flutter_html 
- **Local Storage** - Persistent data storage with SharedPreferences 
- **Neumorphic Design** - Modern UI components with flutter_neumorphic_null_safety 

## Application Architecture

The app follows a modular structure with separate components for each major feature:

- **Authentication Module** - Login and session management
- **Function Modules** - Individual feature implementations for homework, bulletins, absence tracking, etc. 
- **Responsive Layout** - Adaptive UI components for different screen sizes
## User Interface

The application features a clean, intuitive interface with:
- Portrait-only orientation for consistent user experience
- Light theme with customizable neumorphic styling 
- Centralized navigation from the main dashboard 
- Logout functionality with confirmation dialog 

## Project Information

- **Version**: 1.0.0+1 
- **Target Institution**: Southern Taiwan University of Science and Technology (STUST)
- **Development Status**: Beta version
- **License**: Private package (not published to pub.dev)

## Notes

This application is specifically designed for STUST students and staff to manage their academic activities efficiently. The app integrates with official university systems to provide real-time access to important academic information and services. The neumorphic design provides a modern, accessible interface while maintaining functionality across multiple platforms.

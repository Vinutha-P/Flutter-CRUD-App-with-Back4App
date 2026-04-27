# Task Manager App - Flutter CRUD with Back4App

## Project Overview

This Flutter app is a complete Task Manager that uses Back4App (Parse Server) as Backend-as-a-Service. It supports authentication and task CRUD (Create, Read, Update, Delete) with cloud persistence.

## Features

- User registration with email and password
- User login and secure logout
- Create tasks with title and description
- Read tasks from Back4App cloud database
- Update task details and completion status
- Delete tasks
- Session-based auto-login on app restart

## Technology Stack

- Frontend: Flutter (Dart)
- Backend: Back4App (Parse Server)
- Database: Back4App Cloud Database
- Version Control: Git/GitHub

## Project Structure

- `lib/main.dart` - app bootstrap and route entry
- `lib/back4app_config.dart` - Back4App credentials
- `lib/services/back4app_service.dart` - auth and task API calls
- `lib/models/task_model.dart` - task model mapping
- `lib/screens/login_screen.dart` - login page
- `lib/screens/register_screen.dart` - registration page
- `lib/screens/task_list_screen.dart` - task list with edit/delete/toggle
- `lib/screens/task_form_screen.dart` - create/edit task form

## Back4App Setup

1. Create a Back4App app.
2. In Back4App dashboard, open **App Settings -> Security & Keys**.
3. Copy:
   - `Application ID`
   - `Client Key`
   - `Parse Server URL` (usually `https://parseapi.back4app.com`)
4. Update `lib/back4app_config.dart`:

## Back4App Database Class

The app uses Parse class `Task` with fields:

- `title` (String)
- `description` (String)
- `isCompleted` (Boolean)
- `owner` (Pointer to `_User`)

This class is created automatically when the first task is saved.

## Run the App

```bash
flutter pub get
flutter run
```

## App Flow

1. Register a user from **Register** page.
2. Login using username and password.
3. Manage tasks:
   - Add using `+` button
   - Edit by tapping a task
   - Mark done using checkbox
   - Delete using trash icon
4. Logout using top-right logout button.

# Site Directory

The `sites` directory in this project contains `*.dart` files that are responsible for building the user interface (UI) of the Dashboard/App. These files are an integral part of the development process and play a crucial role in creating the visual elements and interactions of the site.

## Purpose

The primary purpose of the `sites` directory is to organize and store the Dart files that handle the UI logic. These files are responsible for defining the structure, design, and behavior of the dashboard's various pages and components. By separating the UI-related code into dedicated files, it becomes easier to manage, maintain, and extend the app's interface.

## File Structure

Within the `sites` directory, you may find several `*.dart` files, each representing a specific part of the Dashboard or a particular page. The file names should ideally be descriptive and indicative of their purpose within the project. Here is an example of the file structure you might encounter:

```
sites/
├── kitsu_deck
│   ├── index.dart
│   └── macro/
│       ├── macro_dashboard.dart
│       ├── macro_editor.dart
│       ├── macro_images.dart
│       └── macro_layout_editor.dart
└── settings/
    ├── add_device.dart
    ├── app.dart
    ├── auth_device.dart
    ├── debug.dart
    ├── kitsu_deck.dart
    ├── navbar.dart
    └── no_device.dart
```

In the above structure:

- `kitsu_deck` represents all sites related to the Kitsu Deck.
- `kitsu_deck/index.dart` is the index file for the Kitsu Deck. Here you can enter the KitsuDeck`s macro dashboard for example.
- `kitsu_deck/macro` contains the code for constructing the Kitsu Deck's macro dashboard, editor, images, and layout editor.

- `settings` contains all sites related to the settings App/Dashboard, like adding a KitsuDeck, re-auth a KitsuDeck(if the pin has changed)

## Building the UI

Each `*.dart` file within the `sites` directory contains code that defines the UI elements and their behavior. Dart is a programming language commonly used with Flutter, a popular UI framework for building cross-platform applications. Therefore, these `*.dart` files likely leverage the Flutter framework to construct the UI.

Typically, a Dart file responsible for building the UI will include various components such as widgets, layouts, styles, and event handlers. These components work together to create a cohesive and interactive user interface.

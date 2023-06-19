# Classes Directory

The `classes` directory in this Flutter project contains subfolders such as `app`, `kitsu_deck`, and `websocket`. Each of these subfolders houses `.dart` files that contain classes responsible for managing different aspects of the application. These classes often extend `ChangeNotifier` from the `provider` package to facilitate state management and enable reactive updates to the UI.

## Purpose

The primary purpose of the `classes` directory is to organize and store class files that encapsulate specific functionalities or modules within the application. By separating classes into dedicated folders, it becomes easier to manage, maintain, and extend the codebase, while also promoting code readability and modularity.

## File Structure

Within the `classes` directory, you will find subfolders corresponding to different modules or features of the application. For example, the `app` folder contains classes related to the overall application functionality(localization, app theme ...), while the `kitsu_deck` folder contains classes related to the KitsuDeck (macro images, macros List ...). The file structure may resemble the following:

```plaintext
classes/
├── app/
│   ├── settings.dart
│   └── ...
├── kitsu_deck/
│   ├── device.dart
│   └── ...
├── websocket/
│   ├── connector.dart
│   └── ...
└── ...
```

## State Management with `ChangeNotifier` and `provider` package

The classes within the subfolders of the `classes` directory often extend `ChangeNotifier` from the `provider` package. This approach facilitates state management within the Flutter application and enables reactive updates to the UI.

By extending `ChangeNotifier`, these classes can implement methods to modify their internal state and then notify any registered listeners of the state changes. The `provider` package aids in dependency injection and makes it easier to access and utilize the state across different parts of the application.

The integration of `ChangeNotifier`-based classes typically involves:

- Registering the class as a provider within the application's widget tree (main.dart-MultiProvider).
- Using the `Consumer` widget or `Provider.of<T>(context)` to access and listen to state changes.
- Calling the appropriate methods within the `ChangeNotifier`-extended class to modify the state.
- Notifying listeners through `notifyListeners()` to trigger UI updates.

## Conclusion

The `classes` directory serves as a central location for organizing class files within the Flutter project. It contains subfolders that represent different modules or features of the application.
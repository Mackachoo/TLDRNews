# TLDRNews-App

A Flutter video client for the TLDR News YouTube channels. Firestore holds channel
and video data, a Python Cloud Function ingests it from the YouTube Data API, and
the app ships to web, Android and iOS from one codebase.

## Commands

```bash
flutter pub get
flutter run -d chrome
flutter analyze
dart run build_runner build --delete-conflicting-outputs   # after touching lib/src/objects/

firebase emulators:start --only functions,firestore
firebase deploy --only hosting
firebase deploy --only functions,firestore:rules,firestore:indexes
```

Full local setup, including Firebase project config and keys, is in [docs/setup.md](docs/setup.md).
The data model and how the pieces fit together is in [docs/architecture.md](docs/architecture.md).

## Layout

```text
lib/src/
├─ objects/     models (json_serializable)
├─ services/    Firestore, auth, config, local storage
├─ screens/     one folder per route, each with a *_controller.dart
├─ widgets/     shared widgets
└─ utils/       extensions, theme, messages
functions/
├─ main.py      trigger definitions only
└─ src/
   ├─ youtube/  YouTube ingest: API client, block store, sync orchestration
   └─ utils/    shared helpers for callables
firebase/       firestore.rules, firestore.indexes.json
```

## Comments

**Do not write long explanatory comments.** Code should be short and readable on
its own. A comment explaining *why* a line exists usually means the code needs a
better name, not a paragraph above it.

The one comment style this codebase does want is the section separator, used to
group methods inside a class so the file is easy to scan:

```dart
//* CRUD -------------------------------------------------------------
//* Video Blocks ------------------------------------------------------
//* Private Methods ---------------------------------------------------
```

See [channel_service.dart](lib/src/services/firestore/channel_service.dart),
[_firestore_core.dart](lib/src/services/firestore/_firestore_core.dart) and
[app_controller.dart](lib/src/app_controller.dart) for the pattern. Use `#*` for
the same effect in Python.

A one-line doc comment on a public method whose purpose is not obvious from its
name is fine. Paragraphs of rationale inside a method body are not.

## Conventions

**Widgets import `package:material_ui/material_ui.dart`**, a Flutter fork — not
`package:flutter/material.dart`. Its widget classes are distinct types, so tests
and finders written against `flutter/material.dart` silently match nothing.

**State is plain `ChangeNotifier` + `ListenableBuilder`.** No Riverpod, Provider
or Bloc. Each screen folder owns a `*_controller.dart`; long-lived ones hang off
`AppCtlr` in [app_controller.dart](lib/src/app_controller.dart).

**Services are `Future`-based**, wrap work in `try`/`catch`, log with
`debugPrint('ClassName.method: $error')`, and return `null` or `false` rather than
throwing. Callers check for null; they do not catch.

**Models** live in `lib/src/objects/` and use `json_serializable`. `id` is always
`@JsonKey(includeToJson: false)` because it is the document id or map key, and is
injected back in during deserialization. Regenerate after every change.

**Dates are Firestore `Timestamp`s**, converted with `TimestampConverter`. Never
store a date as a string.

**Only the Cloud Function writes to `channels/**`.** The client reads. Admin edits
go through the callable, not direct Firestore writes.

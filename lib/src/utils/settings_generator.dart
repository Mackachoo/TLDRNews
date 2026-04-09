import 'dart:async';
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:build/build.dart';

Builder settingsBuilder(BuilderOptions options) => SettingsBuilder();

class SettingsBuilder implements Builder {
  @override
  final buildExtensions = const {
    'settings_controller.json': ['settings_controller.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;

    // Only process settings_controller.json
    if (!inputId.path.endsWith('settings_controller.json')) {
      return;
    }

    final contents = await buildStep.readAsString(inputId);
    final json = jsonDecode(contents) as Map<String, dynamic>;

    final generatedContent = _generateSettingsController(json);

    final outputId = inputId.changeExtension('.g.dart');
    await buildStep.writeAsString(outputId, generatedContent);
  }

  String _generateSettingsController(Map<String, dynamic> json) {
    final buffer = StringBuffer();

    // File header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated from settings_controller.json');
    buffer.writeln();
    buffer.writeln("part of 'settings_controller.dart';");
    buffer.writeln();

    // Generate main SettingsController class
    _generateMain(buffer, json);

    // Generate section controllers
    for (final section in json.entries) {
      final sectionName = section.key;
      final settings = section.value as Map<String, dynamic>;

      if (settings.isNotEmpty) {
        _generateSection(buffer, sectionName, settings);
      }
    }

    return buffer.toString();
  }

  void _generateMain(StringBuffer buffer, Map<String, dynamic> json) {
    buffer.writeln('mixin SettingsLogic on ChangeNotifier {');
    buffer.writeln();

    // Generate section controller instances
    for (final section in json.entries) {
      final sectionName = section.key;
      final settings = section.value as Map<String, dynamic>;

      if (settings.isNotEmpty) {
        final className = '${_capitalize(sectionName)}SettingsController';
        buffer.writeln('  final $className _$sectionName = $className();');
      }
    }
    buffer.writeln();

    // Generate getters for section controllers
    for (final section in json.entries) {
      final sectionName = section.key;
      final settings = section.value as Map<String, dynamic>;

      if (settings.isNotEmpty) {
        final className = '${_capitalize(sectionName)}SettingsController';
        buffer.writeln('  $className get $sectionName => _$sectionName;');
      }
    }
    buffer.writeln();

    // Generate loadAllSettings method
    buffer.writeln('  Future<void> loadAllSettings() async {');
    for (final section in json.entries) {
      final sectionName = section.key;
      final settings = section.value as Map<String, dynamic>;

      if (settings.isNotEmpty) {
        buffer.writeln('    await _$sectionName.loadSettings();');
        buffer.writeln('    _$sectionName.addListener(notifyListeners);');
      }
    }
    buffer.writeln('    notifyListeners();');
    buffer.writeln('  }');
    buffer.writeln();

    // Add dispose method to clean up listeners
    buffer.writeln('  @override');
    buffer.writeln('  void dispose() {');
    for (final section in json.entries) {
      final sectionName = section.key;
      final settings = section.value as Map<String, dynamic>;

      if (settings.isNotEmpty) {
        buffer.writeln('    _$sectionName.removeListener(notifyListeners);');
        buffer.writeln('    _$sectionName.dispose();');
      }
    }
    buffer.writeln('    super.dispose();');
    buffer.writeln('  }');

    buffer.writeln('}');
  }

  void _generateSection(StringBuffer buffer, String sectionName, Map<String, dynamic> settings) {
    final className = '${_capitalize(sectionName)}SettingsController';

    buffer.writeln('class $className with ChangeNotifier {');
    buffer.writeln('  $className();');
    buffer.writeln();

    // Generate private fields for this section
    for (final setting in settings.entries) {
      final fieldName = setting.key;
      final settingConfig = setting.value;
      final fieldType = _getFieldType(settingConfig);
      final defaultValue = _getDefaultValue(settingConfig);
      buffer.writeln('  $fieldType _$fieldName${defaultValue != null ? ' = $defaultValue' : ''};');
    }
    buffer.writeln();

    // Generate load method for this section
    buffer.writeln('  Future<void> loadSettings() async {');
    for (final setting in settings.entries) {
      final fieldName = setting.key;
      final settingConfig = setting.value;
      final fieldType = _getFieldType(settingConfig);
      final defaultValue = _getDefaultValue(settingConfig);
      final storageKey = _getStorageKey(fieldName, sectionName);
      final serviceMethod = _getServiceMethod(fieldType, 'get');
      buffer.writeln(
        "    final stored${_capitalize(fieldName)} = await LocalService.$serviceMethod('$storageKey');",
      );
      buffer.writeln(
        '    _$fieldName = stored${_capitalize(fieldName)}${defaultValue != null ? ' ?? $defaultValue' : ''};',
      );
    }
    buffer.writeln('    notifyListeners();');
    buffer.writeln('  }');
    buffer.writeln();

    // Generate notify method for this section
    buffer.writeln('  void notify() => notifyListeners();');
    buffer.writeln();

    // Generate getters and setters for this section
    for (final setting in settings.entries) {
      final fieldName = setting.key;
      final settingConfig = setting.value;
      final fieldType = _getFieldType(settingConfig);
      _generateGetterSetter(buffer, fieldName, fieldType, sectionName);
    }

    buffer.writeln('}');
    buffer.writeln();
  }

  void _generateGetterSetter(
    StringBuffer buffer,
    String fieldName,
    String fieldType,
    String sectionName,
  ) {
    final storageKey = _getStorageKey(fieldName, sectionName);
    final serviceMethod = _getServiceMethod(fieldType, 'set');

    // Getter
    buffer.writeln('  $fieldType get $fieldName => _$fieldName;');

    // Setter
    buffer.writeln('  set $fieldName($fieldType newValue) {');
    buffer.writeln('    if (newValue != _$fieldName) {');
    buffer.writeln('      _$fieldName = newValue;');
    buffer.writeln('      notifyListeners();');
    buffer.writeln("      LocalService.$serviceMethod('$storageKey', newValue);");
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
  }

  String _getServiceMethod(String type, String operation) =>
      '$operation${_capitalize(type.replaceAll('?', ''))}';

  String _getStorageKey(String fieldName, String sectionName) => '${sectionName}_$fieldName';

  String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  String _getFieldType(dynamic settingConfig) {
    if (settingConfig is Map<String, dynamic>) {
      return settingConfig['type'] as String;
    }
    throw ArgumentError('Invalid setting configuration: $settingConfig');
  }

  String? _getDefaultValue(dynamic settingConfig) {
    if (settingConfig is Map<String, dynamic>) {
      if (settingConfig['default'] == 'null') return null;
      return settingConfig['default'] as String;
    }
    throw ArgumentError('Invalid setting configuration: $settingConfig');
  }
}

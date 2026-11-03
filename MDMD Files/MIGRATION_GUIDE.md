````markdown
# React to Flutter/Dart Migration Guide

This document provides a comprehensive guide for migrating the PDF Toolkit web application from React/TypeScript to Flutter/Dart.

## Architecture Comparison

### State Management

**React (useState, useCallback):**
```typescript
const [activeTool, setActiveTool] = useState<Tool>('home');
const [pdfFile, setPdfFile] = useState<File | null>(null);

const handleFileSelect = useCallback((files: File[]) => {
  setPdfFile(files[0]);
}, []);
```

**Flutter (Provider):**
```dart
class AppState extends ChangeNotifier {
  ToolType _activeTool = ToolType.home;
  
  void selectTool(ToolType tool) {
    _activeTool = tool;
    notifyListeners();
  }
}

// In widget:
final appState = Provider.of<AppState>(context);
```

### Component Structure

**React (Functional Components):**
```typescript
const PdfReaderTool: React.FC<PdfReaderToolProps> = ({ initialFile, onGoHome }) => {
  return <div>...</div>;
};
```

**Flutter (StatefulWidget):**
```dart
class PdfReaderScreen extends StatefulWidget {
  final File? initialFile;
  
  const PdfReaderScreen({super.key, this.initialFile});
  
  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(...);
  }
}
```

## Key Conversions

... (omitted for brevity in this copy)

````

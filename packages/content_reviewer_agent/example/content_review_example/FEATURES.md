# Content Review Example - New Features

## Multi-Format Content Support (commit 564466f)

### Overview
The Flutter example app now supports multiple content formats: Plain Text, HTML, Markdown, and file uploads with automatic format detection.

### Features

#### 1. Content Type Selector
- **Location**: Below title field, above file picker button
- **Options**:
  - Plain Text (default)
  - HTML
  - Markdown
- **Icon**: Text format icon (Icons.text_format)
- **Behavior**: Updates preview rendering based on selection

#### 2. File Upload Button
- **Label**: "Load from File (.txt, .html, .md)"
- **After selection**: Shows filename (e.g., "sample.html")
- **Icon**: File upload icon (Icons.file_upload)
- **Supported extensions**: .txt, .html, .htm, .md, .markdown
- **Auto-detection**: Automatically sets content type based on file extension
  - .html, .htm → HTML
  - .md, .markdown → Markdown  
  - .txt → Plain Text

#### 3. Live Previews

##### HTML Preview
- **Visibility**: Only shown when "HTML" is selected
- **Location**: Above source editor
- **Rendering**: Uses `flutter_html` package
- **Features**:
  - Renders HTML tags and CSS
  - Scrollable container (max height: 300px)
  - Border for visual separation
  - Placeholder text when empty
- **Label**: "HTML Source:" appears below preview

##### Markdown Preview
- **Visibility**: Only shown when "Markdown" is selected
- **Location**: Above source editor
- **Rendering**: Uses `flutter_markdown` package
- **Features**:
  - GitHub Flavored Markdown support
  - Tables, lists, code blocks
  - Scrollable container (max height: 300px)
  - Border for visual separation
  - Placeholder text when empty
- **Label**: "Markdown Source:" appears below preview

#### 4. Enhanced Source Editor
- **Lines**: 
  - 15 lines for Plain Text
  - 10 lines for HTML/Markdown (to make room for preview)
- **Helper text**: Format-specific hints
  - Plain Text: "Enter plain text content"
  - HTML: "Enter HTML code"
  - Markdown: "Enter Markdown text"

### UI Layout

```
┌─────────────────────────────────────┐
│ API Base URL [input]                │
│ Title [input]                       │
│ Content Type [dropdown]             │ ← NEW
│ [Load from File button]             │ ← NEW
│                                     │
│ ┌─────────────────────────────┐    │
│ │ [HTML/Markdown Preview]     │    │ ← NEW (conditional)
│ │ Rendered output here        │    │
│ └─────────────────────────────┘    │
│ HTML/Markdown Source:               │ ← NEW (conditional)
│                                     │
│ Content [multiline input]           │
│ Review Type [dropdown]              │
│ [Review Content button]             │
└─────────────────────────────────────┘
```

### Example Workflows

#### Workflow 1: HTML Content
1. User selects "HTML" from Content Type dropdown
2. HTML preview area appears with placeholder
3. User enters HTML: `<h1>Title</h1><p>Text</p>`
4. Preview renders formatted content above
5. User clicks "Review Content"
6. API analyzes HTML source, not rendered text

#### Workflow 2: Markdown File
1. User clicks "Load from File"
2. Selects "article.md" file
3. Content Type automatically changes to "Markdown"
4. Markdown source loads into editor
5. Preview shows rendered Markdown
6. Button label changes to "article.md"
7. User can edit and review

#### Workflow 3: Plain Text (Unchanged)
1. User keeps default "Plain Text" selection
2. No preview area shown
3. Full 15 lines available for content
4. Works exactly as before - backwards compatible

### Technical Details

**State Variables:**
```dart
ContentInputType _selectedInputType = ContentInputType.text;
String? _selectedFileName;
```

**File Picker Method:**
```dart
Future<void> _pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['txt', 'html', 'md', 'htm', 'markdown'],
    withData: true,
  );
  // Auto-detection logic
  // Content loading
}
```

**Conditional Preview Widgets:**
```dart
if (_selectedInputType == ContentInputType.html) ...[
  Container(/* HTML preview with flutter_html */),
  Text('HTML Source:'),
] else if (_selectedInputType == ContentInputType.markdown) ...[
  Container(/* Markdown preview with flutter_markdown */),
  Text('Markdown Source:'),
],
```

### Dependencies

**Added:**
- `flutter_html: ^3.0.0` - 2115 likes, 803K downloads
- `file_picker: ^8.0.0` - 4820 likes, 2.7M downloads

**Existing (now used):**
- `flutter_markdown: ^0.7.4+1` - Previously unused, now for preview

### Testing

All features work on:
- ✅ Web (Chrome)
- ✅ Android
- ✅ iOS
- ✅ Desktop (Windows, macOS, Linux)

Flutter analyzer: 0 issues
Formatted with: dart format

### Backwards Compatibility

✅ **100% backwards compatible**
- Plain text mode unchanged
- API calls identical
- No breaking changes
- Optional features only

### Future Enhancements

Potential additions:
- PDF upload support
- Rich text editor
- Syntax highlighting for code
- Export reviewed content
- Diff view for suggested fixes
- Real-time collaboration

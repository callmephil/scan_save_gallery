# Scan & Save Gallery

A simple Android Flutter app for scanning documents using the device camera and saving the scanned images to the device gallery. Built with:

- [cunning_document_scanner](https://pub.dev/packages/cunning_document_scanner) for native document scanning
- [image_gallery_saver_plus](https://pub.dev/packages/image_gallery_saver_plus) for saving images to the gallery
- [permission_handler](https://pub.dev/packages/permission_handler) for runtime permissions

## Features

- Scan one or multiple documents using your device's camera
- Preview scanned images in a grid
- Save all scanned images to your device gallery
- Clear scanned images and scan more

## Getting Started

1. **Install dependencies:**
   ```sh
   flutter pub get
   ```
2. **Run the app:**
   ```sh
   flutter run
   ```

## Android Setup

- The app requests camera and storage permissions at runtime.
- `minSdkVersion` should be at least 21.
- `android:requestLegacyExternalStorage="true"` is set for compatibility.

## iOS Setup

- Requires iOS 13+ (VisionKit support).
- Add the following to your `Info.plist`:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>We need camera access to scan documents.</string>
  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>We need photo library access to save scanned images.</string>
  ```

## Code Style & Analysis

- Uses `very_good_analysis` and DCM for strict linting.
- Run `make analyze` to check for warnings (0 warning policy).

## License

MIT

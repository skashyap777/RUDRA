# iOS Debugging Guide - Pothole Detection & Profile Updates

This document explains the comprehensive debugging logs added to diagnose iOS-specific issues.

## 🔍 Pothole Detection Debugging

### Model Loading Debug Logs
- Platform detection and iOS flag status
- TFLite model loading success/failure
- Labels loading and count verification
- Model input/output tensor shapes
- Platform-specific thresholds (iOS: 40% confidence, Android: 50%)

### Image Processing Debug Logs
- Image file path and existence verification
- Image bytes length and decoding status
- Original image dimensions, format, and channels
- Image orientation handling with `bakeOrientation()`
- Resized image dimensions verification
- Input tensor creation and element count

### Inference Debug Logs
- Output tensor shape analysis
- Detection box count and elements per box
- Confidence threshold and minimum detection requirements
- Individual high-confidence detections with box indices
- Top 10 confidence scores sorted
- Threshold and count validation checks
- Final detection decision reasoning

### Key Debug Points for iOS Issues
```
🔍 [iOS DEBUG] Platform: ios
🔍 [iOS DEBUG] Confidence threshold: 0.4 (vs 0.5 on Android)
🔍 [iOS DEBUG] Min detections required: 1 (vs 3 on Android)
🔍 [iOS DEBUG] After bakeOrientation: [width]x[height]
🔍 [iOS DEBUG] Top 10 confidences: [list of values]
```

## 👤 Profile Update Debugging

### Photo Upload Debug Logs
- Platform detection and file path verification
- File existence, size, and extension detection
- Content type determination (image/jpeg vs image/png)
- File bytes reading verification
- FormData creation and field inspection
- Multipart request headers and progress tracking
- Response status, headers, and data analysis
- Detailed DioException handling with request/response info

### Profile Data Update Debug Logs
- Request data payload verification
- Response status and data inspection
- Profile refresh operation tracking
- Error handling with stack traces

### Network Layer Debug Logs
- Token retrieval and truncated display
- Request headers and data logging
- Upload progress tracking
- Response status verification
- Detailed error logging with rethrow

## 🚨 Common iOS Issues to Watch For

### Pothole Detection
1. **Image Orientation**: iOS images may have EXIF rotation metadata
   - Look for: `After bakeOrientation` dimension changes
   - Fix: `img.bakeOrientation()` is applied

2. **Low Confidence Scores**: iOS may produce different confidence values
   - Look for: `Top 10 confidences` values
   - Fix: Lower threshold (40% vs 50%) for iOS

3. **Model Loading**: TFLite model compatibility
   - Look for: Model loading success/failure messages
   - Check: Asset path and model file presence

### Profile Updates
1. **Multipart Encoding**: iOS may handle form data differently
   - Look for: FormData creation and field inspection logs
   - Check: Content-Type headers (should be auto-set by Dio)

2. **File Path Issues**: iOS file paths may differ
   - Look for: File existence and path verification
   - Check: File reading success and byte count

3. **Network Headers**: iOS may require specific headers
   - Look for: Request headers in network logs
   - Check: Accept and Authorization headers

## 📱 How to Use These Logs

1. **Enable Debug Mode**: Run app in debug mode to see all logs
2. **Filter Logs**: Search for `[iOS DEBUG]` to see iOS-specific logs
3. **Follow the Flow**: Logs are ordered chronologically through each process
4. **Check Thresholds**: Verify iOS-specific thresholds are being applied
5. **Analyze Failures**: Look for `❌` markers to identify failure points

## 🔧 Testing Checklist

- [ ] Model loads successfully on iOS
- [ ] Image orientation is handled correctly
- [ ] Confidence scores are reasonable (> 0.1)
- [ ] iOS thresholds are applied (40% confidence, 1 detection)
- [ ] File uploads show proper FormData creation
- [ ] Network requests include correct headers
- [ ] Profile updates receive successful responses

## 📊 Expected Log Flow

### Successful Pothole Detection
```
🔄 [iOS DEBUG] Starting model loading...
✅ [iOS DEBUG] Model loaded successfully
🔍 [iOS DEBUG] Starting prediction...
🔍 [iOS DEBUG] After bakeOrientation: 640x640
🔍 [iOS DEBUG] High confidence detection 1: 0.65 at box 1234
✅ [iOS DEBUG] Pothole detected: Pothole detected (65.0%)
```

### Successful Profile Update
```
📸 [iOS DEBUG] Starting profile photo upload...
📁 [iOS DEBUG] File exists: true
📦 [iOS DEBUG] FormData created successfully
🌐 [iOS DEBUG] Upload progress: 1024 / 2048 bytes
✅ [iOS DEBUG] Profile photo upload successful
```
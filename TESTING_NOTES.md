# 🧪 Testing Notes - GenQR App

## ✅ Completed Tasks (Ready for Testing)

### 1. QR Save with White Background

**Location**: `lib/screens/generator_screen.dart` - `_saveQr()` method
**Implementation**:

- Canvas pe white background draw kiya (2448x2448px)
- QR code ko white background ke upar paint kiya
- 200px padding on all sides

**Test Steps**:

1. Open app
2. Generate QR code
3. Click "Save QR Code"
4. Check saved image - white background hona chahiye

---

### 2. QR Save with Theme Color

**Location**: `lib/screens/generator_screen.dart` - `_saveQr()` method
**Implementation**:

- Theme color parameter pass kiya QrPainter ko
- `eyeStyle` aur `dataModuleStyle` dono mein theme color use kiya

**Test Steps**:

1. Settings mein different colors select karo (Red, Blue, Green, etc.)
2. QR generate karo
3. Save karo
4. Saved image mein selected theme color hona chahiye

---

### 3. QR Save with Proper Padding

**Location**: `lib/screens/generator_screen.dart` - `_saveQr()` method
**Implementation**:

- QR size: 2048x2048px
- Padding: 200px on all sides
- Total image: 2448x2448px

**Test Steps**:

1. QR save karo
2. Image open karo
3. QR ke around proper white space hona chahiye (200px)

---

### 4. Gallery Integration (Android)

**Location**: `lib/screens/generator_screen.dart` - `_saveQr()` method
**Android Manifest**: `android/app/src/main/AndroidManifest.xml`
**Implementation**:

- Save path: `/storage/emulated/0/DCIM/GenQR/`
- Media scanner broadcast: `android.intent.action.MEDIA_SCANNER_SCAN_FILE`
- WRITE_EXTERNAL_STORAGE permission added

**Test Steps (Android Device Required)**:

1. QR generate karo
2. Save karo
3. Gallery app open karo
4. "GenQR" album mein saved QR dikhna chahiye
5. Agar nahi dikha to device restart karo aur check karo

**Possible Issues**:

- Android 10+ pe scoped storage issues ho sakte hain
- Agar gallery mein nahi dikha to alternative: MediaStore API use karna padega

---

### 5. System UI Hidden

**Location**: `lib/main.dart`
**Implementation**:

```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
```

**Test Steps**:

1. Mobile pe app run karo
2. Status bar aur navigation bar hidden hona chahiye
3. Swipe karne pe bhi permanently hidden rahega

---

### 6. Advanced Scanner Result Card

**Location**: `lib/screens/scanner_screen.dart`
**Features**:

- URL detection with favicon
- Copy button with clipboard
- Open button for links
- Website name display

**Test Steps**:

1. Scanner open karo
2. URL wala QR scan karo (e.g., https://google.com)
3. Result card mein:
   - Favicon dikhna chahiye
   - Website name (google.com)
   - Copy aur Open buttons
4. Text wala QR scan karo
5. Result card mein sirf Copy button hona chahiye

---

## 🔧 Platform-Specific Testing

### Desktop (Windows/Mac/Linux)

- ✅ File picker dialog for save
- ✅ Compact UI
- ✅ Image picker for scanner

### Mobile (Android/iOS)

- ✅ Direct save to DCIM/GenQR
- ✅ Gallery integration
- ✅ Camera scanner with custom UI
- ✅ Gallery picker button
- ✅ System UI hidden

### Web

- ✅ Direct download via blob URL
- ✅ Mobile-only restriction (width < 768px)
- ✅ Camera scanner (mobile web)

---

## 🚀 Deployment Status

### Web (Vercel)

**Status**: ✅ READY
**Requirements**:

- Flutter web build
- No additional configuration needed
- Mobile-only restriction already implemented

**Deploy Command**:

```bash
flutter build web --release
```

### Android

**Status**: ⚠️ NEEDS TESTING
**Requirements**:

- Test on actual Android device
- Verify gallery integration
- Check permissions

**Build Command**:

```bash
flutter build apk --release
```

---

## 📝 Known Issues & Solutions

### Issue 1: Gallery Integration Not Working

**Symptoms**: QR saved but not visible in gallery
**Solutions**:

1. Device restart karo
2. Gallery app refresh karo
3. File manager se check karo: `/storage/emulated/0/DCIM/GenQR/`
4. Android 10+ pe MediaStore API use karna padega (future update)

### Issue 2: White Background Not Visible

**Symptoms**: Saved QR transparent background ke saath hai
**Solutions**:

- Code already fixed hai
- Test karo aur verify karo
- Agar issue hai to debug print check karo

### Issue 3: Theme Color Not Applied

**Symptoms**: Saved QR black color mein hai
**Solutions**:

- Code already fixed hai
- Theme color parameter properly pass ho raha hai
- Test karo different colors ke saath

---

## 🎯 Next Steps

1. **Android Device Testing** (PRIORITY)
   - QR save with white background
   - Theme color application
   - Gallery integration
   - Padding verification

2. **Web Deployment**
   - Build for production
   - Deploy to Vercel
   - Test on mobile browsers

3. **iOS Testing** (if needed)
   - QR save functionality
   - Camera permissions
   - Gallery integration

---

## 📞 Contact

Agar koi issue aaye to:

1. Debug prints check karo console mein
2. Error messages note karo
3. Screenshots lo
4. Mujhe batao

---

**Last Updated**: January 29, 2026
**Version**: 1.0.0
**Status**: Ready for Testing ✅

# AppButton + Splash/Login Redesign + ZoomDrawer + Widget Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a unified AppButton widget, redesign splash and login screens, implement ZoomDrawer, delete logo.jpg, and extract all inline private widgets into separate files.

**Architecture:** AppButton replaces all `CustomElevatedButton`, `ElevatedButton`, and `TextButton` usages with a three-variant (elevated/outlined/text) component. ZoomDrawer replaces the standard Flutter Drawer with a slide-and-scale pattern from the visitors project. All private widget classes and function-widgets get extracted to their own files.

**Tech Stack:** Flutter 3.10+, flutter_bloc, flutter_screenutil, go_router, GetIt. Teal-green `#384c4b` palette, Beiruti font.

---

## File Map

### New files
| File | Responsibility |
|------|---------------|
| `lib/core/widgets/buttons/app_button.dart` | Unified button with elevated/outlined/text variants |
| `lib/core/widgets/buttons/buttons_widgets.dart` | Barrel export for buttons/ |
| `lib/core/widgets/navigation/zoom_drawer.dart` | ZoomDrawerController + ZoomDrawer widget |
| `lib/features/settings/presentation/widgets/common/drawer_nav_tile.dart` | Extracted nav tile from settings_drawer |
| `lib/features/settings/presentation/widgets/common/settings_zoom_drawer_content.dart` | ZoomDrawer menu content for settings |
| `lib/features/settings/presentation/widgets/design/album_url_list.dart` | Extracted _AlbumUrlList from background_settings_section |
| `lib/features/settings/presentation/sections/widgets/announcement_editor_sheet.dart` | Extracted _AnnouncementEditorSheet |
| `lib/features/settings/presentation/sections/widgets/mosque_text_editor_sheet.dart` | Extracted _MosqueTextEditorSheet |
| `lib/features/settings/presentation/sections/widgets/alert_card.dart` | Extracted _AlertCard |
| `lib/features/settings/presentation/sections/widgets/alert_edit_dialog.dart` | Extracted _AlertEditDialog |
| `lib/features/settings/presentation/sections/widgets/content_panel.dart` | Extracted _ContentPanel |

### Modified files
| File | Change |
|------|--------|
| `lib/core/widgets/forms/forms_widgets.dart` | Remove `custom_elevated_button.dart` export |
| `lib/core/widgets/navigation/navigation_widgets.dart` | Add `zoom_drawer.dart` export |
| `lib/features/auth/presentation/login_screen.dart` | Full redesign: use logo.png, AppButton, remove _BrandMark |
| `lib/features/splash/presentation/splash_screen.dart` | Redesign with logo.png centerpiece |
| `lib/features/settings/presentation/settings_page.dart` | Switch from Scaffold drawer to ZoomDrawer |
| `lib/features/settings/presentation/widgets/common/common_widgets.dart` | Update exports |
| `lib/features/settings/presentation/widgets/common/settings_drawer.dart` | Delete (replaced by zoom drawer content) |
| `lib/features/settings/presentation/widgets/design/background_settings_section.dart` | Remove _AlbumUrlList, import extracted |
| `lib/features/settings/presentation/sections/announcement_section.dart` | Remove _AnnouncementEditorSheet, import extracted |
| `lib/features/settings/presentation/sections/mosque_text_list_section.dart` | Remove _MosqueTextEditorSheet, import extracted |
| `lib/features/settings/presentation/sections/alerts_section.dart` | Remove _AlertCard + _AlertEditDialog, import extracted |
| `lib/features/settings/presentation/sections/religious_content_section.dart` | Remove _ContentPanel, import extracted |
| `lib/features/auth/presentation/registration_screen.dart` | Replace ElevatedButton/TextButton with AppButton |
| `lib/features/settings/presentation/widgets/profile/profile_phone_card.dart` | Replace ElevatedButton with AppButton |
| `lib/features/settings/presentation/widgets/profile/profile_action_card.dart` | Replace ElevatedButton with AppButton |
| `lib/core/widgets/feedback/error_state_widget.dart` | Replace ElevatedButton with AppButton |
| `lib/features/settings/presentation/sections/general_section.dart` | Replace ElevatedButton with AppButton |
| `lib/features/settings/presentation/sections/prayer_iqama_section.dart` | Replace ElevatedButton with AppButton |
| `lib/features/settings/presentation/sections/iqama_section.dart` | Replace ElevatedButton with AppButton |

### Deleted files
| File | Reason |
|------|--------|
| `lib/core/widgets/forms/custom_elevated_button.dart` | Replaced by AppButton |
| `lib/features/settings/presentation/widgets/common/settings_drawer.dart` | Replaced by zoom drawer |
| `assets/logo.jpg` | Replaced by logo.png |

---

### Task 1: Create AppButton Widget

**Files:**
- Create: `lib/core/widgets/buttons/app_button.dart`
- Create: `lib/core/widgets/buttons/buttons_widgets.dart`

- [ ] **Step 1: Create buttons directory and barrel file**

Create `lib/core/widgets/buttons/buttons_widgets.dart`:
```dart
export 'app_button.dart';
```

- [ ] **Step 2: Create AppButton widget**

Create `lib/core/widgets/buttons/app_button.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';

enum _AppButtonVariant { elevated, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool disabled;
  final IconData? icon;
  final IconData? leadingIcon;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final LinearGradient? gradient;
  final bool expand;
  final bool useShadow;
  final _AppButtonVariant _variant;

  const AppButton.elevated({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.leadingIcon,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.expand = true,
    this.useShadow = true,
  }) : _variant = _AppButtonVariant.elevated;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.leadingIcon,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.expand = true,
    this.useShadow = false,
  }) : _variant = _AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.leadingIcon,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.expand = false,
    this.useShadow = false,
  }) : _variant = _AppButtonVariant.text;

  bool get _isDisabled => disabled || isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius?.r ?? 14.r);
    final h = height ?? context.responsive(48.h, tablet: 52.h, desktop: 40.h);
    final fgColor = foregroundColor ?? _defaultForeground;
    final fSize = fontSize ?? context.adaptiveFont(14.sp);

    Widget content = isLoading
        ? SizedBox(
            width: context.isDesktop ? 24.0 : 24.r,
            height: context.isDesktop ? 24.0 : 24.r,
            child: CircularProgressIndicator(
              color: _variant == _AppButtonVariant.elevated
                  ? Colors.white
                  : AppColors.primary,
              strokeWidth: 3,
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: _isDisabled ? AppColors.mutedForeground : fgColor, size: context.adaptiveIcon(16.sp)),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fSize,
                    fontWeight: FontWeight.bold,
                    color: _isDisabled ? AppColors.mutedForeground : fgColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: _isDisabled ? AppColors.mutedForeground : fgColor, size: context.adaptiveIcon(16.sp)),
              ],
            ],
          );

    switch (_variant) {
      case _AppButtonVariant.elevated:
        return _buildElevated(context, content, radius, h);
      case _AppButtonVariant.outlined:
        return _buildOutlined(context, content, radius, h);
      case _AppButtonVariant.text:
        return _buildText(context, content, fgColor, fSize);
    }
  }

  Widget _buildElevated(BuildContext context, Widget content, BorderRadius radius, double h) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? 120.0 : 0),
      child: Container(
        width: expand ? (width ?? double.infinity) : width,
        height: h,
        decoration: BoxDecoration(
          gradient: _isDisabled ? null : (gradient ?? AppColors.primaryGradient),
          color: _isDisabled ? AppColors.muted : (gradient != null ? null : null),
          borderRadius: radius,
          boxShadow: (_isDisabled || !useShadow)
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryStart.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isDisabled ? null : onPressed,
            borderRadius: radius,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlined(BuildContext context, Widget content, BorderRadius radius, double h) {
    final borderColor = _isDisabled ? AppColors.muted : (foregroundColor ?? AppColors.primary);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? 120.0 : 0),
      child: Container(
        width: expand ? (width ?? double.infinity) : width,
        height: h,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: radius,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isDisabled ? null : onPressed,
            borderRadius: radius,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, Widget content, Color fgColor, double fSize) {
    return TextButton(
      onPressed: _isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: fgColor,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: isLoading
          ? SizedBox(
              width: 20.r,
              height: 20.r,
              child: CircularProgressIndicator(color: fgColor, strokeWidth: 2),
            )
          : content,
    );
  }

  Color get _defaultForeground {
    switch (_variant) {
      case _AppButtonVariant.elevated:
        return Colors.white;
      case _AppButtonVariant.outlined:
        return AppColors.primary;
      case _AppButtonVariant.text:
        return AppColors.primaryDark;
    }
  }
}
```

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add lib/core/widgets/buttons/
git commit -m "feat: create AppButton with elevated/outlined/text variants"
```

---

### Task 2: Migrate All Button Usages to AppButton + Delete CustomElevatedButton

**Files:**
- Modify: `lib/features/auth/presentation/login_screen.dart` (line 242 — CustomElevatedButton → AppButton.elevated, line 277 — TextButton → AppButton.text)
- Modify: `lib/features/auth/presentation/registration_screen.dart` (line 313 — ElevatedButton → AppButton.elevated, line 333 — TextButton → AppButton.text, line 357 — TextButton → AppButton.text)
- Modify: `lib/features/settings/presentation/widgets/profile/profile_phone_card.dart` (line 87 — ElevatedButton → AppButton.elevated)
- Modify: `lib/features/settings/presentation/widgets/profile/profile_action_card.dart` (line 73 — ElevatedButton → AppButton.elevated)
- Modify: `lib/core/widgets/feedback/error_state_widget.dart` (lines 116, 205 — ElevatedButton → AppButton.elevated)
- Modify: `lib/features/settings/presentation/sections/general_section.dart` (ElevatedButton → AppButton.elevated)
- Modify: `lib/features/settings/presentation/sections/prayer_iqama_section.dart` (line 241 — ElevatedButton → AppButton.elevated)
- Modify: `lib/features/settings/presentation/sections/iqama_section.dart` (line 80 — ElevatedButton → AppButton.elevated)
- Modify: `lib/core/widgets/forms/forms_widgets.dart` (remove custom_elevated_button export)
- Delete: `lib/core/widgets/forms/custom_elevated_button.dart`

- [ ] **Step 1: Replace CustomElevatedButton in login_screen.dart**

In `login_screen.dart`, replace the import:
```dart
// Remove:
import '../../../core/widgets/forms/custom_elevated_button.dart';
// Add:
import '../../../core/widgets/buttons/app_button.dart';
```

Replace the CustomElevatedButton at line 242 with:
```dart
AppButton.elevated(
  label: s.login_button,
  isLoading: loading,
  disabled: loading,
  onPressed: _submit,
  icon: Icons.login_rounded,
),
```

Replace the TextButton at line 277 with:
```dart
return AppButton.text(
  label: s.register_link,
  onPressed: () => context.push(Routes.registrationPath),
  foregroundColor: AppColors.primaryDark,
  fontSize: context.adaptiveFont(14.sp),
);
```

- [ ] **Step 2: Replace buttons in registration_screen.dart**

Add import:
```dart
import '../../../core/widgets/buttons/app_button.dart';
```

Replace `_buildAction` method's ElevatedButton (around line 313) with:
```dart
return AppButton.elevated(
  label: s.register_button,
  isLoading: state.status == RegistrationStatus.loading,
  disabled: state.status == RegistrationStatus.loading,
  onPressed: _submit,
);
```

Replace `_buildLoginLink` method's TextButton (around line 333) with:
```dart
return AppButton.text(
  label: s.login_link,
  onPressed: () => Navigator.of(context).pop(),
  foregroundColor: theme.primaryColor,
);
```

Keep the AlertDialog TextButton at line 357 as-is (it's inside a dialog, not a form CTA).

- [ ] **Step 3: Replace buttons in profile_phone_card.dart and profile_action_card.dart**

In both files, add import:
```dart
import '../../../../../core/widgets/buttons/app_button.dart';
```

In `profile_phone_card.dart`, replace the ElevatedButton block (line 87) with:
```dart
child: AppButton.elevated(
  label: s.profile_save_changes,
  isLoading: isLoading,
  disabled: isLoading,
  onPressed: () {
    context.read<ProfileBloc>().add(
      UpdatePhoneRequested(widget.phoneController.text),
    );
  },
),
```
Remove the wrapping `SizedBox(width: double.infinity, height: 54, ...)` — AppButton handles its own sizing.

In `profile_action_card.dart`, replace the ElevatedButton block (line 73) similarly:
```dart
child: AppButton.elevated(
  label: s.profile_save_changes,
  isLoading: isLoading,
  disabled: isLoading,
  onPressed: () {
    context.read<ProfileBloc>().add(
      UpdatePasswordRequested(
        newPassword: widget.passwordController.text,
      ),
    );
  },
),
```

- [ ] **Step 4: Replace buttons in error_state_widget.dart**

Add import:
```dart
import '../buttons/app_button.dart';
```

Replace both `ElevatedButton` instances with:
```dart
AppButton.elevated(
  label: retryLabel ?? s.retry,
  onPressed: onRetry,
  expand: false,
),
```

- [ ] **Step 5: Replace buttons in settings section save buttons**

In `general_section.dart`, `prayer_iqama_section.dart`, and `iqama_section.dart`, add import:
```dart
import '../../../../core/widgets/buttons/app_button.dart';
```

Replace each `ElevatedButton(...)` save button with:
```dart
AppButton.elevated(
  label: s.<appropriate_save_label>,
  onPressed: () { context.read<SettingsBloc>().add(const <SaveEvent>()); },
  icon: Icons.save_rounded,
),
```

Use the exact save label each section currently uses (e.g. `s.save_general_settings`, `s.save_iqama_settings`).

- [ ] **Step 6: Delete CustomElevatedButton and update barrel**

Delete `lib/core/widgets/forms/custom_elevated_button.dart`.

Edit `lib/core/widgets/forms/forms_widgets.dart` — remove the line:
```dart
export 'custom_elevated_button.dart';
```

- [ ] **Step 7: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor: migrate all buttons to AppButton, delete CustomElevatedButton"
```

---

### Task 3: Delete logo.jpg + Verify logo.png Usage

**Files:**
- Delete: `assets/logo.jpg`
- Verify: `pubspec.yaml` (flutter_launcher_icons config)

- [ ] **Step 1: Delete logo.jpg**

```bash
rm assets/logo.jpg
```

- [ ] **Step 2: Verify no code references logo.jpg**

Run: `grep -r "logo.jpg" lib/ assets/ pubspec.yaml`
Expected: No results (the spec doc references are fine).

- [ ] **Step 3: Verify flutter_launcher_icons config**

Check that `pubspec.yaml` has:
```yaml
flutter_launcher_icons:
  image_path: "assets/logo.png"
```

If it references `logo.jpg`, change to `logo.png`.

- [ ] **Step 4: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: delete logo.jpg, standardize on logo.png"
```

---

### Task 4: Redesign Splash Screen

**Files:**
- Modify: `lib/features/splash/presentation/splash_screen.dart`

- [ ] **Step 1: Rewrite splash_screen.dart**

Replace the full content of `splash_screen.dart` with a new design that:
- Uses `logo.png` as the centerpiece inside a white rounded container with shadow (similar to `LogoRectangle` but custom-sized for splash)
- Background: soft gradient from `Color(0xFFF8FAFC)` to `Color(0xFFF0FDFA)` with two subtle teal-tinted circular blobs for depth
- Animated entrance: `AnimatedScale` (0.7→1.0, elasticOut 1200ms) + `AnimatedOpacity` (0→1, 800ms) on the logo
- App tagline below logo: `s.splash_app_tagline` with `AnimatedOpacity` (delayed 200ms)
- Subtle loading spinner at bottom appearing after 800ms
- Same `BlocListener<SplashRoutingBloc>` routing logic

Full replacement code for `splash_screen.dart`:
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/splash/splash_destination.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../bloc/splash_routing/splash_routing_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;
  bool _showTagline = false;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showLogo = true);
    });
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showTagline = true);
    });
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showSpinner = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocListener<SplashRoutingBloc, SplashRoutingState>(
      listener: (context, state) async {
        if (state is SplashLoaded) {
          await Future.delayed(const Duration(milliseconds: 2000));
          if (!context.mounted) return;
          switch (state.destination) {
            case SplashDestination.login:
              context.go(Routes.loginPath);
            case SplashDestination.mobileSettings:
              context.go(Routes.settingsPath);
            case SplashDestination.screenDisplay:
              context.go(Routes.displayPath);
          }
        } else if (state is SplashError) {
          context.read<SplashRoutingBloc>().add(SplashCheckStatus());
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8FAFC), Colors.white, Color(0xFFF0FDFA)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative blob top-right
              Positioned(
                top: -120.h,
                right: -100.w,
                child: Container(
                  width: 400.w,
                  height: 400.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Decorative blob bottom-left
              Positioned(
                bottom: -80.h,
                left: -80.w,
                child: Container(
                  width: 300.w,
                  height: 300.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedScale(
                    scale: _showLogo ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    child: AnimatedOpacity(
                      opacity: _showLogo ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        width: context.responsive(160.w, tablet: 180.w, desktop: 200.w),
                        padding: EdgeInsets.all(context.responsive(16.w, tablet: 20.w)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  // Tagline
                  AnimatedOpacity(
                    opacity: _showTagline ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      s.splash_app_tagline,
                      style: TextStyle(
                        fontSize: context.adaptiveFont(20.sp),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  // Loading spinner
                  AnimatedOpacity(
                    opacity: _showSpinner ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      width: 28.r,
                      height: 28.r,
                      child: CircularProgressIndicator(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/splash/presentation/splash_screen.dart
git commit -m "feat: redesign splash screen with logo.png centerpiece and staggered animations"
```

---

### Task 5: Redesign Login Screen

**Files:**
- Modify: `lib/features/auth/presentation/login_screen.dart`

- [ ] **Step 1: Rewrite login_screen.dart**

Replace the entire file. Key changes from the current version:
- Replace `_BrandMark` (circular gradient with mosque icon) with `logo.png` inside a white rounded container
- Use `AppButton.elevated` for login button (already done in Task 2, but this task rewrites the whole file)
- Use `AppButton.text` for register link
- Keep: form validation logic, BLoC integration, SystemUiOverlayStyle, CustomTextField usage
- Design: clean white card, teal accents, soft shadows, `logo.png` as hero

Full replacement code for `login_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/styles/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../../../core/widgets/forms/custom_text_field.dart';
import '../../../data/repositories/interfaces/app_settings_repository_interface.dart';
import '../bloc/login/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode(debugLabel: 'login_email');
  final _passwordFocusNode = FocusNode(debugLabel: 'login_password');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, S s) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return s.validation_email_required;
    if (!RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
      return s.validation_email_invalid;
    }
    return null;
  }

  String? _validatePassword(String? value, S s) {
    final v = value ?? '';
    if (v.isEmpty) return s.validation_password_required;
    if (v.length < 6) return s.validation_password_short;
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bloc = context.read<LoginBloc>();
    bloc.add(UpdateEmail(_emailController.text.trim()));
    bloc.add(UpdatePassword(_passwordController.text));
    bloc.add(SendLoginRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.loginBackgroundGradient,
          ),
          child: Stack(
            children: [
              // Top accent bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4.h,
                  decoration: const BoxDecoration(
                    gradient: AppColors.accentGradient,
                  ),
                ),
              ),
              SafeArea(
                child: BlocConsumer<LoginBloc, LoginState>(
                  listenWhen: (prev, curr) =>
                      curr is LoginSuccess || curr is LoginFailure,
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      context.go(Routes.settingsPath);
                    } else if (state is LoginFailure) {
                      UnifiedSnackbar.error(context, message: state.error);
                    }
                  },
                  builder: (context, state) {
                    final loading = state is LoginLoading;
                    final s = S.of(context);

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsive(24.w, tablet: 48.w),
                        vertical: 12.h,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height -
                              MediaQuery.paddingOf(context).vertical -
                              24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 24.h),
                            // Bismillah
                            Text(
                              s.bismillah,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.adaptiveFont(13.sp),
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryDark.withValues(alpha: 0.85),
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Logo
                            Center(
                              child: Container(
                                width: context.responsive(120.w, tablet: 140.w),
                                padding: EdgeInsets.all(context.responsive(14.w, tablet: 18.w)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.10),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Title
                            Text(
                              s.login_title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.adaptiveFont(24.sp),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Subtitle
                            Text(
                              s.login_subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.adaptiveFont(14.sp),
                                color: AppColors.secondaryText,
                              ),
                            ),
                            SizedBox(height: 28.h),
                            // Form card
                            Container(
                              padding: EdgeInsets.all(
                                context.responsive(22.w, tablet: 28.w),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22.r),
                                border: Border.all(
                                  color: AppColors.primaryWhisper.withValues(alpha: 0.9),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryDark.withValues(alpha: 0.07),
                                    blurRadius: 28,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    CustomTextField(
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      nextFocusNode: _passwordFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      label: s.email_label,
                                      hintText: s.email_hint,
                                      labelColor: AppColors.primaryText,
                                      textColor: AppColors.primaryText,
                                      focusBorderColor: AppColors.primary,
                                      fillColor: AppColors.creamWhite,
                                      enabled: !loading,
                                      onChanged: (v) => context.read<LoginBloc>().add(UpdateEmail(v)),
                                      validator: (v) => _validateEmail(v, s),
                                      prefixIcon: Icon(
                                        Icons.alternate_email_rounded,
                                        color: AppColors.primaryDark.withValues(alpha: 0.85),
                                        size: context.adaptiveIcon(22.sp),
                                      ),
                                    ),
                                    SizedBox(height: 18.h),
                                    CustomTextField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      isPassword: true,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      label: s.password_label,
                                      hintText: s.password_hint,
                                      labelColor: AppColors.primaryText,
                                      textColor: AppColors.primaryText,
                                      focusBorderColor: AppColors.primary,
                                      fillColor: AppColors.creamWhite,
                                      enabled: !loading,
                                      onChanged: (v) => context.read<LoginBloc>().add(UpdatePassword(v)),
                                      validator: (v) => _validatePassword(v, s),
                                      onFieldSubmitted: (_) => _submit(),
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppColors.primaryDark.withValues(alpha: 0.85),
                                        size: context.adaptiveIcon(22.sp),
                                      ),
                                    ),
                                    SizedBox(height: 28.h),
                                    AppButton.elevated(
                                      label: s.login_button,
                                      isLoading: loading,
                                      disabled: loading,
                                      onPressed: _submit,
                                      icon: Icons.login_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Tawakkul quote
                            Text(
                              s.tawakkul_quote,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.adaptiveFont(12.sp),
                                height: 1.7,
                                color: AppColors.secondaryText.withValues(alpha: 0.85),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Register link
                            FutureBuilder(
                              future: sl<IAppSettingsRepository>().getAppSettings(),
                              builder: (context, snapshot) {
                                final canRegister = snapshot.data?.allowRegistration ?? true;
                                if (!canRegister) return const SizedBox.shrink();
                                return AppButton.text(
                                  label: s.register_link,
                                  onPressed: () => context.push(Routes.registrationPath),
                                  foregroundColor: AppColors.primaryDark,
                                  fontSize: context.adaptiveFont(14.sp),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/login_screen.dart
git commit -m "feat: redesign login screen with logo.png and AppButton"
```

---

### Task 6: Create ZoomDrawer Widget

**Files:**
- Create: `lib/core/widgets/navigation/zoom_drawer.dart`
- Modify: `lib/core/widgets/navigation/navigation_widgets.dart`

- [ ] **Step 1: Create zoom_drawer.dart**

Create `lib/core/widgets/navigation/zoom_drawer.dart`:
```dart
import 'package:flutter/material.dart';

/// Controller for [ZoomDrawer]. Manages open/close state.
class ZoomDrawerController extends ChangeNotifier {
  bool _isOpen = false;
  bool get isOpen => _isOpen;

  void toggle() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }
}

/// A slide-and-scale drawer. The [mainScreen] scales down and slides aside
/// to reveal the [menuScreen] underneath.
class ZoomDrawer extends StatefulWidget {
  final ZoomDrawerController controller;
  final Widget menuScreen;
  final Widget mainScreen;
  final double scale;
  final double slideWidth;
  final double borderRadius;
  final Duration duration;

  const ZoomDrawer({
    super.key,
    required this.controller,
    required this.menuScreen,
    required this.mainScreen,
    this.scale = 0.85,
    this.slideWidth = 265.0,
    this.borderRadius = 24.0,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<ZoomDrawer> createState() => _ZoomDrawerState();
}

class _ZoomDrawerState extends State<ZoomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _radiusAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _setupAnimations();
    widget.controller.addListener(_onControllerChanged);
  }

  void _setupAnimations() {
    final curve = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: widget.scale).animate(curve);
    _slideAnim = Tween<double>(begin: 0.0, end: widget.slideWidth).animate(curve);
    _radiusAnim = Tween<double>(begin: 0.0, end: widget.borderRadius).animate(curve);
  }

  @override
  void didUpdateWidget(covariant ZoomDrawer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    if (old.duration != widget.duration) {
      _animController.duration = widget.duration;
    }
    if (old.scale != widget.scale || old.slideWidth != widget.slideWidth) {
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller.isOpen) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final directionMultiplier = isRTL ? -1.0 : 1.0;

    return Stack(
      children: [
        // Menu layer
        widget.menuScreen,
        // Main screen layer
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final slide = _slideAnim.value * directionMultiplier;
            final scale = _scaleAnim.value;
            final radius = _radiusAnim.value;

            return Transform(
              transform: Matrix4.identity()
                ..translate(slide)
                ..scale(scale),
              alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Stack(
                  children: [
                    child!,
                    // Tap overlay to close when open
                    if (widget.controller.isOpen)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: widget.controller.close,
                          behavior: HitTestBehavior.opaque,
                          child: Container(color: Colors.black.withValues(alpha: 0.15)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          child: widget.mainScreen,
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Update navigation barrel**

Edit `lib/core/widgets/navigation/navigation_widgets.dart`:
```dart
export 'custom_back_button.dart';
export 'zoom_drawer.dart';
```

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add lib/core/widgets/navigation/
git commit -m "feat: create ZoomDrawer widget with slide-and-scale animation"
```

---

### Task 7: Create DrawerNavTile Widget + SettingsZoomDrawer Content

**Files:**
- Create: `lib/features/settings/presentation/widgets/common/drawer_nav_tile.dart`
- Create: `lib/features/settings/presentation/widgets/common/settings_zoom_drawer_content.dart`

- [ ] **Step 1: Create DrawerNavTile**

Create `lib/features/settings/presentation/widgets/common/drawer_nav_tile.dart`:
```dart
import 'package:flutter/material.dart';

/// A single navigation tile for the settings ZoomDrawer.
class DrawerNavTile extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DrawerNavTile({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create SettingsZoomDrawerContent**

Create `lib/features/settings/presentation/widgets/common/settings_zoom_drawer_content.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/l10n/generated/l10n.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/utils/version_helper.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../data/repositories/interfaces/app_settings_repository_interface.dart';
import 'drawer_nav_tile.dart';

/// Deep teal drawer background.
const Color _kDrawerBackground = Color(0xFF1A2F2E);

/// Menu content for the settings ZoomDrawer.
class SettingsZoomDrawerContent extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectSection;
  final VoidCallback onSignOut;
  final bool isOpen;

  const SettingsZoomDrawerContent({
    super.key,
    required this.selectedIndex,
    required this.onSelectSection,
    required this.onSignOut,
    this.isOpen = false,
  });

  @override
  State<SettingsZoomDrawerContent> createState() =>
      _SettingsZoomDrawerContentState();
}

class _SettingsZoomDrawerContentState extends State<SettingsZoomDrawerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(covariant SettingsZoomDrawerContent old) {
    super.didUpdateWidget(old);
    if (widget.isOpen && !old.isOpen) {
      _staggerController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Widget _animatedItem({required int index, required Widget child}) {
    final totalItems = 12; // 10 nav + 2 footer
    final start = (index * 0.05).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    final navItems = <({int index, IconData icon, String label})>[
      (index: 0, icon: Icons.mosque_outlined, label: s.tab_general),
      (index: 1, icon: Icons.access_time_outlined, label: s.tab_prayer_iqama),
      (index: 2, icon: Icons.menu_book_rounded, label: s.tab_religious_content),
      (index: 3, icon: Icons.palette_outlined, label: s.tab_design),
      (index: 4, icon: Icons.photo_library_outlined, label: s.tab_photo_studio),
      (index: 5, icon: Icons.campaign_outlined, label: s.tab_announcements),
      (index: 6, icon: Icons.emergency_share_outlined, label: s.tab_alerts),
      (index: 7, icon: Icons.person_outline_rounded, label: s.tab_profile),
      (index: 8, icon: Icons.info_outline_rounded, label: s.tab_about),
      (index: 9, icon: Icons.system_update_rounded, label: s.tab_update),
    ];

    return Container(
      color: _kDrawerBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: _animatedItem(
                index: 0,
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.mosque_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.login_subtitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.settings_drawer_tagline,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.08),
                height: 1,
              ),
            ),
            // Section label
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
              child: Text(
                s.settings_navigate_sections,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.35),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Nav items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: navItems.length,
                itemBuilder: (context, i) {
                  final item = navItems[i];
                  return _animatedItem(
                    index: i + 1,
                    child: DrawerNavTile(
                      index: item.index,
                      selectedIndex: widget.selectedIndex,
                      icon: item.icon,
                      label: item.label,
                      onTap: () => widget.onSelectSection(item.index),
                    ),
                  );
                },
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.08),
                height: 1,
              ),
            ),
            _animatedItem(
              index: 11,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(
                  Icons.support_agent_rounded,
                  color: Colors.green.shade400,
                  size: 24,
                ),
                title: Text(
                  s.contact_developers,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade400,
                  ),
                ),
                onTap: () async {
                  final appSettings = await sl<IAppSettingsRepository>().getAppSettings();
                  final phone = appSettings?.supportPhone ?? '';
                  if (phone.isNotEmpty) {
                    final uri = Uri.parse("https://wa.me/$phone");
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
              ),
            ),
            _animatedItem(
              index: 12,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF5350),
                  size: 24,
                ),
                title: const Text(
                  '',
                  style: TextStyle(
                    color: Color(0xFFEF5350),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: widget.onSignOut,
              ),
            ),
            // Version
            FutureBuilder<String>(
              future: VersionHelper.getCurrentVersion(),
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Center(
                    child: Text(
                      'V ${snapshot.data ?? '...'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

Note: In the actual implementation, the sign-out ListTile must use `s.sign_out` for the title text (not empty or const). The `s` variable is available in `build()` from the parent — the code above shows the structure; the implementer must wire `s.sign_out` as the title Text and remove `const` from both the Icon and Text widgets in that ListTile.

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/presentation/widgets/common/drawer_nav_tile.dart lib/features/settings/presentation/widgets/common/settings_zoom_drawer_content.dart
git commit -m "feat: create DrawerNavTile and SettingsZoomDrawerContent widgets"
```

---

### Task 8: Integrate ZoomDrawer into SettingsPage

**Files:**
- Modify: `lib/features/settings/presentation/settings_page.dart`
- Modify: `lib/features/settings/presentation/widgets/common/common_widgets.dart`
- Delete: `lib/features/settings/presentation/widgets/common/settings_drawer.dart`

- [ ] **Step 1: Rewrite settings_page.dart to use ZoomDrawer**

The key changes:
- Add `ZoomDrawerController` as state field
- Replace `Scaffold(drawer: SettingsDrawer(...))` with `ZoomDrawer(controller: ..., menuScreen: ..., mainScreen: Scaffold(...))`
- Replace the automatic hamburger menu with a manual `IconButton` in the AppBar `leading` that calls `controller.toggle()`
- Pass `isOpen` to the drawer content for stagger animation triggering
- Remove the `SettingsDrawer` import

Full `settings_page.dart` rewrite:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/app_mode.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/widgets/navigation/zoom_drawer.dart';
import '../../../data/repositories/interfaces/auth_repository_interface.dart';
import '../../../data/repositories/interfaces/mosque_repository_interface.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/feedback/unified_snackbar.dart';
import '../bloc/settings/settings_bloc.dart';
import 'widgets/common/settings_zoom_drawer_content.dart';

import 'sections/general_section.dart';
import 'sections/prayer_iqama_section.dart';
import 'sections/religious_content_section.dart';
import 'sections/design_section.dart';
import 'sections/photo_studio_section.dart';
import 'sections/announcement_section.dart';
import 'sections/alerts_section.dart';
import 'sections/profile_section.dart';
import 'sections/about_section.dart';
import 'sections/update_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(mosqueRepository: sl<IMosqueRepository>())..add(const LoadSettings()),
      child: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _sectionIndex = 0;
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _signOut() async {
    _drawerController.close();
    await sl<IAuthRepository>().logout();
    if (mounted) {
      context.go(Routes.splashPath);
    }
  }

  String _titleForIndex(S s, int i) {
    switch (i) {
      case 0: return s.tab_general;
      case 1: return s.tab_prayer_iqama;
      case 2: return s.tab_religious_content;
      case 3: return s.tab_design;
      case 4: return s.tab_photo_studio;
      case 5: return s.tab_announcements;
      case 6: return s.tab_alerts;
      case 7: return s.tab_profile;
      case 8: return s.tab_about;
      case 9: return s.tab_update;
      default: return s.settings_title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListenableBuilder(
      listenable: _drawerController,
      builder: (context, _) {
        return ZoomDrawer(
          controller: _drawerController,
          menuScreen: SettingsZoomDrawerContent(
            selectedIndex: _sectionIndex,
            isOpen: _drawerController.isOpen,
            onSelectSection: (i) {
              _drawerController.close();
              setState(() => _sectionIndex = i);
            },
            onSignOut: _signOut,
          ),
          mainScreen: Scaffold(
            appBar: AppBar(
              toolbarHeight: 72,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                iconSize: 28,
                onPressed: _drawerController.toggle,
              ),
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
              title: Text(_titleForIndex(s, _sectionIndex)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  iconSize: 28,
                  tooltip: s.refresh,
                  onPressed: () {
                    context.read<SettingsBloc>().add(const LoadSettings());
                  },
                ),
                PopupMenuButton<String>(
                  iconSize: 28,
                  onSelected: (value) async {
                    if (value == 'smart_screen') {
                      await sl<IAuthRepository>().setAppModeOverride(AppMode.deviceDisplay);
                      if (!context.mounted) return;
                      context.go(Routes.displayPath);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'smart_screen',
                        child: Text(s.enable_smart_screen),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: BlocConsumer<SettingsBloc, SettingsState>(
              listenWhen: (prev, curr) {
                if (curr.isSaving && !prev.isSaving) return true;
                if (curr.error != null && prev.error == null) return true;
                if (!curr.isSaving && prev.isSaving && curr.error == null) return true;
                return false;
              },
              listener: (context, state) {
                if (state.isSaving) {
                  UnifiedSnackbar.info(context, message: S.of(context).saving);
                } else if (state.error != null) {
                  UnifiedSnackbar.error(context, message: state.error!);
                } else {
                  UnifiedSnackbar.hide(context);
                  UnifiedSnackbar.success(context, message: S.of(context).saved_successfully);
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mosque = state.request.mosque;
                if (state.error != null && mosque == null) {
                  return Center(child: Text(state.error!));
                }

                if (mosque == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return IndexedStack(
                  index: _sectionIndex,
                  sizing: StackFit.expand,
                  children: [
                    GeneralSection(mosque: mosque),
                    PrayerIqamaSection(mosque: mosque),
                    ReligiousContentSection(mosque: mosque),
                    const DesignSection(),
                    PhotoStudioSection(mosque: mosque),
                    AnnouncementSection(mosque: mosque),
                    AlertsSection(mosque: mosque),
                    const ProfileSection(),
                    const AboutSection(),
                    const UpdateSection(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Delete old settings_drawer.dart**

Delete: `lib/features/settings/presentation/widgets/common/settings_drawer.dart`

- [ ] **Step 3: Update common_widgets.dart barrel**

Replace `lib/features/settings/presentation/widgets/common/common_widgets.dart`:
```dart
export 'offset_stepper_field.dart';
export 'drawer_nav_tile.dart';
export 'settings_zoom_drawer_content.dart';
```

- [ ] **Step 4: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: integrate ZoomDrawer into settings, replace Scaffold drawer"
```

---

### Task 9: Extract Private Widgets to Separate Files

**Files:**
- Create: `lib/features/settings/presentation/widgets/design/album_url_list.dart`
- Create: `lib/features/settings/presentation/sections/widgets/announcement_editor_sheet.dart`
- Create: `lib/features/settings/presentation/sections/widgets/mosque_text_editor_sheet.dart`
- Create: `lib/features/settings/presentation/sections/widgets/alert_card.dart`
- Create: `lib/features/settings/presentation/sections/widgets/alert_edit_dialog.dart`
- Create: `lib/features/settings/presentation/sections/widgets/content_panel.dart`
- Modify: `lib/features/settings/presentation/widgets/design/background_settings_section.dart` (remove _AlbumUrlList)
- Modify: `lib/features/settings/presentation/sections/announcement_section.dart` (remove _AnnouncementEditorSheet)
- Modify: `lib/features/settings/presentation/sections/mosque_text_list_section.dart` (remove _MosqueTextEditorSheet)
- Modify: `lib/features/settings/presentation/sections/alerts_section.dart` (remove _AlertCard, _AlertEditDialog)
- Modify: `lib/features/settings/presentation/sections/religious_content_section.dart` (remove _ContentPanel)

- [ ] **Step 1: Extract _AlbumUrlList from background_settings_section.dart**

Read `background_settings_section.dart` and find the `_AlbumUrlList` class (starts around line 140). Copy it to a new file `lib/features/settings/presentation/widgets/design/album_url_list.dart`, rename to `AlbumUrlList` (public), add necessary imports. In the original file, remove the class and add an import for the new file.

- [ ] **Step 2: Extract _AnnouncementEditorSheet from announcement_section.dart**

Read `announcement_section.dart` and find `_AnnouncementEditorSheet` (starts around line 354). Copy to `lib/features/settings/presentation/sections/widgets/announcement_editor_sheet.dart`, rename to `AnnouncementEditorSheet`, add imports. Update original file.

- [ ] **Step 3: Extract _MosqueTextEditorSheet from mosque_text_list_section.dart**

Read `mosque_text_list_section.dart` and find `_MosqueTextEditorSheet` (starts around line 394). Copy to `lib/features/settings/presentation/sections/widgets/mosque_text_editor_sheet.dart`, rename to `MosqueTextEditorSheet`, add imports. Update original file.

- [ ] **Step 4: Extract _AlertCard and _AlertEditDialog from alerts_section.dart**

Read `alerts_section.dart` and find `_AlertCard` (line 75) and `_AlertEditDialog` (line 103). Copy each to their own files:
- `lib/features/settings/presentation/sections/widgets/alert_card.dart` → `AlertCard`
- `lib/features/settings/presentation/sections/widgets/alert_edit_dialog.dart` → `AlertEditDialog`

Update original file to import both.

- [ ] **Step 5: Extract _ContentPanel from religious_content_section.dart**

Read `religious_content_section.dart` and find `_ContentPanel` (line 117). Copy to `lib/features/settings/presentation/sections/widgets/content_panel.dart`, rename to `ContentPanel`, add imports. Update original file.

- [ ] **Step 6: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "refactor: extract all private widgets to separate files"
```

---

### Task 10: Final Integration Verification

**Files:** None (verification only)

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze --no-pub`
Expected: 0 errors (only pre-existing info-level warnings)

- [ ] **Step 2: Search for stale references**

Run these searches — all should return zero results:
```bash
grep -r "CustomElevatedButton" lib/
grep -r "logo\.jpg" lib/ assets/
grep -r "settings_drawer\.dart" lib/
```

- [ ] **Step 3: Verify logo.jpg is deleted**

Run: `ls assets/logo.jpg`
Expected: File not found

- [ ] **Step 4: Build debug APK**

Run: `flutter build apk --debug`
Expected: Build successful

- [ ] **Step 5: Commit verification (if any cleanup was needed)**

```bash
git add -A
git commit -m "chore: final verification — clean build, no stale references"
```

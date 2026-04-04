// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Something went wrong`
  String get error_occurred {
    return Intl.message(
      'Something went wrong',
      name: 'error_occurred',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `No data`
  String get no_data {
    return Intl.message(
      'No data',
      name: 'no_data',
      desc: '',
      args: [],
    );
  }

  /// `Please select`
  String get please_select {
    return Intl.message(
      'Please select',
      name: 'please_select',
      desc: '',
      args: [],
    );
  }

  /// `Select date`
  String get select_date {
    return Intl.message(
      'Select date',
      name: 'select_date',
      desc: '',
      args: [],
    );
  }

  /// `Upload image`
  String get upload_image {
    return Intl.message(
      'Upload image',
      name: 'upload_image',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `In the name of Allah, the Most Gracious, the Most Merciful`
  String get bismillah {
    return Intl.message(
      'In the name of Allah, the Most Gracious, the Most Merciful',
      name: 'bismillah',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get login_title {
    return Intl.message(
      'Sign in',
      name: 'login_title',
      desc: '',
      args: [],
    );
  }

  /// `Mosque management — control panel`
  String get login_subtitle {
    return Intl.message(
      'Mosque management — control panel',
      name: 'login_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email_label {
    return Intl.message(
      'Email',
      name: 'email_label',
      desc: '',
      args: [],
    );
  }

  /// `example@domain.com`
  String get email_hint {
    return Intl.message(
      'example@domain.com',
      name: 'email_hint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password_label {
    return Intl.message(
      'Password',
      name: 'password_label',
      desc: '',
      args: [],
    );
  }

  /// `••••••••`
  String get password_hint {
    return Intl.message(
      '••••••••',
      name: 'password_hint',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get login_button {
    return Intl.message(
      'Sign in',
      name: 'login_button',
      desc: '',
      args: [],
    );
  }

  /// `«And whoever relies upon Allah — then He is sufficient for him»`
  String get tawakkul_quote {
    return Intl.message(
      '«And whoever relies upon Allah — then He is sufficient for him»',
      name: 'tawakkul_quote',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get validation_email_required {
    return Intl.message(
      'Please enter your email',
      name: 'validation_email_required',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email format`
  String get validation_email_invalid {
    return Intl.message(
      'Invalid email format',
      name: 'validation_email_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get validation_password_required {
    return Intl.message(
      'Please enter your password',
      name: 'validation_password_required',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get validation_password_short {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'validation_password_short',
      desc: '',
      args: [],
    );
  }

  /// `Mosque settings`
  String get settings_title {
    return Intl.message(
      'Mosque settings',
      name: 'settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get sign_out {
    return Intl.message(
      'Sign out',
      name: 'sign_out',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Smart screen mode enabled`
  String get smart_screen_enabled {
    return Intl.message(
      'Smart screen mode enabled',
      name: 'smart_screen_enabled',
      desc: '',
      args: [],
    );
  }

  /// `Smart screen mode disabled`
  String get smart_screen_disabled {
    return Intl.message(
      'Smart screen mode disabled',
      name: 'smart_screen_disabled',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get restart_action {
    return Intl.message(
      'Restart',
      name: 'restart_action',
      desc: '',
      args: [],
    );
  }

  /// `Enable smart screen`
  String get enable_smart_screen {
    return Intl.message(
      'Enable smart screen',
      name: 'enable_smart_screen',
      desc: '',
      args: [],
    );
  }

  /// `Disable smart screen`
  String get disable_smart_screen {
    return Intl.message(
      'Disable smart screen',
      name: 'disable_smart_screen',
      desc: '',
      args: [],
    );
  }

  /// `Saving…`
  String get saving {
    return Intl.message(
      'Saving…',
      name: 'saving',
      desc: '',
      args: [],
    );
  }

  /// `Saved successfully`
  String get saved_successfully {
    return Intl.message(
      'Saved successfully',
      name: 'saved_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Use current location`
  String get use_current_location {
    return Intl.message(
      'Use current location',
      name: 'use_current_location',
      desc: '',
      args: [],
    );
  }

  /// `Coordinates updated from device location`
  String get location_updated {
    return Intl.message(
      'Coordinates updated from device location',
      name: 'location_updated',
      desc: '',
      args: [],
    );
  }

  /// `Location permission is required to set coordinates`
  String get location_permission_denied {
    return Intl.message(
      'Location permission is required to set coordinates',
      name: 'location_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Could not get current location`
  String get location_unavailable {
    return Intl.message(
      'Could not get current location',
      name: 'location_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Screen background color`
  String get design_background_color {
    return Intl.message(
      'Screen background color',
      name: 'design_background_color',
      desc: '',
      args: [],
    );
  }

  /// `Display background image`
  String get design_display_background_image {
    return Intl.message(
      'Display background image',
      name: 'design_display_background_image',
      desc: '',
      args: [],
    );
  }

  /// `Primary`
  String get design_bg_primary {
    return Intl.message(
      'Primary',
      name: 'design_bg_primary',
      desc: '',
      args: [],
    );
  }

  /// `Style 1`
  String get design_bg_style_1 {
    return Intl.message(
      'Style 1',
      name: 'design_bg_style_1',
      desc: '',
      args: [],
    );
  }

  /// `Style 2`
  String get design_bg_style_2 {
    return Intl.message(
      'Style 2',
      name: 'design_bg_style_2',
      desc: '',
      args: [],
    );
  }

  /// `Style 3`
  String get design_bg_style_3 {
    return Intl.message(
      'Style 3',
      name: 'design_bg_style_3',
      desc: '',
      args: [],
    );
  }

  /// `Style 4`
  String get design_bg_style_4 {
    return Intl.message(
      'Style 4',
      name: 'design_bg_style_4',
      desc: '',
      args: [],
    );
  }

  /// `Style 5`
  String get design_bg_style_5 {
    return Intl.message(
      'Style 5',
      name: 'design_bg_style_5',
      desc: '',
      args: [],
    );
  }

  /// `Style 6`
  String get design_bg_style_6 {
    return Intl.message(
      'Style 6',
      name: 'design_bg_style_6',
      desc: '',
      args: [],
    );
  }

  /// `Style 7`
  String get design_bg_style_7 {
    return Intl.message(
      'Style 7',
      name: 'design_bg_style_7',
      desc: '',
      args: [],
    );
  }

  /// `Style 8`
  String get design_bg_style_8 {
    return Intl.message(
      'Style 8',
      name: 'design_bg_style_8',
      desc: '',
      args: [],
    );
  }

  /// `Style 9`
  String get design_bg_style_9 {
    return Intl.message(
      'Style 9',
      name: 'design_bg_style_9',
      desc: '',
      args: [],
    );
  }

  /// `Style 10`
  String get design_bg_style_10 {
    return Intl.message(
      'Style 10',
      name: 'design_bg_style_10',
      desc: '',
      args: [],
    );
  }

  /// `Style 11`
  String get design_bg_style_11 {
    return Intl.message(
      'Style 11',
      name: 'design_bg_style_11',
      desc: '',
      args: [],
    );
  }

  /// `Logo`
  String get design_bg_brand {
    return Intl.message(
      'Logo',
      name: 'design_bg_brand',
      desc: '',
      args: [],
    );
  }

  /// `Clock and Time color`
  String get design_primary_color {
    return Intl.message(
      'Clock and Time color',
      name: 'design_primary_color',
      desc: '',
      args: [],
    );
  }

  /// `Ticker bar color`
  String get design_secondary_color {
    return Intl.message(
      'Ticker bar color',
      name: 'design_secondary_color',
      desc: '',
      args: [],
    );
  }

  /// `Active card background`
  String get design_active_card_color {
    return Intl.message(
      'Active card background',
      name: 'design_active_card_color',
      desc: '',
      args: [],
    );
  }

  /// `Active card text color`
  String get design_active_card_text_color {
    return Intl.message(
      'Active card text color',
      name: 'design_active_card_text_color',
      desc: '',
      args: [],
    );
  }

  /// `Inactive card & Hadith text color`
  String get design_inactive_card_text_color {
    return Intl.message(
      'Inactive card & Hadith text color',
      name: 'design_inactive_card_text_color',
      desc: '',
      args: [],
    );
  }

  /// `Pick color`
  String get design_pick_color {
    return Intl.message(
      'Pick color',
      name: 'design_pick_color',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get tab_general {
    return Intl.message(
      'General',
      name: 'tab_general',
      desc: '',
      args: [],
    );
  }

  /// `Design`
  String get tab_design {
    return Intl.message(
      'Design',
      name: 'tab_design',
      desc: '',
      args: [],
    );
  }

  /// `Iqama`
  String get tab_iqama {
    return Intl.message(
      'Iqama',
      name: 'tab_iqama',
      desc: '',
      args: [],
    );
  }

  /// `Hadith`
  String get tab_hadith {
    return Intl.message(
      'Hadith',
      name: 'tab_hadith',
      desc: '',
      args: [],
    );
  }

  /// `Verses`
  String get tab_verses {
    return Intl.message(
      'Verses',
      name: 'tab_verses',
      desc: '',
      args: [],
    );
  }

  /// `Supplications`
  String get tab_duas {
    return Intl.message(
      'Supplications',
      name: 'tab_duas',
      desc: '',
      args: [],
    );
  }

  /// `Dhikr`
  String get tab_adhkar {
    return Intl.message(
      'Dhikr',
      name: 'tab_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `Announcements`
  String get tab_announcements {
    return Intl.message(
      'Announcements',
      name: 'tab_announcements',
      desc: '',
      args: [],
    );
  }

  /// `Instant Alerts`
  String get tab_alerts {
    return Intl.message(
      'Instant Alerts',
      name: 'tab_alerts',
      desc: '',
      args: [],
    );
  }

  /// `Prayer times · display control`
  String get settings_drawer_tagline {
    return Intl.message(
      'Prayer times · display control',
      name: 'settings_drawer_tagline',
      desc: '',
      args: [],
    );
  }

  /// `Sections`
  String get settings_navigate_sections {
    return Intl.message(
      'Sections',
      name: 'settings_navigate_sections',
      desc: '',
      args: [],
    );
  }

  /// `New hadith`
  String get hadith_fab_add {
    return Intl.message(
      'New hadith',
      name: 'hadith_fab_add',
      desc: '',
      args: [],
    );
  }

  /// `New hadith`
  String get hadith_editor_title_new {
    return Intl.message(
      'New hadith',
      name: 'hadith_editor_title_new',
      desc: '',
      args: [],
    );
  }

  /// `Edit hadith`
  String get hadith_editor_title_edit {
    return Intl.message(
      'Edit hadith',
      name: 'hadith_editor_title_edit',
      desc: '',
      args: [],
    );
  }

  /// `Narrator`
  String get hadith_narrator {
    return Intl.message(
      'Narrator',
      name: 'hadith_narrator',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get hadith_text {
    return Intl.message(
      'Text',
      name: 'hadith_text',
      desc: '',
      args: [],
    );
  }

  /// `Source (optional)`
  String get hadith_source {
    return Intl.message(
      'Source (optional)',
      name: 'hadith_source',
      desc: '',
      args: [],
    );
  }

  /// `No hadiths yet`
  String get hadith_empty_title {
    return Intl.message(
      'No hadiths yet',
      name: 'hadith_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Add texts to rotate on the display screen.`
  String get hadith_empty_subtitle {
    return Intl.message(
      'Add texts to rotate on the display screen.',
      name: 'hadith_empty_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove hadith?`
  String get hadith_delete_title {
    return Intl.message(
      'Remove hadith?',
      name: 'hadith_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `This will remove it from the list. Save to server when you are ready.`
  String get hadith_delete_body {
    return Intl.message(
      'This will remove it from the list. Save to server when you are ready.',
      name: 'hadith_delete_body',
      desc: '',
      args: [],
    );
  }

  /// `Changes are local until you sync with the server.`
  String get hadith_save_bar_hint {
    return Intl.message(
      'Changes are local until you sync with the server.',
      name: 'hadith_save_bar_hint',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this hadith?`
  String get hadith_confirm_delete {
    return Intl.message(
      'Are you sure you want to delete this hadith?',
      name: 'hadith_confirm_delete',
      desc: '',
      args: [],
    );
  }

  /// `New verse`
  String get verse_fab_add {
    return Intl.message(
      'New verse',
      name: 'verse_fab_add',
      desc: '',
      args: [],
    );
  }

  /// `New verse`
  String get verse_editor_title_new {
    return Intl.message(
      'New verse',
      name: 'verse_editor_title_new',
      desc: '',
      args: [],
    );
  }

  /// `Edit verse`
  String get verse_editor_title_edit {
    return Intl.message(
      'Edit verse',
      name: 'verse_editor_title_edit',
      desc: '',
      args: [],
    );
  }

  /// `Context or surah`
  String get verse_narrator {
    return Intl.message(
      'Context or surah',
      name: 'verse_narrator',
      desc: '',
      args: [],
    );
  }

  /// `Verse text`
  String get verse_text {
    return Intl.message(
      'Verse text',
      name: 'verse_text',
      desc: '',
      args: [],
    );
  }

  /// `Source (optional)`
  String get verse_source {
    return Intl.message(
      'Source (optional)',
      name: 'verse_source',
      desc: '',
      args: [],
    );
  }

  /// `No verses yet`
  String get verse_empty_title {
    return Intl.message(
      'No verses yet',
      name: 'verse_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Add verses to rotate below the prayer times on the display.`
  String get verse_empty_subtitle {
    return Intl.message(
      'Add verses to rotate below the prayer times on the display.',
      name: 'verse_empty_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove verse?`
  String get verse_delete_title {
    return Intl.message(
      'Remove verse?',
      name: 'verse_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `This will remove it from the list. Save to server when you are ready.`
  String get verse_delete_body {
    return Intl.message(
      'This will remove it from the list. Save to server when you are ready.',
      name: 'verse_delete_body',
      desc: '',
      args: [],
    );
  }

  /// `Changes are local until you sync with the server.`
  String get verse_save_bar_hint {
    return Intl.message(
      'Changes are local until you sync with the server.',
      name: 'verse_save_bar_hint',
      desc: '',
      args: [],
    );
  }

  /// `New supplication`
  String get dua_fab_add {
    return Intl.message(
      'New supplication',
      name: 'dua_fab_add',
      desc: '',
      args: [],
    );
  }

  /// `New supplication`
  String get dua_editor_title_new {
    return Intl.message(
      'New supplication',
      name: 'dua_editor_title_new',
      desc: '',
      args: [],
    );
  }

  /// `Edit supplication`
  String get dua_editor_title_edit {
    return Intl.message(
      'Edit supplication',
      name: 'dua_editor_title_edit',
      desc: '',
      args: [],
    );
  }

  /// `Title or context`
  String get dua_narrator {
    return Intl.message(
      'Title or context',
      name: 'dua_narrator',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get dua_text {
    return Intl.message(
      'Text',
      name: 'dua_text',
      desc: '',
      args: [],
    );
  }

  /// `Source (optional)`
  String get dua_source {
    return Intl.message(
      'Source (optional)',
      name: 'dua_source',
      desc: '',
      args: [],
    );
  }

  /// `No supplications yet`
  String get dua_empty_title {
    return Intl.message(
      'No supplications yet',
      name: 'dua_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Add supplications to rotate below the prayer times on the display.`
  String get dua_empty_subtitle {
    return Intl.message(
      'Add supplications to rotate below the prayer times on the display.',
      name: 'dua_empty_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove supplication?`
  String get dua_delete_title {
    return Intl.message(
      'Remove supplication?',
      name: 'dua_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `This will remove it from the list. Save to server when you are ready.`
  String get dua_delete_body {
    return Intl.message(
      'This will remove it from the list. Save to server when you are ready.',
      name: 'dua_delete_body',
      desc: '',
      args: [],
    );
  }

  /// `Changes are local until you sync with the server.`
  String get dua_save_bar_hint {
    return Intl.message(
      'Changes are local until you sync with the server.',
      name: 'dua_save_bar_hint',
      desc: '',
      args: [],
    );
  }

  /// `New dhikr`
  String get adhkar_fab_add {
    return Intl.message(
      'New dhikr',
      name: 'adhkar_fab_add',
      desc: '',
      args: [],
    );
  }

  /// `New dhikr`
  String get adhkar_editor_title_new {
    return Intl.message(
      'New dhikr',
      name: 'adhkar_editor_title_new',
      desc: '',
      args: [],
    );
  }

  /// `Edit dhikr`
  String get adhkar_editor_title_edit {
    return Intl.message(
      'Edit dhikr',
      name: 'adhkar_editor_title_edit',
      desc: '',
      args: [],
    );
  }

  /// `Time or context`
  String get adhkar_narrator {
    return Intl.message(
      'Time or context',
      name: 'adhkar_narrator',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get adhkar_text {
    return Intl.message(
      'Text',
      name: 'adhkar_text',
      desc: '',
      args: [],
    );
  }

  /// `Note (optional)`
  String get adhkar_source {
    return Intl.message(
      'Note (optional)',
      name: 'adhkar_source',
      desc: '',
      args: [],
    );
  }

  /// `No dhikr yet`
  String get adhkar_empty_title {
    return Intl.message(
      'No dhikr yet',
      name: 'adhkar_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Add adhkar to rotate below the prayer times on the display.`
  String get adhkar_empty_subtitle {
    return Intl.message(
      'Add adhkar to rotate below the prayer times on the display.',
      name: 'adhkar_empty_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove dhikr?`
  String get adhkar_delete_title {
    return Intl.message(
      'Remove dhikr?',
      name: 'adhkar_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `This will remove it from the list. Save to server when you are ready.`
  String get adhkar_delete_body {
    return Intl.message(
      'This will remove it from the list. Save to server when you are ready.',
      name: 'adhkar_delete_body',
      desc: '',
      args: [],
    );
  }

  /// `Changes are local until you sync with the server.`
  String get adhkar_save_bar_hint {
    return Intl.message(
      'Changes are local until you sync with the server.',
      name: 'adhkar_save_bar_hint',
      desc: '',
      args: [],
    );
  }

  /// `New announcement`
  String get announcement_fab_add {
    return Intl.message(
      'New announcement',
      name: 'announcement_fab_add',
      desc: '',
      args: [],
    );
  }

  /// `New announcement`
  String get announcement_editor_new {
    return Intl.message(
      'New announcement',
      name: 'announcement_editor_new',
      desc: '',
      args: [],
    );
  }

  /// `Edit announcement`
  String get announcement_editor_edit {
    return Intl.message(
      'Edit announcement',
      name: 'announcement_editor_edit',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get announcement_field_title {
    return Intl.message(
      'Title',
      name: 'announcement_field_title',
      desc: '',
      args: [],
    );
  }

  /// `Subtitle`
  String get announcement_field_subtitle {
    return Intl.message(
      'Subtitle',
      name: 'announcement_field_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Link or text for QR`
  String get announcement_field_qr {
    return Intl.message(
      'Link or text for QR',
      name: 'announcement_field_qr',
      desc: '',
      args: [],
    );
  }

  /// `Display period`
  String get announcement_period {
    return Intl.message(
      'Display period',
      name: 'announcement_period',
      desc: '',
      args: [],
    );
  }

  /// `Showing now`
  String get announcement_status_active {
    return Intl.message(
      'Showing now',
      name: 'announcement_status_active',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled`
  String get announcement_status_upcoming {
    return Intl.message(
      'Scheduled',
      name: 'announcement_status_upcoming',
      desc: '',
      args: [],
    );
  }

  /// `Ended`
  String get announcement_status_ended {
    return Intl.message(
      'Ended',
      name: 'announcement_status_ended',
      desc: '',
      args: [],
    );
  }

  /// `No announcements`
  String get announcement_empty_title {
    return Intl.message(
      'No announcements',
      name: 'announcement_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `Create slides with dates for the display screen.`
  String get announcement_empty_subtitle {
    return Intl.message(
      'Create slides with dates for the display screen.',
      name: 'announcement_empty_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove announcement?`
  String get announcement_delete_title {
    return Intl.message(
      'Remove announcement?',
      name: 'announcement_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `It will be removed from the list. Sync with the server to apply.`
  String get announcement_delete_body {
    return Intl.message(
      'It will be removed from the list. Sync with the server to apply.',
      name: 'announcement_delete_body',
      desc: '',
      args: [],
    );
  }

  /// `Local changes — tap save to upload.`
  String get announcement_save_bar_hint {
    return Intl.message(
      'Local changes — tap save to upload.',
      name: 'announcement_save_bar_hint',
      desc: '',
      args: [],
    );
  }

  /// `End date must be on or after the start date.`
  String get announcement_dates_invalid {
    return Intl.message(
      'End date must be on or after the start date.',
      name: 'announcement_dates_invalid',
      desc: '',
      args: [],
    );
  }

  /// `No active priority alerts.`
  String get alerts_empty_title {
    return Intl.message(
      'No active priority alerts.',
      name: 'alerts_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `These alerts appear full-screen on the display.`
  String get alerts_empty_subtitle {
    return Intl.message(
      'These alerts appear full-screen on the display.',
      name: 'alerts_empty_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `New High-Priority Alert`
  String get alerts_fab_add {
    return Intl.message(
      'New High-Priority Alert',
      name: 'alerts_fab_add',
      desc: '',
      args: [],
    );
  }

  /// `Clear All Active Alerts`
  String get alerts_clear_all {
    return Intl.message(
      'Clear All Active Alerts',
      name: 'alerts_clear_all',
      desc: '',
      args: [],
    );
  }

  /// `Send Instant Alert`
  String get alert_editor_title {
    return Intl.message(
      'Send Instant Alert',
      name: 'alert_editor_title',
      desc: '',
      args: [],
    );
  }

  /// `Alert Headline`
  String get alert_field_headline {
    return Intl.message(
      'Alert Headline',
      name: 'alert_field_headline',
      desc: '',
      args: [],
    );
  }

  /// `Urgent Message`
  String get alert_field_message {
    return Intl.message(
      'Urgent Message',
      name: 'alert_field_message',
      desc: '',
      args: [],
    );
  }

  /// `Duration:`
  String get alert_field_duration {
    return Intl.message(
      'Duration:',
      name: 'alert_field_duration',
      desc: '',
      args: [],
    );
  }

  /// `Send to Screen`
  String get alert_send_action {
    return Intl.message(
      'Send to Screen',
      name: 'alert_send_action',
      desc: '',
      args: [],
    );
  }

  /// `Prayer times`
  String get miqat_ar {
    return Intl.message(
      'Prayer times',
      name: 'miqat_ar',
      desc: '',
      args: [],
    );
  }

  /// `MIQAT PRAYER TIMES`
  String get miqat_en {
    return Intl.message(
      'MIQAT PRAYER TIMES',
      name: 'miqat_en',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get sign_out_tooltip {
    return Intl.message(
      'Sign out',
      name: 'sign_out_tooltip',
      desc: '',
      args: [],
    );
  }

  /// `Remaining`
  String get remaining_label {
    return Intl.message(
      'Remaining',
      name: 'remaining_label',
      desc: '',
      args: [],
    );
  }

  /// `Azan`
  String get countdown_azan {
    return Intl.message(
      'Azan',
      name: 'countdown_azan',
      desc: '',
      args: [],
    );
  }

  /// `Iqama`
  String get countdown_iqama {
    return Intl.message(
      'Iqama',
      name: 'countdown_iqama',
      desc: '',
      args: [],
    );
  }

  /// `Scan for details`
  String get scan_qr_hint {
    return Intl.message(
      'Scan for details',
      name: 'scan_qr_hint',
      desc: '',
      args: [],
    );
  }

  /// `May Allah bless this Mosque`
  String get mosque_blessing {
    return Intl.message(
      'May Allah bless this Mosque',
      name: 'mosque_blessing',
      desc: '',
      args: [],
    );
  }

  /// `Fajr`
  String get prayer_fajr {
    return Intl.message(
      'Fajr',
      name: 'prayer_fajr',
      desc: '',
      args: [],
    );
  }

  /// `Sunrise`
  String get prayer_sunrise {
    return Intl.message(
      'Sunrise',
      name: 'prayer_sunrise',
      desc: '',
      args: [],
    );
  }

  /// `Dhuhr`
  String get prayer_dhuhr {
    return Intl.message(
      'Dhuhr',
      name: 'prayer_dhuhr',
      desc: '',
      args: [],
    );
  }

  /// `Asr`
  String get prayer_asr {
    return Intl.message(
      'Asr',
      name: 'prayer_asr',
      desc: '',
      args: [],
    );
  }

  /// `Maghrib`
  String get prayer_maghrib {
    return Intl.message(
      'Maghrib',
      name: 'prayer_maghrib',
      desc: '',
      args: [],
    );
  }

  /// `Isha`
  String get prayer_isha {
    return Intl.message(
      'Isha',
      name: 'prayer_isha',
      desc: '',
      args: [],
    );
  }

  /// `Jumuah`
  String get prayer_jummah {
    return Intl.message(
      'Jumuah',
      name: 'prayer_jummah',
      desc: '',
      args: [],
    );
  }

  /// `فجر`
  String get prayer_fajr_ar {
    return Intl.message(
      'فجر',
      name: 'prayer_fajr_ar',
      desc: '',
      args: [],
    );
  }

  /// `Fajr`
  String get prayer_fajr_en {
    return Intl.message(
      'Fajr',
      name: 'prayer_fajr_en',
      desc: '',
      args: [],
    );
  }

  /// `شروق`
  String get prayer_sunrise_ar {
    return Intl.message(
      'شروق',
      name: 'prayer_sunrise_ar',
      desc: '',
      args: [],
    );
  }

  /// `Sunrise`
  String get prayer_sunrise_en {
    return Intl.message(
      'Sunrise',
      name: 'prayer_sunrise_en',
      desc: '',
      args: [],
    );
  }

  /// `ظهر`
  String get prayer_dhuhr_ar {
    return Intl.message(
      'ظهر',
      name: 'prayer_dhuhr_ar',
      desc: '',
      args: [],
    );
  }

  /// `Dhuhr`
  String get prayer_dhuhr_en {
    return Intl.message(
      'Dhuhr',
      name: 'prayer_dhuhr_en',
      desc: '',
      args: [],
    );
  }

  /// `عصر`
  String get prayer_asr_ar {
    return Intl.message(
      'عصر',
      name: 'prayer_asr_ar',
      desc: '',
      args: [],
    );
  }

  /// `Asr`
  String get prayer_asr_en {
    return Intl.message(
      'Asr',
      name: 'prayer_asr_en',
      desc: '',
      args: [],
    );
  }

  /// `مغرب`
  String get prayer_maghrib_ar {
    return Intl.message(
      'مغرب',
      name: 'prayer_maghrib_ar',
      desc: '',
      args: [],
    );
  }

  /// `Maghrib`
  String get prayer_maghrib_en {
    return Intl.message(
      'Maghrib',
      name: 'prayer_maghrib_en',
      desc: '',
      args: [],
    );
  }

  /// `عشاء`
  String get prayer_isha_ar {
    return Intl.message(
      'عشاء',
      name: 'prayer_isha_ar',
      desc: '',
      args: [],
    );
  }

  /// `Isha`
  String get prayer_isha_en {
    return Intl.message(
      'Isha',
      name: 'prayer_isha_en',
      desc: '',
      args: [],
    );
  }

  /// `Azan`
  String get azan_label {
    return Intl.message(
      'Azan',
      name: 'azan_label',
      desc: '',
      args: [],
    );
  }

  /// `Iqama`
  String get iqama_label {
    return Intl.message(
      'Iqama',
      name: 'iqama_label',
      desc: '',
      args: [],
    );
  }

  /// `App language`
  String get settings_language {
    return Intl.message(
      'App language',
      name: 'settings_language',
      desc: '',
      args: [],
    );
  }

  /// `Inactive card background`
  String get design_prayer_overlay {
    return Intl.message(
      'Inactive card background',
      name: 'design_prayer_overlay',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get required_field {
    return Intl.message(
      'Required',
      name: 'required_field',
      desc: '',
      args: [],
    );
  }

  /// `mins`
  String get minutes_suffix {
    return Intl.message(
      'mins',
      name: 'minutes_suffix',
      desc: '',
      args: [],
    );
  }

  /// `m`
  String get minutes_short {
    return Intl.message(
      'm',
      name: 'minutes_short',
      desc: '',
      args: [],
    );
  }

  /// `s`
  String get unit_seconds {
    return Intl.message(
      's',
      name: 'unit_seconds',
      desc: '',
      args: [],
    );
  }

  /// `No active mosque linked to this account.`
  String get display_error_no_mosque {
    return Intl.message(
      'No active mosque linked to this account.',
      name: 'display_error_no_mosque',
      desc: '',
      args: [],
    );
  }

  /// `Hadith`
  String get display_ticker_hadith {
    return Intl.message(
      'Hadith',
      name: 'display_ticker_hadith',
      desc: '',
      args: [],
    );
  }

  /// `Verse`
  String get display_ticker_verse {
    return Intl.message(
      'Verse',
      name: 'display_ticker_verse',
      desc: '',
      args: [],
    );
  }

  /// `Dua`
  String get display_ticker_dua {
    return Intl.message(
      'Dua',
      name: 'display_ticker_dua',
      desc: '',
      args: [],
    );
  }

  /// `Dhikr`
  String get display_ticker_adhkar {
    return Intl.message(
      'Dhikr',
      name: 'display_ticker_adhkar',
      desc: '',
      args: [],
    );
  }

  /// `System ad`
  String get display_ticker_platform {
    return Intl.message(
      'System ad',
      name: 'display_ticker_platform',
      desc: '',
      args: [],
    );
  }

  /// `Mosque ad`
  String get display_ticker_mosque {
    return Intl.message(
      'Mosque ad',
      name: 'display_ticker_mosque',
      desc: '',
      args: [],
    );
  }

  /// `Next prayer`
  String get display_next_prayer_title {
    return Intl.message(
      'Next prayer',
      name: 'display_next_prayer_title',
      desc: '',
      args: [],
    );
  }

  /// `Up next`
  String get display_next_prayer_badge {
    return Intl.message(
      'Up next',
      name: 'display_next_prayer_badge',
      desc: '',
      args: [],
    );
  }

  /// `Remaining to iqama — {prayer}`
  String display_remaining_to_iqama_line(Object prayer) {
    return Intl.message(
      'Remaining to iqama — $prayer',
      name: 'display_remaining_to_iqama_line',
      desc: '',
      args: [prayer],
    );
  }

  /// `Remaining to adhan — {prayer}`
  String display_remaining_to_adhan_line(Object prayer) {
    return Intl.message(
      'Remaining to adhan — $prayer',
      name: 'display_remaining_to_adhan_line',
      desc: '',
      args: [prayer],
    );
  }

  /// `Remaining to Sunrise`
  String get display_remaining_to_sunrise_line {
    return Intl.message(
      'Remaining to Sunrise',
      name: 'display_remaining_to_sunrise_line',
      desc: '',
      args: [],
    );
  }

  /// `Remaining`
  String get display_countdown_label {
    return Intl.message(
      'Remaining',
      name: 'display_countdown_label',
      desc: '',
      args: [],
    );
  }

  /// `Iqama time ended — moving to next prayer`
  String get display_grace_iqama_subtitle {
    return Intl.message(
      'Iqama time ended — moving to next prayer',
      name: 'display_grace_iqama_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Minutes after adhan`
  String get iqama_minutes_after_adhan {
    return Intl.message(
      'Minutes after adhan',
      name: 'iqama_minutes_after_adhan',
      desc: '',
      args: [],
    );
  }

  /// `Save iqama settings`
  String get save_iqama_settings {
    return Intl.message(
      'Save iqama settings',
      name: 'save_iqama_settings',
      desc: '',
      args: [],
    );
  }

  /// `Save design settings`
  String get save_design_settings {
    return Intl.message(
      'Save design settings',
      name: 'save_design_settings',
      desc: '',
      args: [],
    );
  }

  /// `Save general settings`
  String get save_general_settings {
    return Intl.message(
      'Save general settings',
      name: 'save_general_settings',
      desc: '',
      args: [],
    );
  }

  /// `Typography & Layout`
  String get design_section_typography {
    return Intl.message(
      'Typography & Layout',
      name: 'design_section_typography',
      desc: '',
      args: [],
    );
  }

  /// `Ticker & Symbols`
  String get design_section_ticker {
    return Intl.message(
      'Ticker & Symbols',
      name: 'design_section_ticker',
      desc: '',
      args: [],
    );
  }

  /// `Ticker Speed`
  String get design_ticker_speed {
    return Intl.message(
      'Ticker Speed',
      name: 'design_ticker_speed',
      desc: '',
      args: [],
    );
  }

  /// `Content Strip Speed`
  String get design_strip_speed {
    return Intl.message(
      'Content Strip Speed',
      name: 'design_strip_speed',
      desc: '',
      args: [],
    );
  }

  /// `Numeral Format`
  String get design_numeral_format {
    return Intl.message(
      'Numeral Format',
      name: 'design_numeral_format',
      desc: '',
      args: [],
    );
  }

  /// `Arabic (١٢٣)`
  String get design_numeral_arabic {
    return Intl.message(
      'Arabic (١٢٣)',
      name: 'design_numeral_arabic',
      desc: '',
      args: [],
    );
  }

  /// `English (123)`
  String get design_numeral_english {
    return Intl.message(
      'English (123)',
      name: 'design_numeral_english',
      desc: '',
      args: [],
    );
  }

  /// `App Font Family`
  String get design_font_family {
    return Intl.message(
      'App Font Family',
      name: 'design_font_family',
      desc: '',
      args: [],
    );
  }

  /// `Browse Fonts`
  String get design_font_browse {
    return Intl.message(
      'Browse Fonts',
      name: 'design_font_browse',
      desc: '',
      args: [],
    );
  }

  /// `Visual Font Browser`
  String get design_font_browser_title {
    return Intl.message(
      'Visual Font Browser',
      name: 'design_font_browser_title',
      desc: '',
      args: [],
    );
  }

  /// `بسم الله الرحمن الرحيم - Mosque App Preview`
  String get design_font_preview_text {
    return Intl.message(
      'بسم الله الرحمن الرحيم - Mosque App Preview',
      name: 'design_font_preview_text',
      desc: '',
      args: [],
    );
  }

  /// `Clock font size`
  String get design_font_size_clock {
    return Intl.message(
      'Clock font size',
      name: 'design_font_size_clock',
      desc: '',
      args: [],
    );
  }

  /// `Mosque info font size`
  String get design_font_size_mosque_info {
    return Intl.message(
      'Mosque info font size',
      name: 'design_font_size_mosque_info',
      desc: '',
      args: [],
    );
  }

  /// `Prayers font size`
  String get design_font_size_prayers {
    return Intl.message(
      'Prayers font size',
      name: 'design_font_size_prayers',
      desc: '',
      args: [],
    );
  }

  /// `Announcements font size`
  String get design_font_size_announcements {
    return Intl.message(
      'Announcements font size',
      name: 'design_font_size_announcements',
      desc: '',
      args: [],
    );
  }

  /// `Hadiths & content font size`
  String get design_font_size_content {
    return Intl.message(
      'Hadiths & content font size',
      name: 'design_font_size_content',
      desc: '',
      args: [],
    );
  }

  /// `Enter a value between 8 and 96`
  String get validation_font_size_range {
    return Intl.message(
      'Enter a value between 8 and 96',
      name: 'validation_font_size_range',
      desc: '',
      args: [],
    );
  }

  /// `Mosque name`
  String get mosque_name_label {
    return Intl.message(
      'Mosque name',
      name: 'mosque_name_label',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city_label {
    return Intl.message(
      'City',
      name: 'city_label',
      desc: '',
      args: [],
    );
  }

  /// `Prayer calculation method`
  String get prayer_calculation_method {
    return Intl.message(
      'Prayer calculation method',
      name: 'prayer_calculation_method',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Prayer Time Adjustment (Minutes)`
  String get general_section_adjustments {
    return Intl.message(
      'Advanced Prayer Time Adjustment (Minutes)',
      name: 'general_section_adjustments',
      desc: '',
      args: [],
    );
  }

  /// `Latitude: {value}`
  String latitude_coordinate(Object value) {
    return Intl.message(
      'Latitude: $value',
      name: 'latitude_coordinate',
      desc: '',
      args: [value],
    );
  }

  /// `Longitude: {value}`
  String longitude_coordinate(Object value) {
    return Intl.message(
      'Longitude: $value',
      name: 'longitude_coordinate',
      desc: '',
      args: [value],
    );
  }

  /// `Mosque Smart Display`
  String get splash_app_tagline {
    return Intl.message(
      'Mosque Smart Display',
      name: 'splash_app_tagline',
      desc: '',
      args: [],
    );
  }

  /// `Time until iqama for {prayer}`
  String display_time_until_iqama_for(Object prayer) {
    return Intl.message(
      'Time until iqama for $prayer',
      name: 'display_time_until_iqama_for',
      desc: '',
      args: [prayer],
    );
  }

  /// `Time until adhan for {prayer}`
  String display_time_until_adhan_for(Object prayer) {
    return Intl.message(
      'Time until adhan for $prayer',
      name: 'display_time_until_adhan_for',
      desc: '',
      args: [prayer],
    );
  }

  /// `Fajr (tomorrow)`
  String get prayer_fajr_tomorrow {
    return Intl.message(
      'Fajr (tomorrow)',
      name: 'prayer_fajr_tomorrow',
      desc: '',
      args: [],
    );
  }

  /// `Background Type`
  String get design_background_type {
    return Intl.message(
      'Background Type',
      name: 'design_background_type',
      desc: '',
      args: [],
    );
  }

  /// `Library Image`
  String get design_bg_type_image {
    return Intl.message(
      'Library Image',
      name: 'design_bg_type_image',
      desc: '',
      args: [],
    );
  }

  /// `Solid Color`
  String get design_bg_type_color {
    return Intl.message(
      'Solid Color',
      name: 'design_bg_type_color',
      desc: '',
      args: [],
    );
  }

  /// `Colors & Theme`
  String get design_colors_title {
    return Intl.message(
      'Colors & Theme',
      name: 'design_colors_title',
      desc: '',
      args: [],
    );
  }

  /// `Font Sizes`
  String get design_font_sizes_title {
    return Intl.message(
      'Font Sizes',
      name: 'design_font_sizes_title',
      desc: '',
      args: [],
    );
  }

  /// `Typography`
  String get design_typography_title {
    return Intl.message(
      'Typography',
      name: 'design_typography_title',
      desc: '',
      args: [],
    );
  }

  /// `Display Behavior`
  String get design_behavior_title {
    return Intl.message(
      'Display Behavior',
      name: 'design_behavior_title',
      desc: '',
      args: [],
    );
  }

  /// `Screen Background`
  String get design_background_title {
    return Intl.message(
      'Screen Background',
      name: 'design_background_title',
      desc: '',
      args: [],
    );
  }

  /// `Main Clock & Time Color`
  String get design_color_primary {
    return Intl.message(
      'Main Clock & Time Color',
      name: 'design_color_primary',
      desc: '',
      args: [],
    );
  }

  /// `Ticker Bar Background Color`
  String get design_color_secondary {
    return Intl.message(
      'Ticker Bar Background Color',
      name: 'design_color_secondary',
      desc: '',
      args: [],
    );
  }

  /// `Active Prayer Card Background`
  String get design_color_active_card {
    return Intl.message(
      'Active Prayer Card Background',
      name: 'design_color_active_card',
      desc: '',
      args: [],
    );
  }

  /// `Active Card Text Color`
  String get design_color_active_card_text {
    return Intl.message(
      'Active Card Text Color',
      name: 'design_color_active_card_text',
      desc: '',
      args: [],
    );
  }

  /// `Inactive Card & Hadith Text`
  String get design_color_inactive_card_text {
    return Intl.message(
      'Inactive Card & Hadith Text',
      name: 'design_color_inactive_card_text',
      desc: '',
      args: [],
    );
  }

  /// `Inactive Cards Background Color`
  String get design_color_prayer_overlay {
    return Intl.message(
      'Inactive Cards Background Color',
      name: 'design_color_prayer_overlay',
      desc: '',
      args: [],
    );
  }

  /// `Clock Font Size`
  String get design_clock_font_size {
    return Intl.message(
      'Clock Font Size',
      name: 'design_clock_font_size',
      desc: '',
      args: [],
    );
  }

  /// `Mosque Info Font Size`
  String get design_mosque_info_font_size {
    return Intl.message(
      'Mosque Info Font Size',
      name: 'design_mosque_info_font_size',
      desc: '',
      args: [],
    );
  }

  /// `Prayers Font Size`
  String get design_prayers_font_size {
    return Intl.message(
      'Prayers Font Size',
      name: 'design_prayers_font_size',
      desc: '',
      args: [],
    );
  }

  /// `Announcements Font Size`
  String get design_announcements_font_size {
    return Intl.message(
      'Announcements Font Size',
      name: 'design_announcements_font_size',
      desc: '',
      args: [],
    );
  }

  /// `Hadiths & Content Font Size`
  String get design_content_font_size {
    return Intl.message(
      'Hadiths & Content Font Size',
      name: 'design_content_font_size',
      desc: '',
      args: [],
    );
  }

  /// `Arabic (١٢٣)`
  String get numeral_format_arabic {
    return Intl.message(
      'Arabic (١٢٣)',
      name: 'numeral_format_arabic',
      desc: '',
      args: [],
    );
  }

  /// `English (123)`
  String get numeral_format_english {
    return Intl.message(
      'English (123)',
      name: 'numeral_format_english',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get register_title {
    return Intl.message(
      'Create Account',
      name: 'register_title',
      desc: '',
      args: [],
    );
  }

  /// `Join Miqat system as a mosque administrator`
  String get register_subtitle {
    return Intl.message(
      'Join Miqat system as a mosque administrator',
      name: 'register_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get register_button {
    return Intl.message(
      'Create Account',
      name: 'register_button',
      desc: '',
      args: [],
    );
  }

  /// `Register New Mosque`
  String get register_type_new {
    return Intl.message(
      'Register New Mosque',
      name: 'register_type_new',
      desc: '',
      args: [],
    );
  }

  /// `Join Existing Mosque`
  String get register_type_existing {
    return Intl.message(
      'Join Existing Mosque',
      name: 'register_type_existing',
      desc: '',
      args: [],
    );
  }

  /// `Unique Mosque ID (English)`
  String get mosque_id_label {
    return Intl.message(
      'Unique Mosque ID (English)',
      name: 'mosque_id_label',
      desc: '',
      args: [],
    );
  }

  /// `example: al_rowda_mosque`
  String get mosque_id_hint {
    return Intl.message(
      'example: al_rowda_mosque',
      name: 'mosque_id_hint',
      desc: '',
      args: [],
    );
  }

  /// `This ID is already taken`
  String get mosque_id_taken {
    return Intl.message(
      'This ID is already taken',
      name: 'mosque_id_taken',
      desc: '',
      args: [],
    );
  }

  /// `Suggested ID: {id}`
  String mosque_id_suggestion(Object id) {
    return Intl.message(
      'Suggested ID: $id',
      name: 'mosque_id_suggestion',
      desc: '',
      args: [id],
    );
  }

  /// `Account and mosque created successfully!`
  String get registration_success_new {
    return Intl.message(
      'Account and mosque created successfully!',
      name: 'registration_success_new',
      desc: '',
      args: [],
    );
  }

  /// `Account created. Please contact support to link it to your mosque.`
  String get registration_success_existing {
    return Intl.message(
      'Account created. Please contact support to link it to your mosque.',
      name: 'registration_success_existing',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? Sign in`
  String get login_link {
    return Intl.message(
      'Already have an account? Sign in',
      name: 'login_link',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account? Register now`
  String get register_link {
    return Intl.message(
      'Don\'t have an account? Register now',
      name: 'register_link',
      desc: '',
      args: [],
    );
  }

  /// `Mosque ID is required for a new mosque`
  String get validation_mosque_id_required {
    return Intl.message(
      'Mosque ID is required for a new mosque',
      name: 'validation_mosque_id_required',
      desc: '',
      args: [],
    );
  }

  /// `To join an existing mosque, please create your account first, then contact support at {phone} to link your account.`
  String contact_dev_message(Object phone) {
    return Intl.message(
      'To join an existing mosque, please create your account first, then contact support at $phone to link your account.',
      name: 'contact_dev_message',
      desc: '',
      args: [phone],
    );
  }

  /// `Profile`
  String get tab_profile {
    return Intl.message(
      'Profile',
      name: 'tab_profile',
      desc: '',
      args: [],
    );
  }

  /// `About App`
  String get tab_about {
    return Intl.message(
      'About App',
      name: 'tab_about',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get profile_email {
    return Intl.message(
      'Email',
      name: 'profile_email',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get profile_password {
    return Intl.message(
      'Current Password',
      name: 'profile_password',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get profile_new_password {
    return Intl.message(
      'New Password',
      name: 'profile_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Terminate other sessions`
  String get profile_terminate_other {
    return Intl.message(
      'Terminate other sessions',
      name: 'profile_terminate_other',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get profile_save_changes {
    return Intl.message(
      'Save Changes',
      name: 'profile_save_changes',
      desc: '',
      args: [],
    );
  }

  /// `General Information`
  String get about_category_default {
    return Intl.message(
      'General Information',
      name: 'about_category_default',
      desc: '',
      args: [],
    );
  }

  /// `Note: Changing password automatically signs out most other sessions.`
  String get profile_terminate_hint {
    return Intl.message(
      'Note: Changing password automatically signs out most other sessions.',
      name: 'profile_terminate_hint',
      desc: '',
      args: [],
    );
  }

  /// `App Update`
  String get tab_update {
    return Intl.message(
      'App Update',
      name: 'tab_update',
      desc: '',
      args: [],
    );
  }

  /// `New Update Available!`
  String get update_title {
    return Intl.message(
      'New Update Available!',
      name: 'update_title',
      desc: '',
      args: [],
    );
  }

  /// `Current Version: {version}`
  String update_current_version(Object version) {
    return Intl.message(
      'Current Version: $version',
      name: 'update_current_version',
      desc: '',
      args: [version],
    );
  }

  /// `Latest Version: {version}`
  String update_latest_version(Object version) {
    return Intl.message(
      'Latest Version: $version',
      name: 'update_latest_version',
      desc: '',
      args: [version],
    );
  }

  /// `Download & Install Update`
  String get update_download {
    return Intl.message(
      'Download & Install Update',
      name: 'update_download',
      desc: '',
      args: [],
    );
  }

  /// `Downloading... {progress}%`
  String update_downloading(Object progress) {
    return Intl.message(
      'Downloading... $progress%',
      name: 'update_downloading',
      desc: '',
      args: [progress],
    );
  }

  /// `Download complete! Installing...`
  String get update_success {
    return Intl.message(
      'Download complete! Installing...',
      name: 'update_success',
      desc: '',
      args: [],
    );
  }

  /// `Download failed. Please try again later.`
  String get update_failure {
    return Intl.message(
      'Download failed. Please try again later.',
      name: 'update_failure',
      desc: '',
      args: [],
    );
  }

  /// `No download link available for this platform.`
  String get update_no_link {
    return Intl.message(
      'No download link available for this platform.',
      name: 'update_no_link',
      desc: '',
      args: [],
    );
  }

  /// `Contact Tech Support`
  String get contact_developers {
    return Intl.message(
      'Contact Tech Support',
      name: 'contact_developers',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number (For fast contact)`
  String get registration_phone {
    return Intl.message(
      'Phone Number (For fast contact)',
      name: 'registration_phone',
      desc: '',
      args: [],
    );
  }

  /// `Contact Phone Number`
  String get profile_phone_label {
    return Intl.message(
      'Contact Phone Number',
      name: 'profile_phone_label',
      desc: '',
      args: [],
    );
  }

  /// `Please ensure you enter your correct number. Tech support will use it to contact you and ensure your account and mosque remain active.`
  String get profile_phone_hint {
    return Intl.message(
      'Please ensure you enter your correct number. Tech support will use it to contact you and ensure your account and mosque remain active.',
      name: 'profile_phone_hint',
      desc: '',
      args: [],
    );
  }

  /// `Your app is up to date`
  String get update_up_to_date {
    return Intl.message(
      'Your app is up to date',
      name: 'update_up_to_date',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

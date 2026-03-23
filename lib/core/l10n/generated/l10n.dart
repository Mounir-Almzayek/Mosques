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

  /// `Logo`
  String get design_bg_brand {
    return Intl.message(
      'Logo',
      name: 'design_bg_brand',
      desc: '',
      args: [],
    );
  }

  /// `Primary color`
  String get design_primary_color {
    return Intl.message(
      'Primary color',
      name: 'design_primary_color',
      desc: '',
      args: [],
    );
  }

  /// `Secondary color`
  String get design_secondary_color {
    return Intl.message(
      'Secondary color',
      name: 'design_secondary_color',
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

  /// `Prayer cards overlay (on SVG backgrounds)`
  String get design_prayer_overlay {
    return Intl.message(
      'Prayer cards overlay (on SVG backgrounds)',
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

  /// `Base font size`
  String get design_base_font_size {
    return Intl.message(
      'Base font size',
      name: 'design_base_font_size',
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

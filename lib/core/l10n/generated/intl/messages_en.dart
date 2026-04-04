// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(phone) =>
      "To join an existing mosque, please create your account first, then contact support at ${phone} to link your account.";

  static String m1(prayer) => "Remaining to adhan — ${prayer}";

  static String m2(prayer) => "Remaining to iqama — ${prayer}";

  static String m3(prayer) => "Time until adhan for ${prayer}";

  static String m4(prayer) => "Time until iqama for ${prayer}";

  static String m5(value) => "Latitude: ${value}";

  static String m6(value) => "Longitude: ${value}";

  static String m7(id) => "Suggested ID: ${id}";

  static String m8(version) => "Current Version: ${version}";

  static String m9(progress) => "Downloading... ${progress}%";

  static String m10(version) => "Latest Version: ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about_category_default":
            MessageLookupByLibrary.simpleMessage("General Information"),
        "adhkar_delete_body": MessageLookupByLibrary.simpleMessage(
            "This will remove it from the list. Save to server when you are ready."),
        "adhkar_delete_title":
            MessageLookupByLibrary.simpleMessage("Remove dhikr?"),
        "adhkar_editor_title_edit":
            MessageLookupByLibrary.simpleMessage("Edit dhikr"),
        "adhkar_editor_title_new":
            MessageLookupByLibrary.simpleMessage("New dhikr"),
        "adhkar_empty_subtitle": MessageLookupByLibrary.simpleMessage(
            "Add adhkar to rotate below the prayer times on the display."),
        "adhkar_empty_title":
            MessageLookupByLibrary.simpleMessage("No dhikr yet"),
        "adhkar_fab_add": MessageLookupByLibrary.simpleMessage("New dhikr"),
        "adhkar_narrator":
            MessageLookupByLibrary.simpleMessage("Time or context"),
        "adhkar_save_bar_hint": MessageLookupByLibrary.simpleMessage(
            "Changes are local until you sync with the server."),
        "adhkar_source":
            MessageLookupByLibrary.simpleMessage("Note (optional)"),
        "adhkar_text": MessageLookupByLibrary.simpleMessage("Text"),
        "alert_editor_title":
            MessageLookupByLibrary.simpleMessage("Send Instant Alert"),
        "alert_field_duration":
            MessageLookupByLibrary.simpleMessage("Duration:"),
        "alert_field_headline":
            MessageLookupByLibrary.simpleMessage("Alert Headline"),
        "alert_field_message":
            MessageLookupByLibrary.simpleMessage("Urgent Message"),
        "alert_send_action":
            MessageLookupByLibrary.simpleMessage("Send to Screen"),
        "alerts_clear_all":
            MessageLookupByLibrary.simpleMessage("Clear All Active Alerts"),
        "alerts_empty_subtitle": MessageLookupByLibrary.simpleMessage(
            "These alerts appear full-screen on the display."),
        "alerts_empty_title":
            MessageLookupByLibrary.simpleMessage("No active priority alerts."),
        "alerts_fab_add":
            MessageLookupByLibrary.simpleMessage("New High-Priority Alert"),
        "announcement_dates_invalid": MessageLookupByLibrary.simpleMessage(
            "End date must be on or after the start date."),
        "announcement_delete_body": MessageLookupByLibrary.simpleMessage(
            "It will be removed from the list. Sync with the server to apply."),
        "announcement_delete_title":
            MessageLookupByLibrary.simpleMessage("Remove announcement?"),
        "announcement_editor_edit":
            MessageLookupByLibrary.simpleMessage("Edit announcement"),
        "announcement_editor_new":
            MessageLookupByLibrary.simpleMessage("New announcement"),
        "announcement_empty_subtitle": MessageLookupByLibrary.simpleMessage(
            "Create slides with dates for the display screen."),
        "announcement_empty_title":
            MessageLookupByLibrary.simpleMessage("No announcements"),
        "announcement_fab_add":
            MessageLookupByLibrary.simpleMessage("New announcement"),
        "announcement_field_qr":
            MessageLookupByLibrary.simpleMessage("Link or text for QR"),
        "announcement_field_subtitle":
            MessageLookupByLibrary.simpleMessage("Subtitle"),
        "announcement_field_title":
            MessageLookupByLibrary.simpleMessage("Title"),
        "announcement_period":
            MessageLookupByLibrary.simpleMessage("Display period"),
        "announcement_save_bar_hint": MessageLookupByLibrary.simpleMessage(
            "Local changes — tap save to upload."),
        "announcement_status_active":
            MessageLookupByLibrary.simpleMessage("Showing now"),
        "announcement_status_ended":
            MessageLookupByLibrary.simpleMessage("Ended"),
        "announcement_status_upcoming":
            MessageLookupByLibrary.simpleMessage("Scheduled"),
        "azan_label": MessageLookupByLibrary.simpleMessage("Azan"),
        "bismillah": MessageLookupByLibrary.simpleMessage(
            "In the name of Allah, the Most Gracious, the Most Merciful"),
        "camera": MessageLookupByLibrary.simpleMessage("Camera"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "city_label": MessageLookupByLibrary.simpleMessage("City"),
        "contact_dev_message": m0,
        "contact_developers":
            MessageLookupByLibrary.simpleMessage("Contact Tech Support"),
        "countdown_azan": MessageLookupByLibrary.simpleMessage("Azan"),
        "countdown_iqama": MessageLookupByLibrary.simpleMessage("Iqama"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "design_active_card_color":
            MessageLookupByLibrary.simpleMessage("Active card background"),
        "design_active_card_text_color":
            MessageLookupByLibrary.simpleMessage("Active card text color"),
        "design_announcements_font_size":
            MessageLookupByLibrary.simpleMessage("Announcements Font Size"),
        "design_background_color":
            MessageLookupByLibrary.simpleMessage("Screen background color"),
        "design_background_title":
            MessageLookupByLibrary.simpleMessage("Screen Background"),
        "design_background_type":
            MessageLookupByLibrary.simpleMessage("Background Type"),
        "design_behavior_title":
            MessageLookupByLibrary.simpleMessage("Display Behavior"),
        "design_bg_brand": MessageLookupByLibrary.simpleMessage("Logo"),
        "design_bg_primary": MessageLookupByLibrary.simpleMessage("Primary"),
        "design_bg_style_1": MessageLookupByLibrary.simpleMessage("Style 1"),
        "design_bg_style_10": MessageLookupByLibrary.simpleMessage("Style 10"),
        "design_bg_style_11": MessageLookupByLibrary.simpleMessage("Style 11"),
        "design_bg_style_2": MessageLookupByLibrary.simpleMessage("Style 2"),
        "design_bg_style_3": MessageLookupByLibrary.simpleMessage("Style 3"),
        "design_bg_style_4": MessageLookupByLibrary.simpleMessage("Style 4"),
        "design_bg_style_5": MessageLookupByLibrary.simpleMessage("Style 5"),
        "design_bg_style_6": MessageLookupByLibrary.simpleMessage("Style 6"),
        "design_bg_style_7": MessageLookupByLibrary.simpleMessage("Style 7"),
        "design_bg_style_8": MessageLookupByLibrary.simpleMessage("Style 8"),
        "design_bg_style_9": MessageLookupByLibrary.simpleMessage("Style 9"),
        "design_bg_type_color":
            MessageLookupByLibrary.simpleMessage("Solid Color"),
        "design_bg_type_image":
            MessageLookupByLibrary.simpleMessage("Library Image"),
        "design_clock_font_size":
            MessageLookupByLibrary.simpleMessage("Clock Font Size"),
        "design_color_active_card": MessageLookupByLibrary.simpleMessage(
            "Active Prayer Card Background"),
        "design_color_active_card_text":
            MessageLookupByLibrary.simpleMessage("Active Card Text Color"),
        "design_color_inactive_card_text":
            MessageLookupByLibrary.simpleMessage("Inactive Card & Hadith Text"),
        "design_color_prayer_overlay": MessageLookupByLibrary.simpleMessage(
            "Inactive Cards Background Color"),
        "design_color_primary":
            MessageLookupByLibrary.simpleMessage("Main Clock & Time Color"),
        "design_color_secondary":
            MessageLookupByLibrary.simpleMessage("Ticker Bar Background Color"),
        "design_colors_title":
            MessageLookupByLibrary.simpleMessage("Colors & Theme"),
        "design_content_font_size":
            MessageLookupByLibrary.simpleMessage("Hadiths & Content Font Size"),
        "design_display_background_image":
            MessageLookupByLibrary.simpleMessage("Display background image"),
        "design_font_browse":
            MessageLookupByLibrary.simpleMessage("Browse Fonts"),
        "design_font_browser_title":
            MessageLookupByLibrary.simpleMessage("Visual Font Browser"),
        "design_font_family":
            MessageLookupByLibrary.simpleMessage("App Font Family"),
        "design_font_preview_text": MessageLookupByLibrary.simpleMessage(
            "بسم الله الرحمن الرحيم - Mosque App Preview"),
        "design_font_size_announcements":
            MessageLookupByLibrary.simpleMessage("Announcements font size"),
        "design_font_size_clock":
            MessageLookupByLibrary.simpleMessage("Clock font size"),
        "design_font_size_content":
            MessageLookupByLibrary.simpleMessage("Hadiths & content font size"),
        "design_font_size_mosque_info":
            MessageLookupByLibrary.simpleMessage("Mosque info font size"),
        "design_font_size_prayers":
            MessageLookupByLibrary.simpleMessage("Prayers font size"),
        "design_font_sizes_title":
            MessageLookupByLibrary.simpleMessage("Font Sizes"),
        "design_inactive_card_text_color": MessageLookupByLibrary.simpleMessage(
            "Inactive card & Hadith text color"),
        "design_mosque_info_font_size":
            MessageLookupByLibrary.simpleMessage("Mosque Info Font Size"),
        "design_numeral_arabic":
            MessageLookupByLibrary.simpleMessage("Arabic (١٢٣)"),
        "design_numeral_english":
            MessageLookupByLibrary.simpleMessage("English (123)"),
        "design_numeral_format":
            MessageLookupByLibrary.simpleMessage("Numeral Format"),
        "design_pick_color": MessageLookupByLibrary.simpleMessage("Pick color"),
        "design_prayer_overlay":
            MessageLookupByLibrary.simpleMessage("Inactive card background"),
        "design_prayers_font_size":
            MessageLookupByLibrary.simpleMessage("Prayers Font Size"),
        "design_primary_color":
            MessageLookupByLibrary.simpleMessage("Clock and Time color"),
        "design_secondary_color":
            MessageLookupByLibrary.simpleMessage("Ticker bar color"),
        "design_section_ticker":
            MessageLookupByLibrary.simpleMessage("Ticker & Symbols"),
        "design_section_typography":
            MessageLookupByLibrary.simpleMessage("Typography & Layout"),
        "design_strip_speed":
            MessageLookupByLibrary.simpleMessage("Content Strip Speed"),
        "design_ticker_speed":
            MessageLookupByLibrary.simpleMessage("Ticker Speed"),
        "design_typography_title":
            MessageLookupByLibrary.simpleMessage("Typography"),
        "disable_smart_screen":
            MessageLookupByLibrary.simpleMessage("Disable smart screen"),
        "display_countdown_label":
            MessageLookupByLibrary.simpleMessage("Remaining"),
        "display_error_no_mosque": MessageLookupByLibrary.simpleMessage(
            "No active mosque linked to this account."),
        "display_grace_iqama_subtitle": MessageLookupByLibrary.simpleMessage(
            "Iqama time ended — moving to next prayer"),
        "display_next_prayer_badge":
            MessageLookupByLibrary.simpleMessage("Up next"),
        "display_next_prayer_title":
            MessageLookupByLibrary.simpleMessage("Next prayer"),
        "display_remaining_to_adhan_line": m1,
        "display_remaining_to_iqama_line": m2,
        "display_remaining_to_sunrise_line":
            MessageLookupByLibrary.simpleMessage("Remaining to Sunrise"),
        "display_ticker_adhkar": MessageLookupByLibrary.simpleMessage("Dhikr"),
        "display_ticker_dua": MessageLookupByLibrary.simpleMessage("Dua"),
        "display_ticker_hadith": MessageLookupByLibrary.simpleMessage("Hadith"),
        "display_ticker_mosque":
            MessageLookupByLibrary.simpleMessage("Mosque ad"),
        "display_ticker_platform":
            MessageLookupByLibrary.simpleMessage("System ad"),
        "display_ticker_verse": MessageLookupByLibrary.simpleMessage("Verse"),
        "display_time_until_adhan_for": m3,
        "display_time_until_iqama_for": m4,
        "dua_delete_body": MessageLookupByLibrary.simpleMessage(
            "This will remove it from the list. Save to server when you are ready."),
        "dua_delete_title":
            MessageLookupByLibrary.simpleMessage("Remove supplication?"),
        "dua_editor_title_edit":
            MessageLookupByLibrary.simpleMessage("Edit supplication"),
        "dua_editor_title_new":
            MessageLookupByLibrary.simpleMessage("New supplication"),
        "dua_empty_subtitle": MessageLookupByLibrary.simpleMessage(
            "Add supplications to rotate below the prayer times on the display."),
        "dua_empty_title":
            MessageLookupByLibrary.simpleMessage("No supplications yet"),
        "dua_fab_add": MessageLookupByLibrary.simpleMessage("New supplication"),
        "dua_narrator":
            MessageLookupByLibrary.simpleMessage("Title or context"),
        "dua_save_bar_hint": MessageLookupByLibrary.simpleMessage(
            "Changes are local until you sync with the server."),
        "dua_source": MessageLookupByLibrary.simpleMessage("Source (optional)"),
        "dua_text": MessageLookupByLibrary.simpleMessage("Text"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "email_hint":
            MessageLookupByLibrary.simpleMessage("example@domain.com"),
        "email_label": MessageLookupByLibrary.simpleMessage("Email"),
        "enable_smart_screen":
            MessageLookupByLibrary.simpleMessage("Enable smart screen"),
        "error_occurred":
            MessageLookupByLibrary.simpleMessage("Something went wrong"),
        "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
        "general_section_adjustments": MessageLookupByLibrary.simpleMessage(
            "Advanced Prayer Time Adjustment (Minutes)"),
        "hadith_confirm_delete": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this hadith?"),
        "hadith_delete_body": MessageLookupByLibrary.simpleMessage(
            "This will remove it from the list. Save to server when you are ready."),
        "hadith_delete_title":
            MessageLookupByLibrary.simpleMessage("Remove hadith?"),
        "hadith_editor_title_edit":
            MessageLookupByLibrary.simpleMessage("Edit hadith"),
        "hadith_editor_title_new":
            MessageLookupByLibrary.simpleMessage("New hadith"),
        "hadith_empty_subtitle": MessageLookupByLibrary.simpleMessage(
            "Add texts to rotate on the display screen."),
        "hadith_empty_title":
            MessageLookupByLibrary.simpleMessage("No hadiths yet"),
        "hadith_fab_add": MessageLookupByLibrary.simpleMessage("New hadith"),
        "hadith_narrator": MessageLookupByLibrary.simpleMessage("Narrator"),
        "hadith_save_bar_hint": MessageLookupByLibrary.simpleMessage(
            "Changes are local until you sync with the server."),
        "hadith_source":
            MessageLookupByLibrary.simpleMessage("Source (optional)"),
        "hadith_text": MessageLookupByLibrary.simpleMessage("Text"),
        "iqama_label": MessageLookupByLibrary.simpleMessage("Iqama"),
        "iqama_minutes_after_adhan":
            MessageLookupByLibrary.simpleMessage("Minutes after adhan"),
        "latitude_coordinate": m5,
        "location_permission_denied": MessageLookupByLibrary.simpleMessage(
            "Location permission is required to set coordinates"),
        "location_unavailable": MessageLookupByLibrary.simpleMessage(
            "Could not get current location"),
        "location_updated": MessageLookupByLibrary.simpleMessage(
            "Coordinates updated from device location"),
        "login_button": MessageLookupByLibrary.simpleMessage("Sign in"),
        "login_link": MessageLookupByLibrary.simpleMessage(
            "Already have an account? Sign in"),
        "login_subtitle": MessageLookupByLibrary.simpleMessage(
            "Mosque management — control panel"),
        "login_title": MessageLookupByLibrary.simpleMessage("Sign in"),
        "longitude_coordinate": m6,
        "minutes_short": MessageLookupByLibrary.simpleMessage("m"),
        "minutes_suffix": MessageLookupByLibrary.simpleMessage("mins"),
        "miqat_ar": MessageLookupByLibrary.simpleMessage("Prayer times"),
        "miqat_en": MessageLookupByLibrary.simpleMessage("MIQAT PRAYER TIMES"),
        "mosque_blessing":
            MessageLookupByLibrary.simpleMessage("May Allah bless this Mosque"),
        "mosque_id_hint":
            MessageLookupByLibrary.simpleMessage("example: al_rowda_mosque"),
        "mosque_id_label":
            MessageLookupByLibrary.simpleMessage("Unique Mosque ID (English)"),
        "mosque_id_suggestion": m7,
        "mosque_id_taken":
            MessageLookupByLibrary.simpleMessage("This ID is already taken"),
        "mosque_name_label":
            MessageLookupByLibrary.simpleMessage("Mosque name"),
        "no_data": MessageLookupByLibrary.simpleMessage("No data"),
        "numeral_format_arabic":
            MessageLookupByLibrary.simpleMessage("Arabic (١٢٣)"),
        "numeral_format_english":
            MessageLookupByLibrary.simpleMessage("English (123)"),
        "password_hint": MessageLookupByLibrary.simpleMessage("••••••••"),
        "password_label": MessageLookupByLibrary.simpleMessage("Password"),
        "please_select": MessageLookupByLibrary.simpleMessage("Please select"),
        "prayer_asr": MessageLookupByLibrary.simpleMessage("Asr"),
        "prayer_asr_ar": MessageLookupByLibrary.simpleMessage("عصر"),
        "prayer_asr_en": MessageLookupByLibrary.simpleMessage("Asr"),
        "prayer_calculation_method":
            MessageLookupByLibrary.simpleMessage("Prayer calculation method"),
        "prayer_dhuhr": MessageLookupByLibrary.simpleMessage("Dhuhr"),
        "prayer_dhuhr_ar": MessageLookupByLibrary.simpleMessage("ظهر"),
        "prayer_dhuhr_en": MessageLookupByLibrary.simpleMessage("Dhuhr"),
        "prayer_fajr": MessageLookupByLibrary.simpleMessage("Fajr"),
        "prayer_fajr_ar": MessageLookupByLibrary.simpleMessage("فجر"),
        "prayer_fajr_en": MessageLookupByLibrary.simpleMessage("Fajr"),
        "prayer_fajr_tomorrow":
            MessageLookupByLibrary.simpleMessage("Fajr (tomorrow)"),
        "prayer_isha": MessageLookupByLibrary.simpleMessage("Isha"),
        "prayer_isha_ar": MessageLookupByLibrary.simpleMessage("عشاء"),
        "prayer_isha_en": MessageLookupByLibrary.simpleMessage("Isha"),
        "prayer_jummah": MessageLookupByLibrary.simpleMessage("Jumuah"),
        "prayer_maghrib": MessageLookupByLibrary.simpleMessage("Maghrib"),
        "prayer_maghrib_ar": MessageLookupByLibrary.simpleMessage("مغرب"),
        "prayer_maghrib_en": MessageLookupByLibrary.simpleMessage("Maghrib"),
        "prayer_sunrise": MessageLookupByLibrary.simpleMessage("Sunrise"),
        "prayer_sunrise_ar": MessageLookupByLibrary.simpleMessage("شروق"),
        "prayer_sunrise_en": MessageLookupByLibrary.simpleMessage("Sunrise"),
        "profile_email": MessageLookupByLibrary.simpleMessage("Email"),
        "profile_new_password":
            MessageLookupByLibrary.simpleMessage("New Password"),
        "profile_password":
            MessageLookupByLibrary.simpleMessage("Current Password"),
        "profile_phone_hint": MessageLookupByLibrary.simpleMessage(
            "Please ensure you enter your correct number. Tech support will use it to contact you and ensure your account and mosque remain active."),
        "profile_phone_label":
            MessageLookupByLibrary.simpleMessage("Contact Phone Number"),
        "profile_save_changes":
            MessageLookupByLibrary.simpleMessage("Save Changes"),
        "profile_terminate_hint": MessageLookupByLibrary.simpleMessage(
            "Note: Changing password automatically signs out most other sessions."),
        "profile_terminate_other":
            MessageLookupByLibrary.simpleMessage("Terminate other sessions"),
        "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
        "register_button":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "register_link": MessageLookupByLibrary.simpleMessage(
            "Don\'t have an account? Register now"),
        "register_subtitle": MessageLookupByLibrary.simpleMessage(
            "Join Miqat system as a mosque administrator"),
        "register_title":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "register_type_existing":
            MessageLookupByLibrary.simpleMessage("Join Existing Mosque"),
        "register_type_new":
            MessageLookupByLibrary.simpleMessage("Register New Mosque"),
        "registration_phone": MessageLookupByLibrary.simpleMessage(
            "Phone Number (For fast contact)"),
        "registration_success_existing": MessageLookupByLibrary.simpleMessage(
            "Account created. Please contact support to link it to your mosque."),
        "registration_success_new": MessageLookupByLibrary.simpleMessage(
            "Account and mosque created successfully!"),
        "remaining_label": MessageLookupByLibrary.simpleMessage("Remaining"),
        "required_field": MessageLookupByLibrary.simpleMessage("Required"),
        "restart_action": MessageLookupByLibrary.simpleMessage("Restart"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "save_design_settings":
            MessageLookupByLibrary.simpleMessage("Save design settings"),
        "save_general_settings":
            MessageLookupByLibrary.simpleMessage("Save general settings"),
        "save_iqama_settings":
            MessageLookupByLibrary.simpleMessage("Save iqama settings"),
        "saved_successfully":
            MessageLookupByLibrary.simpleMessage("Saved successfully"),
        "saving": MessageLookupByLibrary.simpleMessage("Saving…"),
        "scan_qr_hint":
            MessageLookupByLibrary.simpleMessage("Scan for details"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "select_date": MessageLookupByLibrary.simpleMessage("Select date"),
        "settings_drawer_tagline": MessageLookupByLibrary.simpleMessage(
            "Prayer times · display control"),
        "settings_language":
            MessageLookupByLibrary.simpleMessage("App language"),
        "settings_navigate_sections":
            MessageLookupByLibrary.simpleMessage("Sections"),
        "settings_title":
            MessageLookupByLibrary.simpleMessage("Mosque settings"),
        "sign_out": MessageLookupByLibrary.simpleMessage("Sign out"),
        "sign_out_tooltip": MessageLookupByLibrary.simpleMessage("Sign out"),
        "smart_screen_disabled":
            MessageLookupByLibrary.simpleMessage("Smart screen mode disabled"),
        "smart_screen_enabled":
            MessageLookupByLibrary.simpleMessage("Smart screen mode enabled"),
        "splash_app_tagline":
            MessageLookupByLibrary.simpleMessage("Mosque Smart Display"),
        "tab_about": MessageLookupByLibrary.simpleMessage("About App"),
        "tab_adhkar": MessageLookupByLibrary.simpleMessage("Dhikr"),
        "tab_alerts": MessageLookupByLibrary.simpleMessage("Instant Alerts"),
        "tab_announcements":
            MessageLookupByLibrary.simpleMessage("Announcements"),
        "tab_design": MessageLookupByLibrary.simpleMessage("Design"),
        "tab_duas": MessageLookupByLibrary.simpleMessage("Supplications"),
        "tab_general": MessageLookupByLibrary.simpleMessage("General"),
        "tab_hadith": MessageLookupByLibrary.simpleMessage("Hadith"),
        "tab_iqama": MessageLookupByLibrary.simpleMessage("Iqama"),
        "tab_profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "tab_update": MessageLookupByLibrary.simpleMessage("App Update"),
        "tab_verses": MessageLookupByLibrary.simpleMessage("Verses"),
        "tawakkul_quote": MessageLookupByLibrary.simpleMessage(
            "«And whoever relies upon Allah — then He is sufficient for him»"),
        "unit_seconds": MessageLookupByLibrary.simpleMessage("s"),
        "update_current_version": m8,
        "update_download":
            MessageLookupByLibrary.simpleMessage("Download & Install Update"),
        "update_downloading": m9,
        "update_failure": MessageLookupByLibrary.simpleMessage(
            "Download failed. Please try again later."),
        "update_latest_version": m10,
        "update_no_link": MessageLookupByLibrary.simpleMessage(
            "No download link available for this platform."),
        "update_success": MessageLookupByLibrary.simpleMessage(
            "Download complete! Installing..."),
        "update_title":
            MessageLookupByLibrary.simpleMessage("New Update Available!"),
        "update_up_to_date":
            MessageLookupByLibrary.simpleMessage("Your app is up to date"),
        "upload_image": MessageLookupByLibrary.simpleMessage("Upload image"),
        "use_current_location":
            MessageLookupByLibrary.simpleMessage("Use current location"),
        "validation_email_invalid":
            MessageLookupByLibrary.simpleMessage("Invalid email format"),
        "validation_email_required":
            MessageLookupByLibrary.simpleMessage("Please enter your email"),
        "validation_font_size_range": MessageLookupByLibrary.simpleMessage(
            "Enter a value between 8 and 96"),
        "validation_mosque_id_required": MessageLookupByLibrary.simpleMessage(
            "Mosque ID is required for a new mosque"),
        "validation_password_required":
            MessageLookupByLibrary.simpleMessage("Please enter your password"),
        "validation_password_short": MessageLookupByLibrary.simpleMessage(
            "Password must be at least 6 characters"),
        "verse_delete_body": MessageLookupByLibrary.simpleMessage(
            "This will remove it from the list. Save to server when you are ready."),
        "verse_delete_title":
            MessageLookupByLibrary.simpleMessage("Remove verse?"),
        "verse_editor_title_edit":
            MessageLookupByLibrary.simpleMessage("Edit verse"),
        "verse_editor_title_new":
            MessageLookupByLibrary.simpleMessage("New verse"),
        "verse_empty_subtitle": MessageLookupByLibrary.simpleMessage(
            "Add verses to rotate below the prayer times on the display."),
        "verse_empty_title":
            MessageLookupByLibrary.simpleMessage("No verses yet"),
        "verse_fab_add": MessageLookupByLibrary.simpleMessage("New verse"),
        "verse_narrator":
            MessageLookupByLibrary.simpleMessage("Context or surah"),
        "verse_save_bar_hint": MessageLookupByLibrary.simpleMessage(
            "Changes are local until you sync with the server."),
        "verse_source":
            MessageLookupByLibrary.simpleMessage("Source (optional)"),
        "verse_text": MessageLookupByLibrary.simpleMessage("Verse text")
      };
}

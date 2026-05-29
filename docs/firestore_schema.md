# Tebyan — Firestore Schema

This document describes the complete Firestore data model used by the Tebyan
mosque-display app. It is the contract between the app and the backend team.

Conventions used throughout:

- **Field keys are stored exactly as written** (snake_case). They are defined
  centrally in `lib/core/constants/firestore_schema.dart`.
- **Timestamps** are written as Firestore `Timestamp` (server time) and read
  defensively: the app accepts either a Firestore `Timestamp`, an ISO-8601
  string, or epoch milliseconds (`int`). Prefer `Timestamp`.
- **Enums** are stored as short string codes (see each field's "Values").
- **Colors** are stored as hex strings including the leading `#`
  (e.g. `#1B5E3B`).
- **Defaults** listed are the values the app falls back to when a field is
  missing. The backend should still write explicit values.
- Fields marked **legacy / read-only** are accepted on read for backward
  compatibility but are not written by the current app. Do not rely on them for
  new data.

---

## Collections overview

| Collection | Document ID | Purpose |
|---|---|---|
| `mosques` | mosque ID (auto / assigned) | One document per mosque: location, prayer config, design, content, ads, alerts, album. |
| `app_settings` | `global` (single doc) | App-wide settings: support phone, background library, About content, update info. |
| `platform_announcements` | per-announcement docs + one `settings_announcements` doc | Platform-level full-screen display announcements, plus in-app settings banners. |
| `users` | Firebase Auth UID | Per-user record: email, phone, active mosque, FCM tokens. |

---

## 1. Collection: `mosques`

**Path:** `mosques/{mosqueId}`
**Document ID:** the mosque ID (also exposed as `MosqueModel.id`; not stored as a field).

### 1.1 Basic info

| Field | Type | Default | Notes |
|---|---|---|---|
| `name` | string | `""` | Mosque display name. |
| `city` | string | `""` | City name. |
| `latitude` | number (double) | `0.0` | Used for prayer-time calculation. |
| `longitude` | number (double) | `0.0` | Used for prayer-time calculation. |
| `calculation_method` | string | `MuslimWorldLeague` | Prayer calculation method name (adhan library). |
| `language_code` | string | _(unset)_ | UI language override for this mosque, e.g. `ar`, `en`. Written only when set. |
| `app_language_code` | string | _(unset)_ | **Legacy / read-only** alias for `language_code`. Read as fallback. |
| `last_seen` | Timestamp | _(null)_ | Last time the display device reported in. |
| `updated_at` | Timestamp | _(null)_ | Last document update time. |

> The constants file also defines `logo_url`, `admin_email`, and `created_at`.
> These are reserved keys and are **not currently read or written** by
> `MosqueModel`. Treat them as backend-managed metadata.

### 1.2 `prayer_offsets` (map)

Per-prayer minute adjustments applied to calculated times. Object stored under
the `prayer_offsets` key. All integers, default `0`.

| Key | Type | Default |
|---|---|---|
| `fajr` | int (minutes) | `0` |
| `sunrise` | int (minutes) | `0` |
| `dhuhr` | int (minutes) | `0` |
| `asr` | int (minutes) | `0` |
| `maghrib` | int (minutes) | `0` |
| `isha` | int (minutes) | `0` |

### 1.3 `iqama_offsets` (map)

Minutes between adhan and iqama per prayer. Object stored under the
`iqama_offsets` key.

| Key | Type | Default |
|---|---|---|
| `fajr` | int (minutes) | `20` |
| `dhuhr` | int (minutes) | `15` |
| `asr` | int (minutes) | `15` |
| `maghrib` | int (minutes) | `10` |
| `isha` | int (minutes) | `15` |
| `jummah` | int (minutes) | `30` |

### 1.4 `design_settings` (map)

A single flat map stored under the `design_settings` key. It combines several
logical groups (background, font sizes, colors, and timing) into one object.

#### 1.4.1 Background

| Key | Type | Default | Notes |
|---|---|---|---|
| `background_type` | string | `image` | Values: `image`, `color`, `album`. (Legacy `remote_url` / `remoteUrl` are read as `album`.) |
| `background_value` | string | `default` | Meaning depends on type: image preset ID (e.g. `01`), hex color (e.g. `#FF0000`), or album reference. |

#### 1.4.2 Font sizes

All doubles, default `20.0`. If a specific key is missing, the app falls back to
`base_font_size` (also default `20.0`).

| Key | Type | Default |
|---|---|---|
| `base_font_size` | double | `20.0` | **Read-only fallback** for any missing size below. Not written. |
| `clock_font_size` | double | `20.0` |
| `mosque_info_font_size` | double | `20.0` |
| `prayers_font_size` | double | `20.0` |
| `announcements_font_size` | double | `20.0` |
| `religious_content_font_size` | double | `20.0` | Legacy alias `content_font_size` read as fallback. |
| `alerts_font_size` | double | `20.0` |
| `countdown_font_size` | double | `20.0` |

#### 1.4.3 Colors

All hex strings with leading `#`.

| Key | Type | Default |
|---|---|---|
| `primary_color` | string (hex) | `#1B5E3B` |
| `secondary_color` | string (hex) | `#E8F5E9` |
| `active_card_color` | string (hex) | `#C8E6C9` |
| `active_card_text_color` | string (hex) | `#1B5E3B` |
| `prayer_overlay_color` | string (hex) | `#E8F5E9` |
| `inactive_card_text_color` | string (hex) | `#2E7D32` |

#### 1.4.4 Timing & misc

| Key | Type | Default | Notes |
|---|---|---|---|
| `ticker_speed` | double | `1.0` | Bottom ticker scroll speed multiplier. |
| `strip_speed` | double | `1.0` | Strip scroll speed multiplier. |
| `numeral_format` | string | `en` | Values: `en` (Western digits), `ar` (Arabic-Indic digits). |
| `font_family` | string | `Beiruti` | Display font family name. |
| `pre_adhan_minutes` | int | `5` | Lead-in countdown window before adhan. |
| `adhan_moment_duration_seconds` | int | `60` | How long the adhan-moment screen stays. |
| `religious_content_wait_seconds` | int | `120` | Idle wait before showing religious content. |
| `religious_content_display_seconds` | int | `30` | How long each religious content item shows. |
| `prayer_card_scale` | double | `1.0` | Prayer-card scale on the display (range 0.5–2.0). |

### 1.5 Religious text lists

Four arrays of objects. Each array uses the **same** element shape
(`MosqueTextEntryModel`). Keys: `hadiths`, `verses`, `duas`, `adhkar`.

Each element:

| Key | Type | Default | Notes |
|---|---|---|---|
| `id` | string | _(generated)_ | If missing/empty, the app generates a stable fallback ID. |
| `narrator` | string | `""` | Attribution / narrator (الراوي). |
| `text` | string | `""` | The body text. |
| `source` | string | `""` | Source reference. |
| `is_active` | bool | `true` | Whether shown in rotation. |
| `order` | int | `0` | Sort order. |

### 1.6 Ads & alerts

Two arrays of `AnnouncementModel` objects:

- `mosque_ads` — regular mosque announcements (ads).
- `active_alerts` — saved high-priority alerts (published full-screen on demand).

Each element (`AnnouncementModel`):

| Key | Type | Default | Notes |
|---|---|---|---|
| `id` | string | `""` | Element ID (stored inside the object). |
| `title` | string | `""` | |
| `subtitle` | string | _(null)_ | Optional. |
| `start_date` | Timestamp | _now_ | When the item becomes valid. |
| `end_date` | Timestamp | _now + 1h_ | When the item expires. |
| `qr_code_url` | string | _(null)_ | Optional QR target URL. |
| `is_active` | bool | `true` | |
| `order` | int | `0` | Sort order. |
| `is_priority` | bool | `false` | Priority alerts render full-screen, overriding regular content. |
| `display_duration_seconds` | int | `30` | How long to show once it enters view. |
| `is_published` | bool | `false` | Whether currently published to the display. |
| `published_at` | Timestamp | _(null)_ | Last publish time. |
| `publish_duration_seconds` | int | `30` | How long to show while published. |

### 1.7 Album & published image

| Field | Type | Default | Notes |
|---|---|---|---|
| `album_image_urls` | array<string> | `[]` | Unified image URL list (used for background cycling and fullscreen). **Authoritative when present**, even if empty. |
| `photo_studio_urls` | array<string> | — | **Legacy / read-only.** Merged only when `album_image_urls` is absent. |
| `background_album_urls` | array<string> | — | **Legacy / read-only.** Merged only when `album_image_urls` is absent. |
| `published_album_url` | string | _(null)_ | Currently published fullscreen image URL. |
| `published_album_at` | Timestamp | _(null)_ | When the image was published. |
| `published_album_duration` | int (seconds) | `30` | How long to show the published image. |
| `published_album_fit` | string | `contain` | `BoxFit` enum name: `contain`, `cover`, `fill`, `fitWidth`, `fitHeight`. |

---

## 2. Collection: `app_settings`

**Path:** `app_settings/global` (a single well-known document).

| Field | Type | Default | Notes |
|---|---|---|---|
| `support_phone` | string | `""` | Support contact phone. |
| `background_folder_url` | string | _(unset)_ | Optional remote folder of background images. Written only when set. |
| `background_library_urls` | array<string> | `[]` | Selectable background image URLs (replaces old hardcoded asset presets). Written only when non-empty. |
| `about_categories` | array<map> | `[]` | About-screen content (see 2.1). |
| `update` | map | _(see 2.2)_ | App update info. |

> **Legacy / read-only:** if `update` is absent, the app builds it from
> top-level `latest_version` and `update_message`. Prefer writing the `update`
> map.

### 2.1 `about_categories` element (`AboutCategoryModel`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `title` | string | `""` | Category title. |
| `sections` | array<map> | `[]` | Ordered content sections (see below). |

Each section (`AboutSectionModel`):

| Key | Type | Default | Notes |
|---|---|---|---|
| `type` | string | `text` | Values: `text`, `link`, `qr`. |
| `content` | string | `""` | Text body / URL / QR payload depending on type. |
| `font_size` | double | `14.0` | |
| `font_weight` | string | `thin` | Values: `thin`, `bold`. |

### 2.2 `update` map (`AppUpdateModel`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `latest_version` | string | `1.0.0` | Latest available version. |
| `android_link` | string | `""` | Download URL. |
| `windows_link` | string | `""` | Download URL. |
| `ios_link` | string | `""` | Download URL. |
| `macos_link` | string | `""` | Download URL. |
| `linux_link` | string | `""` | Download URL. |
| `release_notes` | string | `""` | Release notes text. |

---

## 3. Collection: `platform_announcements`

This collection holds two different kinds of data:

1. **Display announcements** — every document in the collection **except** the
   document whose ID is `settings_announcements`. Each such document is an
   `AnnouncementModel` (same shape as section 1.6) and is shown full-screen on
   the display.
2. **Settings announcements** — one special document with ID
   `settings_announcements`, holding an `items` array of in-app banner objects.

### 3.1 Display announcement documents

**Path:** `platform_announcements/{announcementId}` (any ID other than
`settings_announcements`).

Same fields as the `AnnouncementModel` element in section 1.6 (`id`, `title`,
`subtitle`, `start_date`, `end_date`, `qr_code_url`, `is_active`, `order`,
`is_priority`, `display_duration_seconds`, `is_published`, `published_at`,
`publish_duration_seconds`).

### 3.2 Settings announcements document

**Path:** `platform_announcements/settings_announcements`

| Field | Type | Notes |
|---|---|---|
| `items` | array<map> | List of `SettingsAnnouncementModel` banners. |

Each element (`SettingsAnnouncementModel`):

| Key | Type | Default | Notes |
|---|---|---|---|
| `id` | string | _(fallback)_ | Banner ID. |
| `title` | string | `""` | Legacy aliases read: `headline`. |
| `body` | string | _(null)_ | Legacy aliases read: `subtitle`, `message`. |
| `image_url` | string | _(null)_ | Legacy aliases read: `imageUrl`, `image`, and `url` (when no explicit image). |
| `link_url` | string | _(null)_ | Legacy aliases read: `linkUrl`, `link`, `href`, `cta_url`, `ctaUrl`, `target_url`, `targetUrl`. |
| `is_active` | bool | `true` | Legacy alias read: `active`. |
| `order` | int | `0` | Sort order. |
| `start_date` | Timestamp | _(null)_ | Optional visibility start. Legacy alias read: `startDate`. |
| `end_date` | Timestamp | _(null)_ | Optional visibility end (exclusive). Legacy alias read: `endDate`. |

> The app writes the canonical snake_case keys (`title`, `body`, `image_url`,
> `link_url`, `is_active`, `order`, `start_date`, `end_date`). The camelCase /
> alternate keys are **read-only** for backward compatibility — do not write
> them for new data.

---

## 4. Collection: `users`

**Path:** `users/{uid}` where `{uid}` is the Firebase Auth UID.

| Field | Type | Notes |
|---|---|---|
| `email` | string | User email. |
| `phone` | string | User phone (updated from the profile screen). |
| `active_mosque_id` | string | The mosque this user currently administers / displays. |
| `fcm_token` | string | **Deprecated** single-token field. Still written via merge for backward compatibility. |
| `fcm_tokens` | array<string> | Canonical set of FCM tokens (appended via `arrayUnion`). |
| `fcm_token_updated_at` | Timestamp | Server timestamp of the last token write. |

> On FCM token save the app performs a merge-write of `fcm_token`,
> `fcm_tokens` (arrayUnion), and `fcm_token_updated_at` (server timestamp).
> Prefer `fcm_tokens` (array) for push targeting; `fcm_token` is legacy.

---

## Appendix A — Enum value reference

| Enum | Field(s) | Stored values |
|---|---|---|
| Numeral format | `numeral_format` | `en`, `ar` |
| Background type | `background_type` | `image`, `color`, `album` (legacy: `remote_url`, `remoteUrl` → `album`) |
| Box fit | `published_album_fit` | `contain`, `cover`, `fill`, `fitWidth`, `fitHeight` |
| About section type | `type` (about section) | `text`, `link`, `qr` |
| About section weight | `font_weight` (about section) | `thin`, `bold` |

## Appendix B — Date/time handling

Any timestamp field is parsed by `parseDateOrMillis`, which accepts:

- Firestore `Timestamp` (preferred for writes),
- ISO-8601 `String`,
- epoch milliseconds as `int`.

The backend should write Firestore `Timestamp` values.

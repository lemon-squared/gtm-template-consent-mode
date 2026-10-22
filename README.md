# Lemon Signal — GTM Consent Mode template

Aligned with:

- [Custom templates quick start](https://developers.google.com/tag-platform/tag-manager/templates)
- [Consent Mode / Consent APIs](https://developers.google.com/tag-platform/tag-manager/templates/consent-apis)
- [Custom template permissions](https://developers.google.com/tag-platform/tag-manager/templates/permissions)

## Import (important)

Do **not** paste `template.tpl` into the **Code** tab. That treats the Terms text (`By creating…`) as JavaScript and errors with `missing ';' at 'By'`.

**Correct:**

1. Templates → **New** (tag template) → fill Name / Description if asked  
2. Top-right **⋮** (More actions) → **Import**  
3. Choose [`template.tpl`](./template.tpl)  
4. **Save** (GTM fills Permissions from the sandboxed APIs)

`template.tpl` must match a real GTM **Export** (UTF-8 BOM, typed `WEB_PERMISSIONS`, YAML `scenarios:` tests). Empty `[]` permissions/tests will make Import fail with **Error importing file**.

**Fallback** if Import still fails: Templates → New → paste only [`template.js`](./template.js) into **Code**, add Fields from the table below, **Save** (auto Permissions), then tighten cookie / listener / dataLayer keys.

## Quick-start editor checklist

| Editor tab | What to verify |
| --- | --- |
| **Info** | Name + description (≤200 chars). Optional: square icon ≥64×64, ≤50 kB PNG/JPEG/GIF |
| **Fields** | `defaultSettings` table, cookie name, redaction / URL passthrough, optional developer ID |
| **Code** | Sandboxed JS; uses Consent APIs + `data.gtmOnSuccess()` (required for Preview / sequencing) |
| **Permissions** | Auto-detected on **Save** from `require()`d APIs — then tighten |
| **Tests** | Run Code / Tests in the editor before publishing |

**After first import:** click **Save** so GTM refreshes permissions from the code, confirm cookie name + `LemonSignalAddConsentListener` execute + `write_data_layer` keys (`ads_data_redaction`, `url_passthrough`, `developer_id.*`), then **Run Code**. Prefer **Export** from GTM and re-commit the exported `.tpl` when you change the template in the UI (hand-edited `.tpl` can drift from GTM’s format).

## Consent / permissions map

| Google requirement | Ours |
| --- | --- |
| Safer than Custom HTML | Custom TAG template (sandboxed) |
| `setDefaultConsentState` / `updateConsentState` | Yes (not `gtag('consent')` in template) |
| Consent Initialization trigger | Documented / required |
| Region defaults table | Yes + GB+EEA built-in fallback |
| `wait_for_update: 500` | Yes |
| Cookie → update | `lemon_signal_consent` + `queryPermission('get_cookies', …)` |
| `callInWindow` listener | `LemonSignalAddConsentListener` + `queryPermission('access_globals', 'execute', …)` |
| `gtagSet` redaction / passthrough / developer_id | + `write_data_layer` permission |
| `data.gtmOnSuccess()` | Always |
| Unit tests | Built-in defaults, cookie restore, listener register |

## Setup

1. Import template → **Save** → refine Permissions → run Tests.
2. **Tags** → New → Lemon Signal Consent Mode.
3. **Trigger**: `Consent Initialization - All Pages`.
4. Fill **Default settings** (or leave empty for built-in GB+EEA deny).
5. Cookie name must match the site `StorageConfig.cookieName` (default `lemon_signal_consent`).
6. Optional redaction / URL passthrough. Leave developer ID blank unless you are a registered CMP.
7. Google tag / GA4 in the same container → Consent Settings → require `analytics_storage`.
8. Publish.

Server-side tags (Meta, Snap, TikTok, Reddit, and others) are separate template repos. They read Google consent state. They do not replace this tag. Each one gets the same files as this repo (`template.tpl`, `template.js`, `metadata.yaml`, `tests.yaml`) and a Tag Execution Consent Settings group: send always, or abort unless `ad_storage` is granted (`eventData.consent_state.ad_storage`, otherwise the third character of `x-ga-gcs`).

## Repository layout

| File | Role |
| --- | --- |
| `template.tpl` | File you import into GTM. Gallery submission reads this. |
| `template.js` | Sandboxed code. Must match `___SANDBOXED_JS_FOR_WEB_TEMPLATE___`. |
| `tests.yaml` | Unit tests. Must match `___TESTS___`. |
| `metadata.yaml` | Community Gallery versions. Add a `sha` only when `template.tpl` changes. |
| `biome.jsonc` | Ultracite Biome config. `bun run format` formats `template.js` and copies it into `template.tpl`. |
| `LICENSE` | Apache 2.0 |

## Site bridge

[`@lemon-squared/signal`](https://github.com/lemon-squared/signal) early bootstrap installs:

```js
window.LemonSignalAddConsentListener = function (cb) { /* … */ };
```

before React hydrates, so Consent Initialization can register the callback.

## Open Source

The Lemon Signal Consent Mode tag is developed and maintained by [Lemon Squared](https://github.com/lemon-squared) under the Apache 2.0 license.

### GTM Gallery Status
🔴 Not listed

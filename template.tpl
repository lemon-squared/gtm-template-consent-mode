___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Lemon Signal Consent Mode",
  "categories": [
    "ADVERTISING",
    "ANALYTICS",
    "UTILITY"
  ],
  "brand": {
    "id": "github.com_lemon-squared_signal",
    "displayName": "Lemon Squared Signal",
    "thumbnail": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAZUlEQVR42u3QQREAAAQAMEXkE1oYcjh7rMCisuezECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAgQIECBAgAABAu5bXkHiLIelPx0AAAAASUVORK5CYII="
  },
  "description": "Consent Mode v2 for Lemon Squared Signal. Uses setDefaultConsentState and updateConsentState. Trigger: Consent Initialization.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "PARAM_TABLE",
    "name": "defaultSettings",
    "displayName": "Default settings",
    "paramTableColumns": [
      {
        "param": {
          "type": "TEXT",
          "name": "region",
          "displayName": "Region (leave blank to have consent apply to all regions)",
          "simpleValueType": true
        },
        "isUnique": true
      },
      {
        "param": {
          "type": "TEXT",
          "name": "granted",
          "displayName": "Granted Consent Types (comma separated)",
          "simpleValueType": true
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "TEXT",
          "name": "denied",
          "displayName": "Denied Consent Types (comma separated)",
          "simpleValueType": true
        },
        "isUnique": false
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "cookieName",
    "displayName": "Signal consent cookie name",
    "simpleValueType": true,
    "defaultValue": "lemon_signal_consent",
    "help": "Must match site StorageConfig.cookieName."
  },
  {
    "type": "CHECKBOX",
    "name": "ads_data_redaction",
    "checkboxText": "Redact Ads Data",
    "simpleValueType": true
  },
  {
    "type": "CHECKBOX",
    "name": "url_passthrough",
    "checkboxText": "Pass through URL parameters",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "developerId",
    "displayName": "Google developer ID (CMP vendors only)",
    "simpleValueType": true,
    "help": "Leave blank for first-party use."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const queryPermission = require('queryPermission');
const setDefaultConsentState = require('setDefaultConsentState');
const updateConsentState = require('updateConsentState');
const getCookieValues = require('getCookieValues');
const callInWindow = require('callInWindow');
const gtagSet = require('gtagSet');
const JSON = require('JSON');

const COOKIE_NAME = data.cookieName || 'lemon_signal_consent';
const LISTENER_GLOBAL = 'LemonSignalAddConsentListener';

const splitInput = (input) => {
  if (!input) return [];
  return input.split(',').map((entry) => entry.trim()).filter((entry) => entry.length !== 0);
};

const parseCommandData = (settings) => {
  const regions = splitInput(settings.region);
  const granted = splitInput(settings.granted);
  const denied = splitInput(settings.denied);
  const commandData = {};
  if (regions.length > 0) {
    commandData.region = regions;
  }
  granted.forEach((entry) => {
    commandData[entry] = 'granted';
  });
  denied.forEach((entry) => {
    commandData[entry] = 'denied';
  });
  return commandData;
};

const onUserConsent = (consent) => {
  if (!consent) {
    return;
  }
  updateConsentState({
    ad_storage: consent.adConsentGranted ? 'granted' : 'denied',
    ad_user_data: consent.adUserDataConsentGranted ? 'granted' : 'denied',
    ad_personalization: consent.adPersonalizationConsentGranted ? 'granted' : 'denied',
    analytics_storage: consent.analyticsConsentGranted ? 'granted' : 'denied',
    functionality_storage: consent.functionalityConsentGranted ? 'granted' : 'denied',
    personalization_storage: consent.personalizationConsentGranted ? 'granted' : 'denied',
    security_storage: consent.securityConsentGranted ? 'granted' : 'denied'
  });
};

const applyBuiltInDefaults = () => {
  setDefaultConsentState({
    ad_storage: 'granted',
    ad_user_data: 'granted',
    ad_personalization: 'granted',
    analytics_storage: 'granted',
    personalization_storage: 'granted',
    functionality_storage: 'granted',
    security_storage: 'granted',
    wait_for_update: 500
  });
  setDefaultConsentState({
    ad_storage: 'denied',
    ad_user_data: 'denied',
    ad_personalization: 'denied',
    analytics_storage: 'denied',
    personalization_storage: 'denied',
    functionality_storage: 'granted',
    security_storage: 'granted',
    region: [
      'GB', 'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR',
      'HU', 'IE', 'IS', 'IT', 'LV', 'LI', 'LT', 'LU', 'MT', 'NL', 'NO', 'PL', 'PT',
      'RO', 'SK', 'SI', 'ES', 'SE'
    ],
    wait_for_update: 500
  });
};

const applyGtagSetOptions = () => {
  if (queryPermission('write_data_layer', 'ads_data_redaction')) {
    gtagSet('ads_data_redaction', !!data.ads_data_redaction);
  }
  if (queryPermission('write_data_layer', 'url_passthrough')) {
    gtagSet('url_passthrough', !!data.url_passthrough);
  }
  if (data.developerId) {
    if (queryPermission('write_data_layer', 'developer_id')) {
      gtagSet('developer_id.' + data.developerId, true);
    }
  }
};

const restoreFromCookie = () => {
  if (!queryPermission('get_cookies', COOKIE_NAME)) {
    return;
  }
  const cookieValues = getCookieValues(COOKIE_NAME);
  if (!(cookieValues && cookieValues.length > 0)) {
    return;
  }
  const settings = JSON.parse(cookieValues[0]);
  if (settings) {
    onUserConsent(settings);
  }
};

const registerListener = () => {
  if (!queryPermission('access_globals', 'execute', LISTENER_GLOBAL)) {
    log('Lemon Signal: missing execute permission for', LISTENER_GLOBAL);
    return;
  }
  callInWindow(LISTENER_GLOBAL, onUserConsent);
};

const main = () => {
  log('Lemon Signal consent template data =', data);

  applyGtagSetOptions();

  const rows = data.defaultSettings;
  if (rows && rows.length > 0) {
    rows.forEach((settings) => {
      const defaultData = parseCommandData(settings);
      defaultData.wait_for_update = 500;
      setDefaultConsentState(defaultData);
    });
  } else {
    applyBuiltInDefaults();
  }

  restoreFromCookie();
  registerListener();

  data.gtmOnSuccess();
};

main();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "LemonSignalAddConsentListener"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "lemon_signal_consent"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_user_data"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "ad_personalization"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "analytics_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "functionality_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "personalization_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "consentType"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "security_storage"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "write_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "ads_data_redaction"
              },
              {
                "type": 1,
                "string": "url_passthrough"
              },
              {
                "type": 1,
                "string": "developer_id.*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Applies built-in defaults and finishes
  code: |-
    const mockData = {
      cookieName: 'lemon_signal_consent',
      ads_data_redaction: false,
      url_passthrough: false
    };

    mock('queryPermission', () => true);
    mock('setDefaultConsentState', () => {});
    mock('updateConsentState', () => {});
    mock('getCookieValues', () => []);
    mock('callInWindow', () => {});
    mock('gtagSet', () => {});
    mock('logToConsole', () => {});

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();


___NOTES___

Import into a WEB container as a TAG template.
Trigger tags on Consent Initialization - All Pages.
Site must install window.LemonSignalAddConsentListener via @lemon-squared/signal.



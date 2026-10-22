const log = require("logToConsole");
const queryPermission = require("queryPermission");
const setDefaultConsentState = require("setDefaultConsentState");
const updateConsentState = require("updateConsentState");
const getCookieValues = require("getCookieValues");
const callInWindow = require("callInWindow");
const gtagSet = require("gtagSet");
const JSON = require("JSON");

const COOKIE_NAME = data.cookieName || "lemon_signal_consent";
const LISTENER_GLOBAL = "LemonSignalAddConsentListener";

const splitInput = (input) => {
  if (!input) return [];
  return input
    .split(",")
    .map((entry) => entry.trim())
    .filter((entry) => entry.length !== 0);
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
    commandData[entry] = "granted";
  });
  denied.forEach((entry) => {
    commandData[entry] = "denied";
  });
  return commandData;
};

const onUserConsent = (consent) => {
  if (!consent) {
    return;
  }
  updateConsentState({
    ad_personalization: consent.adPersonalizationConsentGranted
      ? "granted"
      : "denied",
    ad_storage: consent.adConsentGranted ? "granted" : "denied",
    ad_user_data: consent.adUserDataConsentGranted ? "granted" : "denied",
    analytics_storage: consent.analyticsConsentGranted ? "granted" : "denied",
    functionality_storage: consent.functionalityConsentGranted
      ? "granted"
      : "denied",
    personalization_storage: consent.personalizationConsentGranted
      ? "granted"
      : "denied",
    security_storage: consent.securityConsentGranted ? "granted" : "denied",
  });
};

const applyBuiltInDefaults = () => {
  setDefaultConsentState({
    ad_personalization: "granted",
    ad_storage: "granted",
    ad_user_data: "granted",
    analytics_storage: "granted",
    functionality_storage: "granted",
    personalization_storage: "granted",
    security_storage: "granted",
    wait_for_update: 500,
  });
  setDefaultConsentState({
    ad_personalization: "denied",
    ad_storage: "denied",
    ad_user_data: "denied",
    analytics_storage: "denied",
    functionality_storage: "granted",
    personalization_storage: "denied",
    region: [
      "GB",
      "AT",
      "BE",
      "BG",
      "HR",
      "CY",
      "CZ",
      "DK",
      "EE",
      "FI",
      "FR",
      "DE",
      "GR",
      "HU",
      "IE",
      "IS",
      "IT",
      "LV",
      "LI",
      "LT",
      "LU",
      "MT",
      "NL",
      "NO",
      "PL",
      "PT",
      "RO",
      "SK",
      "SI",
      "ES",
      "SE",
    ],
    security_storage: "granted",
    wait_for_update: 500,
  });
};

const applyGtagSetOptions = () => {
  if (queryPermission("write_data_layer", "ads_data_redaction")) {
    gtagSet("ads_data_redaction", !!data.ads_data_redaction);
  }
  if (queryPermission("write_data_layer", "url_passthrough")) {
    gtagSet("url_passthrough", !!data.url_passthrough);
  }
  if (data.developerId && queryPermission("write_data_layer", "developer_id")) {
    gtagSet("developer_id." + data.developerId, true);
  }
};

const restoreFromCookie = () => {
  if (!queryPermission("get_cookies", COOKIE_NAME)) {
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
  if (!queryPermission("access_globals", "execute", LISTENER_GLOBAL)) {
    log("Lemon Signal: missing execute permission for", LISTENER_GLOBAL);
    return;
  }
  callInWindow(LISTENER_GLOBAL, onUserConsent);
};

const main = () => {
  log("Lemon Signal consent template data =", data);

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

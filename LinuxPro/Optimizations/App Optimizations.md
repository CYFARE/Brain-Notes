# Linux Application Improvements

## Remove Snaps from Ubuntu

### Firefox Deb Package

Before removing snaps, make sure to add Firefox PPA and config to stop snap reinstall by APT if you try ```sudo apt install firefox```. Follow the steps.

#### Add Firefox PPA

```bash
sudo add-apt-repository ppa:mozillateam/ppa
```

#### Add Firefox Package Priority Config

Paste the following in terminal at one go and press Enter:

```bash
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap1-0ubuntu2
Pin-Priority: -1
' | sudo tee /etc/apt/preferences.d/mozilla-firefox
```

#### Remove Firefox snap

```bash
sudo snap remove firefox
```

#### Install firefox using apt

```bash
sudo apt install firefox
```

#### Add unattended-upgrades config for Firefox

In terminal: 

```bash
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
```

### Remove snaps & snapd

#### List installated packages

```bash
sudo snap list
```

#### Remove package one by one

```bash
sudo snap remove package_name
```

#### Remove snapd completely

```bash
sudo rm -rf /var/cache/snapd/
sudo apt autoremove --purge snapd gnome-software-plugin-snap
rm -fr ~/snap
sudo apt-mark hold snapd
```

## LibreOffice Security Improvements
1. Remove personal information on save
2. Ctrl+click required to open links
3. Macro security - block links from untrusted documents
4. Macro security - very high
5. Disabled 'execution of vba code' in Word & Excel
6. Security warninigs:
	1. When saving and sending file
	2. When signing file
	3. When printing
	4. When creating PDF

## Flatpak Configurations

### Font fix

To fix font or graphical issues, use the following:

```bash
sudo apt install xdg-desktop-portal-gtk
```

### Pinta crash fix

```bash
sudo apt install mono-devel
```

## Firefox Configurations
### Configurations: Misc
```
dom.event.contextmenu.enabled = false
	Don't allow websites to prevent use of right-click, 
	or otherwise messing with the context menu.

dom.event.clipboardevents.enabled = false
	Don't allow websites to prevent copy and paste.
	Disable notifications of copy, paste, or cut functions. 
        Stop webpage knowing which part of the page had been selected.

network.IDN_show_punycode = true
	Show punycode. Help protect from character 'spoofing' eg:
	xn--80ak6aa92e.com -> аррӏе.com
	[IDN homograph attacks](https://www.xudongz.com/blog/2017/idn-phishing/)

browser.uidensity = 1
	Get dense tabs back! - recommended
```

### Configurations: Privacy
```
plugins.enumerable_names = blank
	Disable site reading installed plugins.

network.http.sendRefererHeader = 1
	Tells website where you came from. Disabling may break some sites.
	0 = Disable referrer headers. 
	1 = Send only on clicked links.
	2 = (default) Send for links and image.
        
network.http.sendSecureXSiteReferrer = false
        Disable referrer headers between https websites.
		
network.http.referer.spoofSource = true
	Send fake referrer (if choose to send referrers).
		
privacy.trackingprotection.enabled = true
        Mozilla’s built in tracking protection.
		
geo.enabled = false
geo.wifi.uri = blank
browser.search.geoip.url = blank
        Disables geolocation and firefox logging geolocation requests.


browser.safebrowsing.enabled = false
browser.safebrowsing.phishing.enabled = false
browser.safebrowsing.malware.enabled = false	
browser.safebrowsing.downloads.enabled = false
browser.safebrowsing.provider.google4.dataSharing.enabled = blank
browser.safebrowsing.provider.google4.updateURL = blank
browser.safebrowsing.provider.google4.reportURL = blank
browser.safebrowsing.provider.google4.reportPhishMistakeURL = blank
browser.safebrowsing.provider.google4.reportMalwareMistakeURL = blank
browser.safebrowsing.provider.google4.lists = blank
browser.safebrowsing.provider.google4.gethashURL = blank
browser.safebrowsing.provider.google4.dataSharingURL = blank
browser.safebrowsing.provider.google4.dataSharing.enabled = false
browser.safebrowsing.provider.google4.advisoryURL = blank
browser.safebrowsing.provider.google4.advisoryName = blank
browser.safebrowsing.provider.google.updateURL = blank
browser.safebrowsing.provider.google.reportURL = blank
browser.safebrowsing.provider.google.reportPhishMistakeURL = blank
browser.safebrowsing.provider.google.reportMalwareMistakeURL = blank
browser.safebrowsing.provider.google.pver = blank
browser.safebrowsing.provider.google.lists = blank
browser.safebrowsing.provider.google.gethashURL = blank
browser.safebrowsing.provider.google.advisoryURL = blank
browser.safebrowsing.downloads.remote.url = blank
        Disable Google Safe Browsing and malware and phishing protection.
	Stop sending links and downloading lists from google.	
	Security risk, but privacy improvement.
	Note: this list may be incomplete as firefox updates, be sure to search for browser.safebrowsing.provider.google*
	Also simply setting safebrowsing.*.enabled to false should make setting the URL's to blank redundant, but better to be safe.
	If you see anything pointing google, probably best to nuke it.


browser.selfsupport.url = blank
browser.aboutHomeSnippets.updateUrL = blank
browser.startup.homepage_override.mstone = ignore
browser.startup.homepage_override.buildID = blank
startup.homepage_welcome_url = blank
startup.homepage_welcome_url.additional = blank
startup.homepage_override_url = blank
	Can call home to every time firefox is started or home page is visited.
	https://support.mozilla.org/en-US/kb/how-stop-firefox-making-automatic-connections
	http://kb.mozillazine.org/Connections_established_on_startup_-_Firefox


toolkit.telemetry.cachedClientID = blank

browser.send_pings = false
	Prevent website tracking clicks.
		
browser.send_pings.require_same_host = true
	Only send pings if send and receiving host match (same website).
        
dom.battery.enabled = false
	Disable website reading how much battery your mobile device or laptop has.

network.cookie.alwaysAcceptSessionCookies = false
        Disables acceptance of session cookies.
		
network.cookie.cookieBehavior
        Disable cookies.
        0 = All cookies are allowed. (Default) 
        1 = Only cookies from the originating server are allowed. (block third party cookies)
        2 = No cookies are allowed. 
	3 = Third-party cookies are allowed only if that site has stored cookies already from a previous visit 
			
network.cookie.lifetimePolicy 
        cookies are deleted at the end of the session
        0 = The cookie's lifetime is supplied by the server. (Default) 
        1 = The user is prompted for the cookie's lifetime. 
        2 = The cookie expires at the end of the session (when the browser closes). 
        3 = The cookie lasts for the number of days specified by network.cookie.lifetime.days.   

network.dnsCacheEntries = 100
        Number of cached DNS entries. Lower number = More requests but less data stored.
    
network.dnsCacheExpiration = 60
        Time DNS entries are cached in seconds.
    
places.history.enabled = false
        Disables recording of visited websites.
    
browser.formfill.enable = false
        Disables saving of form data.
    
browser.cache.disk.enable = false
        Disables caching on hardrive.
    
browser.cache.disk_cache_ssl = false
        Disables caching for ssl connections.
    
browser.cache.memory.enable = false
        Disables caching in memory.
   
browser.cache.offline.enable = false
        Disables offline cache.
    
network.dns.disableIPv6 = true
        If your OS or ISP does not support IPv6, there is no reason to have this preference set to false. 

network.predictor.enabled = false
network.dns.disablePrefetch = true   
network.prefetch-next = false
        Link prefetching is when a webpage hints to the browser that certain pages are likely to be visited, 
	so the browser downloads them immediately so they can be displayed immediately when the user requests it. 

network.http.speculative-parallel-limit = 0
	Disable prefetch link on hover.
	
media.peerconnection.enabled = false    
network.websocket.enabled = false
        WebSockets is a technology that makes it possible to open an interactive communication 
        session between the user's browser and a server. (May leak IP when using proxy/VPN)
   
loop.enabled = false
	Disable 3rd party closed-source Hello integration.
	Note: only affects older versions of firefox as "Hello" has been discontinued as in favor of webrtc: https://support.mozilla.org/en-US/kb/hello-status
	
extensions.pocket.enabled = false
extensions.pocket.site = blank
extensions.pocket.oAuthConsumerKey = blank
extensions.pocket.api = blank
	Disable 3rd party closed-source Pocket integration.
	Note, this is browser.pocket.enabled for older versions of firefox
```

### Configurations: Performance
```
layout.frame_rate.precise = true
	Increases animation speed. May mitigate choppy scrolling.
	
webgl.force-enabled = true
layers.acceleration.force-enabled = true
layers.offmainthreadcomposition.enabled = true
layers.offmainthreadcomposition.async-animations = true
layers.async-video.enabled = true
html5.offmainthread = true
	Enable Hardware Acceleration and Off Main Thread Compositing (OMTC).
	It's likely your browser is already set to use these features.
	May introduce instability on some hardware.
```

### Configurations: Reduce RAM Usage (Not Recommended)
```
browser.cache.memory.capacity = xx
	Limit memory cache size. (xx = value in MB)
	
browser.sessionhistory.max_entries = xx
	Limit maximum pages in session history. (how many URLs you can traverse using the Forward or Back button)
	
browser.sessionstore.max_tabs_undo = xx
	Limit max closed tabs you can reopen.
	
browser.tabs.animate = false
browser.download.animateNotifications = false
	Disable some animations.
	
config.trim_on_minimize = true
	Reduce memory usage when minimized. (Windows only)
	
image.mem.max_decoded_image_kb = xx
	How much info Firefox stores of uncompressed images.
	Higher value = improve speed at the expense of increased memory usage.
	
javascript.options.mem.max == xx
	Limit amount of memory javascript may consume.
	-1 = Automatic

javascript.options.mem.high_water_mark == xx
	Tell garbage collector to start running when javascript is using xx MB of memory. 
	Garbage collection releases memory back to the system.
```

### Configurations: Random Privacy
```
privacy.trackingprotection.enabled;true
browser.tabs.loadInBackground;false
webgl.disabled;true
media.peerconnection.ice.no_host;true
media.peerconnection.ice.proxy_only;true
privacy.clearOnShutdown.cookies;true
network.cookie.lifetimePolicy;2
network.cookie.thirdparty.sessionOnly;true
network.cookie.thirdparty.nonsecureSessionOnly;true
network.http.referer.XOriginPolicy;1
network.http.referer.XOriginTrimmingPolicy;2
network.http.referer.userControlPolicy;2
network.http.referer.defaultPolicy;2
network.http.referer.defaultPolicy.pbmode;2
places.history.enabled;false
browser.storageManager.enabled;true
dom.storageManager.enabled;true
dom.caches.enabled;false
browser.search.suggest.enabled;false
geo.enabled;false
camera.control.face_detection.enabled;false
browser.urlbar.trimURLs;false
network.proxy.socks_remote_dns;true
plugin.state.flash;0
plugin.state.java;0
network.IDN_show_punycode;true
network.standard-url.punycode-host;true
experiments.supported;false
experiments.enabled;false
network.allow-experiments;false
browser.uitour.enabled;false
datareporting.healthreport.service.enabled;false
datareporting.healthreport.uploadEnabled;false
extensions.shield-recipe-client.enabled;false
network.predictor.enabled;false
network.http.speculative-parallel-limit;0
privacy.donottrackheader.enabled;true
privacy.firstparty.isolate;true
general.oscpu.override;Linux x86_64
general.platform.override;Linux x86_64
general.appversion.override;5.0 (X11)
general.buildID.override;20100101000000
general.useragent.locale;en-US
privacy.sanitize.sanitizeOnShutdown;true
privacy.sanitize.timeSpan;0
privacy.clearOnShutdown.offlineApps;true
privacy.clearOnShutdown.siteSettings;true
privacy.cpd.offlineApps;true
privacy.cpd.passwords;true
privacy.cpd.siteSettings;true
browser.cache.disk.capacity;0
browser.cache.disk.smart_size.enabled;false
browser.cache.disk.enable;false
signon.rememberSignons;false
browser.formfill.enable;false
browser.newtabpage.enabled;false
browser.newtabpage.enhanced;false
security.tls.version.max;4
security.tls.unrestricted_rc4_fallback;false
security.ssl.treat_unsafe_negotiation_as_broken;true
dom.enable_performance;false
offline-apps.allow_by_default;false
dom.mozTCPSocket.enabled;false
dom.netinfo.enabled;false
dom.telephony.enabled;false
beacon.enabled;false
browser.send_pings;false
security.xpconnect.plugin.unrestricted;false
media.video_stats.enabled;false
browser.safebrowsing.downloads.remote.enabled;false
network.captive-portal-service.enabled;false
browser.sessionstore.privacy_level;2
security.ask_for_password;2
security.password_lifetime;1
security.cert_pinning.enforcement_level;2
security.pki.sha1_enforcement_level;1
security.ssl3.dhe_rsa_aes_128_sha;false
security.ssl3.ecdhe_ecdsa_aes_128_gcm_sha256;false
security.ssl3.ecdhe_ecdsa_aes_128_sha;false
security.ssl3.ecdhe_rsa_aes_128_sha;false
security.ssl3.rsa_des_ede3_sha;false
browser.link.open_newwindow.restriction;0
extensions.pocket.enabled;false
media.eme.enabled;false
social.enabled;false
social.directories;
social.remote-install.enabled;false
social.share.activationPanelEnabled;false
social.shareDirectory;
social.toast-notifications.enabled;false
social.whitelist;
browser.tabs.closeWindowWithLastTab;false
```

### Extensions:  Privacy
- Privacy Badger
- Decentraleyes
- HTTPS Everywhere
- Privacy Possum
- Canvas Blocker
- uBlock Origin
- GNU LibreJS
- Firefox Multi Account Container
- Firefox Relay
- User Agent Switcher
- Cookie Auto Delete
- CSS Exfil Protection
- Clear URLs

### Extensions:  Pentesting
- Retire.js
- Shodan.io
- Cookie Editor
- dotgit
- Wappalyzer
- iMacros
- FoxyProxy
- Firefox Multi Account Container
- User Agent Switcher

### Privacy User JS
- arkenfox - https://github.com/arkenfox/user.js


## Firefox about:config Profile Settings

```
app.normandy.api_url

app.normandy.enabled

false

app.normandy.first_run

false

app.normandy.migrationsApplied

12

app.normandy.shieldLearnMoreUrl

app.normandy.user_id

app.shield.optoutstudies.enabled

false

app.update.lastUpdateTime.addon-background-update-timer

1676089507

app.update.lastUpdateTime.browser-cleanup-thumbnails

1676089267

app.update.lastUpdateTime.recipe-client-addon-run

1676089387

app.update.lastUpdateTime.region-update-timer

1675766877

app.update.lastUpdateTime.search-engine-update-timer

1676089027

app.update.lastUpdateTime.services-settings-poll-changes

1676089147

app.update.lastUpdateTime.telemetry_modules_ping

1675766352

app.update.lastUpdateTime.xpi-signature-verification

1676089627

browser.bookmarks.restore_default_bookmarks

false

browser.cache.disk.enable

false

browser.cache.disk_cache_ssl

false

browser.cache.offline.enable

false

browser.contentblocking.category

custom

browser.contextual-services.contextId

{6ef73d3e-ccf6-402f-9683-04822479cd96}

browser.download.panel.shown

true

browser.download.viewableInternally.typeWasRegistered.avif

true

browser.download.viewableInternally.typeWasRegistered.webp

true

browser.engagement.downloads-button.has-used

true

browser.engagement.home-button.has-removed

true

browser.formfill.enable

false

browser.laterrun.bookkeeping.profileCreationTime

1675766292

browser.laterrun.bookkeeping.sessionCount

13

browser.laterrun.enabled

true

browser.migration.version

128

browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons

false

browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features

false

browser.newtabpage.activity-stream.feeds.topsites

false

browser.newtabpage.activity-stream.impressionId

{2c1665af-b89c-4287-9d2d-8b7ae7f82969}

browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned

google

browser.newtabpage.pinned

browser.newtabpage.storageVersion

1

browser.pageActions.persistedActions

{"ids":["bookmark"],"idsInUrlbar":["bookmark"],"idsInUrlbarPreProton":[],"version":1}

browser.pagethumbnails.storage_version

3

browser.policies.applied

true

browser.policies.runOncePerModification.displayBookmarksToolbar

false

browser.proton.toolbar.version

3

browser.region.update.updated

1675766297

browser.rights.3.shown

true

browser.safebrowsing.provider.google4.lastupdatetime

1676091096895

browser.safebrowsing.provider.google4.nextupdatetime

1676092921895

browser.safebrowsing.provider.mozilla.lastupdatetime

1676089004211

browser.safebrowsing.provider.mozilla.nextupdatetime

1676110604211

browser.search.region

CH

browser.search.suggest.enabled

false

browser.send_pings.require_same_host

true

browser.sessionstore.upgradeBackup.latestBuildID

20221205141915

browser.shell.checkDefaultBrowser

true

browser.shell.mostRecentDateSetAsDefault

1676091587

browser.startup.couldRestoreSession.count

2

browser.startup.homepage

about:home

browser.startup.homepage_override.buildID

20221205141915

browser.startup.homepage_override.mstone

102.6.0

browser.startup.lastColdStartupCheck

1676091587

browser.theme.content-theme

0

browser.theme.toolbar-theme

0

browser.toolbars.bookmarks.visibility

never

browser.uiCustomization.state

{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","urlbar-container","bookmarks-menu-button","downloads-button","ublock0_raymondhill_net-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action"],"dirtyAreaCache":["nav-bar","toolbar-menubar","TabsToolbar","PersonalToolbar"],"currentVersion":17,"newElementCount":3}

browser.uidensity

1

browser.uitour.enabled

false

browser.urlbar.placeholderName

DuckDuckGo

browser.urlbar.placeholderName.private

Google

browser.urlbar.quicksuggest.migrationVersion

2

browser.urlbar.quicksuggest.scenario

history

browser.urlbar.trimURLs

false

distribution.Kali.bookmarksProcessed

true

distribution.iniFile.exists.appversion

102.6.0

distribution.iniFile.exists.value

true

doh-rollout.balrog-migration-done

true

doh-rollout.doneFirstRun

true

doh-rollout.home-region

CH

dom.battery.enabled

false

dom.push.userAgentID

e226eedb74764f7ca8d1d18dca891b4e

dom.security.https_only_mode

true

dom.security.https_only_mode_ever_enabled

true

extensions.activeThemeID

firefox-compact-dark@mozilla.org

extensions.blocklist.pingCountVersion

-1

extensions.databaseSchema

35

extensions.getAddons.cache.lastUpdate

1676089509

extensions.getAddons.databaseSchema

6

extensions.lastAppBuildId

20221205141915

extensions.lastAppVersion

102.6.0

extensions.lastPlatformVersion

102.6.0

extensions.pendingOperations

false

extensions.pictureinpicture.enable_picture_in_picture_overrides

true

extensions.pocket.api

extensions.pocket.enabled

false

extensions.pocket.oAuthConsumerKey

extensions.pocket.site

extensions.systemAddonSet

{"schema":1,"addons":{}}

extensions.ui.dictionary.hidden

true

extensions.ui.lastCategory

addons://list/extension

extensions.ui.locale.hidden

true

extensions.ui.sitepermission.hidden

true

extensions.webcompat.enable_shims

true

extensions.webcompat.perform_injections

true

extensions.webcompat.perform_ua_overrides

true

extensions.webextensions.ExtensionStorageIDB.migrated.screenshots@mozilla.org

true

extensions.webextensions.ExtensionStorageIDB.migrated.uBlock0@raymondhill.net

true

extensions.webextensions.uuids

{"doh-rollout@mozilla.org":"106d4d93-fc81-435e-be89-d0869828610e","formautofill@mozilla.org":"a3739b37-29d1-43b7-8aeb-80fb219dd4cd","pictureinpicture@mozilla.org":"3b4c5206-42f1-4656-90dd-dca23ea432e0","screenshots@mozilla.org":"44245e97-dccc-4a6b-a101-8c2455a6e0b3","webcompat-reporter@mozilla.org":"f248d198-55ef-47e9-9425-3ac4250f8ed4","webcompat@mozilla.org":"b779f40c-3c73-4ab1-b8e1-8a8a78fd44f6","default-theme@mozilla.org":"3f6cbb37-b75e-472b-9ee6-24e9be026428","addons-search-detection@mozilla.com":"d18363d2-c711-469d-b43e-8ea593a0e448","google@search.mozilla.org":"5db64132-a641-4938-b19b-cf17735a0f44","wikipedia@search.mozilla.org":"5b5397f9-9a3f-4403-81b9-85e91a1d7798","bing@search.mozilla.org":"4b3c43e0-bba0-4752-845b-4cfdef8443f3","ddg@search.mozilla.org":"1b51f9da-4f1a-4a15-9f7c-7c869bc62b20","amazon@search.mozilla.org":"d0c531cc-d274-43b8-bde2-582a8a307ee9","ebay@search.mozilla.org":"ce314634-8bf5-403d-8cb3-b8126271de1d","firefox-compact-dark@mozilla.org":"780153ea-ede9-44b5-ad93-6c5626cc83ad","uBlock0@raymondhill.net":"ff478d66-1a08-48b1-aa32-da0d753f3a02"}

fission.experiment.max-origins.last-disqualified

0

fission.experiment.max-origins.last-qualified

1675766294

fission.experiment.max-origins.qualified

true

gecko.handlerService.defaultHandlersVersion

1

geo.enabled

false

idle.lastDailyNotification

1675767075

layers.acceleration.force-enabled

true

layers.async-video.enabled

true

layers.offmainthreadcomposition.enabled

true

layout.frame_rate.precise

true

layout.spellcheckDefault

0

media.gmp-gmpopenh264.abi

x86_64-gcc3

media.gmp-gmpopenh264.lastDownload

1675766650

media.gmp-gmpopenh264.lastInstallStart

1675766647

media.gmp-gmpopenh264.lastUpdate

1675766650

media.gmp-gmpopenh264.version

1.8.1.2

media.gmp-manager.buildID

20221205141915

media.gmp-manager.lastCheck

1676090140

media.gmp-manager.lastEmptyCheck

1676090140

media.gmp.storage.version.observed

1

media.videocontrols.picture-in-picture.video-toggle.enabled

false

network.IDN_show_punycode

true

network.cookie.cookieBehavior

1

network.cookie.lifetimePolicy

2

network.dns.disableIPv6

true

network.dnsCacheEntries

100

network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation

true

network.http.referer.spoofSource

true

network.http.sendRefererHeader

1

network.http.speculative-parallel-limit

0

network.predictor.enabled

false

network.prefetch-next

false

network.proxy.socks_remote_dns

true

pdfjs.enabledCache.state

true

pdfjs.migrationVersion

2

places.database.lastMaintenance

1675767075

places.history.enabled

false

plugin.state.flash

0

pref.general.disable_button.default_browser

false

privacy.annotate_channels.strict_list.enabled

true

privacy.clearOnShutdown.offlineApps

true

privacy.clearOnShutdown.siteSettings

true

privacy.cpd.offlineApps

true

privacy.cpd.siteSettings

true

privacy.donottrackheader.enabled

true

privacy.history.custom

true

privacy.partition.network_state.ocsp_cache

true

privacy.purge_trackers.date_in_cookie_database

0

privacy.purge_trackers.last_purge

1675767075415

privacy.query_stripping.enabled

true

privacy.sanitize.pending

[{"id":"shutdown","itemsToClear":["cache","cookies","offlineApps","history","formdata","downloads","sessions","siteSettings"],"options":{}},{"id":"newtab-container","itemsToClear":[],"options":{}}]

privacy.sanitize.sanitizeOnShutdown

true

privacy.sanitize.timeSpan

0

privacy.trackingprotection.enabled

true

privacy.trackingprotection.socialtracking.enabled

true

privacy.userContext.enabled

true

security.sandbox.content.tempDirSuffix

14cf1862-b439-40bc-b0bd-4631cf528715

services.settings.blocklists.addons-bloomfilters.last_check

1676089147

services.settings.blocklists.gfx.last_check

1676089147

services.settings.clock_skew_seconds

0

services.settings.last_etag

"1676084232023"

services.settings.last_update_seconds

1676089147

services.settings.main.addons-manager-settings.last_check

1676089147

services.settings.main.anti-tracking-url-decoration.last_check

1676089147

services.settings.main.cfr.last_check

1676089147

services.settings.main.devtools-compatibility-browsers.last_check

1676089147

services.settings.main.doh-config.last_check

1676089147

services.settings.main.doh-providers.last_check

1676089147

services.settings.main.hijack-blocklists.last_check

1676089147

services.settings.main.language-dictionaries.last_check

1676089147

services.settings.main.message-groups.last_check

1676089147

services.settings.main.normandy-recipes-capabilities.last_check

1676089147

services.settings.main.partitioning-exempt-urls.last_check

1676089147

services.settings.main.password-recipes.last_check

1676089147

services.settings.main.password-rules.last_check

1676089147

services.settings.main.pioneer-study-addons-v1.last_check

1676089147

services.settings.main.query-stripping.last_check

1676089147

services.settings.main.search-config.last_check

1676089147

services.settings.main.search-default-override-allowlist.last_check

1676089147

services.settings.main.search-telemetry-v2.last_check

1676089147

services.settings.main.sites-classification.last_check

1676089147

services.settings.main.top-sites.last_check

1676089147

services.settings.main.url-classifier-skip-urls.last_check

1676089147

services.settings.main.websites-with-shared-credential-backends.last_check

1676089147

services.settings.main.whats-new-panel.last_check

1676089147

services.sync.clients.lastSync

0

services.sync.declinedEngines

services.sync.globalScore

0

services.sync.nextSync

0

services.sync.prefs.sync.app.shield.optoutstudies.enabled

false

services.sync.tabs.lastSync

0

signon.management.page.breach-alerts.enabled

false

signon.rememberSignons

false

storage.vacuum.last.index

0

storage.vacuum.last.places.sqlite

1675767075

toolkit.startup.last_success

1676091091

toolkit.telemetry.cachedClientID

c0ffeec0-ffee-c0ff-eec0-ffeec0ffeec0

toolkit.telemetry.pioneer-new-studies-available

false

toolkit.telemetry.previousBuildID

20221205141915

toolkit.telemetry.reportingpolicy.firstRun

false

webgl.force-enabled

true
```

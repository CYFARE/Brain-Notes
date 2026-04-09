# WiFi Pineapple MK7 — Wardriving Setup Guide

Complete setup for wardriving with a Hak5 WiFi Pineapple MK7, ublox7 GPS/GLONASS USB dongle, and portable battery. Produces WiGLE.net-compatible CSV files for contribution. Includes a mobile-friendly web dashboard for start/stop control and live stats.

## Requirements

- WiFi Pineapple MK7 (running stock firmware)
- USB GPS/GLONASS dongle (ublox7-based, appears as `/dev/ttyACM0`)
- Portable battery pack (powering MK7 via USB)
- Phone or laptop connected to MK7 management AP

## Architecture

```
Phone (browser) ──WiFi──▶ MK7 Management AP (172.16.42.1)
                              │
                              ├── uhttpd :8080 → CGI dashboard
                              ├── wlan0 (mt76) → WiFi scanning
                              └── /dev/ttyACM0 → GPS via gpsd
```

- **wlan0** (built-in mt76 radio) handles both the management AP and WiFi scanning
- **wlan1** (mt7601u USB) does not support scanning in managed mode on MK7 — do not use it
- `airmon-ng` is incompatible with mt76 chipsets — use `iw` commands only

---

## Step 1: SSH into the Pineapple

Connect your phone/laptop to the MK7's management AP, then:

```bash
ssh root@172.16.42.1
```

## Step 2: Install GPS Support

The MK7 needs internet for package installation. Tether your phone to the WAN port or configure internet sharing before running:

```bash
opkg update
opkg install gpsd gpsd-clients uhttpd
```

> **Note:** `uhttpd` may already be installed. If `opkg` says it's already installed, that's fine.

## Step 3: Start GPS Daemon

```bash
gpsd -b /dev/ttyACM0 -n
```

The `-b` flag is required for ublox7 devices — without it, gpsd may report `lat: 0, lon: 0` even with a valid fix.

### Verify GPS Fix

```bash
cgps -s
```

Wait **outdoors with clear sky view** until you see:

- Valid latitude/longitude values
- Satellites with SNR > 15 and `Y` in the Use column
- Status showing `2D FIX` or `3D FIX`

Exit with `q`.

**GPS fix times:**

|Scenario|Time|
|---|---|
|Cold start (first use / new location)|1–15 minutes|
|Warm start (after reboot, same location)|5–30 seconds|
|Driving (maintaining fix)|Continuous|

> **Troubleshooting:** If GPS shows `NO FIX` after 15 minutes outdoors, check that any external antenna connector on the ublox7 dongle is properly seated. Some modules have a ceramic patch antenna that must face skyward.

## Step 4: Create the Wardrive Script

```bash
cat << 'EOF' > /root/wardrive.sh
#!/bin/sh

OUTFILE="/root/wardrive_$(date +%Y%m%d_%H%M%S).csv"
IFACE="wlan0"

echo "WigleWifi-1.4,appRelease=MK7,model=MK7,release=1.0,device=PineappleMK7,display=none,board=MK7,brand=Hak5" > "$OUTFILE"
echo "MAC,SSID,AuthMode,FirstSeen,Channel,RSSI,CurrentLatitude,CurrentLongitude,AltitudeMeters,AccuracyMeters,Type" >> "$OUTFILE"

echo "Logging to $OUTFILE"

while true; do
    GPSDATA=$(gpspipe -w -n 5 2>/dev/null | grep -m1 '"class":"TPV"')
    LAT=$(echo "$GPSDATA" | sed -n 's/.*"lat":\([0-9.-]*\).*/\1/p')
    LON=$(echo "$GPSDATA" | sed -n 's/.*"lon":\([0-9.-]*\).*/\1/p')
    ALT=$(echo "$GPSDATA" | sed -n 's/.*"alt":\([0-9.-]*\).*/\1/p')

    [ -z "$LAT" ] && sleep 1 && continue
    [ -z "$ALT" ] && ALT="0"

    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    iw dev "$IFACE" scan 2>/dev/null | awk -v lat="$LAT" -v lon="$LON" -v alt="$ALT" -v ts="$TIMESTAMP" \
    'BEGIN { mac=""; ssid=""; chan=""; rssi=""; wpa="" }
    /^BSS / {
        if (mac != "") {
            auth = (wpa != "") ? wpa : "[OPEN]"
            printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,0,WIFI\n", mac, ssid, auth, ts, chan, rssi, lat, lon, alt
        }
        mac = $2; sub(/\(.*/, "", mac)
        ssid=""; chan=""; rssi=""; wpa=""
    }
    /\tSSID: / { ssid = substr($0, index($0,"SSID: ")+6) }
    /\* primary channel:/ { chan = $NF }
    /signal:/ { rssi = $2 }
    /WPA|RSN|WEP/ { wpa = wpa "[" $1 "]" }
    END {
        if (mac != "") {
            auth = (wpa != "") ? wpa : "[OPEN]"
            printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,0,WIFI\n", mac, ssid, auth, ts, chan, rssi, lat, lon, alt
        }
    }' >> "$OUTFILE"

    sleep 3
done
EOF
chmod +x /root/wardrive.sh
```

> **Scan interval:** The `sleep 3` at the end controls scan frequency. Lower values capture more data but use more battery and may cause brief management AP interruptions.

## Step 5: Create the API Endpoint

```bash
mkdir -p /www/cgi-bin

cat << 'APIEOF' > /www/cgi-bin/wardrive-api
#!/bin/sh
echo "Content-Type: application/json"
echo ""

PIDFILE="/tmp/wardrive.pid"
ACTION=$(echo "$QUERY_STRING" | sed -n 's/.*action=\([a-z]*\).*/\1/p')

is_running() {
    [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null
}

case "$ACTION" in
    start)
        if ! is_running; then
            /root/wardrive.sh >/dev/null 2>&1 &
            echo $! > "$PIDFILE"
            sleep 2
        fi ;;
    stop)
        if is_running; then
            kill $(cat "$PIDFILE") 2>/dev/null
            rm -f "$PIDFILE"
            sleep 1
        fi ;;
esac

RUNNING="false"
is_running && RUNNING="true"

F=$(ls -t /root/wardrive_*.csv 2>/dev/null | head -1)

if [ -z "$F" ]; then
    echo "{\"gps\":0,\"running\":$RUNNING,\"total\":0,\"unique\":0,\"open\":0,\"wpa\":0,\"recent\":[]}"
    exit 0
fi

TOTAL=$(tail -n +3 "$F" | wc -l)
UNIQUE=$(tail -n +3 "$F" | cut -d',' -f1 | sort -u | wc -l)
OPEN=$(tail -n +3 "$F" | grep '\[OPEN\]' | cut -d',' -f1 | sort -u | wc -l)
WPA=$(tail -n +3 "$F" | grep -v '\[OPEN\]' | cut -d',' -f1 | sort -u | wc -l)

LASTLAT=$(tail -1 "$F" | cut -d',' -f7)
GPSFIX=0
if [ -n "$LASTLAT" ] && [ "$LASTLAT" != "0.000000" ]; then
    GPSFIX=3
fi

RECENT=$(tail -n +3 "$F" | tail -50 | awk -F',' '{
    mac=$1; ssid=$2; auth=$3; ts=$4; ch=$5; rssi=$6; lat=$7; lon=$8
    gsub(/"/, "\\\"", ssid)
    printf "{\"mac\":\"%s\",\"ssid\":\"%s\",\"auth\":\"%s\",\"ts\":\"%s\",\"ch\":\"%s\",\"rssi\":\"%s\",\"lat\":\"%s\",\"lon\":\"%s\"},", mac, ssid, auth, ts, ch, rssi, lat, lon
}' | sed 's/,$//')

echo "{\"gps\":$GPSFIX,\"running\":$RUNNING,\"total\":$TOTAL,\"unique\":$UNIQUE,\"open\":$OPEN,\"wpa\":$WPA,\"recent\":[$RECENT]}"
APIEOF
chmod +x /www/cgi-bin/wardrive-api
```

## Step 6: Create the Web Dashboard

```bash
cat << 'HTMLEOF' > /www/cgi-bin/wardrive
#!/bin/sh
echo "Content-Type: text/html; charset=utf-8"
echo ""
cat <<'HTML'
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>MK7 Wardrive</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:-apple-system,sans-serif;background:#0a0e17;color:#e0e0e0;padding:10px}
h1{text-align:center;color:#00ff88;font-size:1.4em;margin:8px 0}
.top{display:flex;justify-content:center;gap:12px;margin:10px 0}
.btn{font-size:1.1em;padding:12px 32px;border:none;border-radius:10px;color:#fff;cursor:pointer;font-weight:bold}
.btn-start{background:#1a8}
.btn-stop{background:#c33}
.btn:disabled{opacity:.4;cursor:default}
.status-bar{text-align:center;font-size:1.1em;padding:8px;border-radius:8px;margin:6px 0}
.stats{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin:10px 0}
.stat{background:#151b2b;border-radius:10px;padding:10px;text-align:center}
.stat .num{font-size:1.6em;font-weight:bold;color:#00ff88}
.stat .lbl{font-size:.75em;color:#888;margin-top:2px}
.recent{background:#151b2b;border-radius:10px;padding:10px;margin:8px 0;max-height:55vh;overflow-y:auto}
.recent h3{color:#00ff88;font-size:.9em;margin-bottom:6px}
.recent table{width:100%;font-size:.75em;border-collapse:collapse}
.recent td,.recent th{padding:4px 5px;text-align:left;border-bottom:1px solid #1a2040}
.recent th{color:#888}
.gps-bar{text-align:center;font-size:.85em;padding:6px;margin:6px 0;border-radius:6px;background:#151b2b}
</style>
</head><body>
<h1>MK7 Wardrive</h1>
<div class="gps-bar" id="gpsBar">GPS: checking...</div>
<div class="status-bar" id="status">Loading...</div>
<div class="top">
  <button class="btn btn-start" id="btnStart" onclick="doStart()">START</button>
  <button class="btn btn-stop" id="btnStop" onclick="doStop()">STOP</button>
</div>
<div class="stats">
  <div class="stat"><div class="num" id="sTotal">0</div><div class="lbl">Total Scans</div></div>
  <div class="stat"><div class="num" id="sUnique">0</div><div class="lbl">Unique APs</div></div>
  <div class="stat"><div class="num" id="sOpen">0</div><div class="lbl">Open</div></div>
  <div class="stat"><div class="num" id="sWpa">0</div><div class="lbl">Encrypted</div></div>
</div>
<div class="recent">
  <h3>Recent Networks</h3>
  <table><thead><tr><th>SSID</th><th>Ch</th><th>RSSI</th><th>Auth</th><th>MAC</th></tr></thead>
  <tbody id="tblRecent"></tbody></table>
</div>

<script>
var API="/cgi-bin/wardrive-api";
var locked=false;
var pollTimer=null;

function setUI(d){
  var s=document.getElementById("status");
  if(d.running){
    s.textContent="RUNNING";s.style.background="#1a3a1a";s.style.color="#0f0";
  } else {
    s.textContent="STOPPED";s.style.background="#3a1a1a";s.style.color="#f33";
  }
  document.getElementById("btnStart").disabled=d.running;
  document.getElementById("btnStop").disabled=!d.running;

  var gb=document.getElementById("gpsBar");
  var labels=["NO GPS","NO FIX","2D FIX","3D FIX"];
  var colors=["#f33","#f33","#fa0","#0f0"];
  var m=d.gps||0;
  var coord="";
  if(d.recent&&d.recent.length>0){
    var last=d.recent[d.recent.length-1];
    coord=" | "+last.lat+", "+last.lon;
  }
  gb.innerHTML="GPS: <span style='color:"+colors[m]+"'>"+labels[m]+"</span>"+coord;
}

function updateData(d){
  document.getElementById("sTotal").textContent=d.total;
  document.getElementById("sUnique").textContent=d.unique;
  document.getElementById("sOpen").textContent=d.open;
  document.getElementById("sWpa").textContent=d.wpa;
  var seen={};var rows=[];
  for(var i=d.recent.length-1;i>=0&&rows.length<30;i--){
    var p=d.recent[i];
    if(!seen[p.mac]){seen[p.mac]=1;rows.push(p)}
  }
  var html="";
  for(var i=0;i<rows.length;i++){
    var p=rows[i];
    html+="<tr><td>"+esc(p.ssid||"(hidden)")+"</td><td>"+p.ch+"</td><td>"+p.rssi+"</td><td>"+esc(p.auth)+"</td><td style='font-size:.65em'>"+p.mac+"</td></tr>";
  }
  document.getElementById("tblRecent").innerHTML=html;
}

function doStart(){
  if(locked)return;locked=true;stopPolling();
  document.getElementById("btnStart").disabled=true;
  document.getElementById("btnStop").disabled=true;
  document.getElementById("status").textContent="Starting...";
  document.getElementById("status").style.background="#2a2a1a";
  document.getElementById("status").style.color="#fa0";
  fetch(API+"?action=start").then(function(r){return r.json()}).then(function(d){locked=false;updateData(d);setUI(d);startPolling()}).catch(function(){locked=false;startPolling()});
}

function doStop(){
  if(locked)return;locked=true;stopPolling();
  document.getElementById("btnStart").disabled=true;
  document.getElementById("btnStop").disabled=true;
  document.getElementById("status").textContent="Stopping...";
  document.getElementById("status").style.background="#2a2a1a";
  document.getElementById("status").style.color="#fa0";
  fetch(API+"?action=stop").then(function(r){return r.json()}).then(function(d){locked=false;updateData(d);setUI(d);startPolling()}).catch(function(){locked=false;startPolling()});
}

function poll(){
  if(locked)return;
  fetch(API).then(function(r){return r.json()}).then(function(d){if(!locked){updateData(d);setUI(d)}}).catch(function(){});
}

function esc(s){return s?s.replace(/&/g,"&amp;").replace(/</g,"&lt;"):""}
function startPolling(){pollTimer=setInterval(poll,5000)}
function stopPolling(){clearInterval(pollTimer)}
startPolling();poll();
</script>
</body></html>
HTML
HTMLEOF
chmod +x /www/cgi-bin/wardrive
```

## Step 7: Configure uhttpd

```bash
uci set uhttpd.wardrive=uhttpd
uci set uhttpd.wardrive.listen_http='0.0.0.0:8080'
uci set uhttpd.wardrive.home='/www'
uci set uhttpd.wardrive.cgi_prefix='/cgi-bin'
uci commit uhttpd
/etc/init.d/uhttpd restart
```

## Step 8: Auto-Start on Boot

```bash
echo 'gpsd -b /dev/ttyACM0 -n' >> /etc/rc.local
echo '/root/wardrive_ctl.sh >/dev/null 2>&1 &' >> /etc/rc.local
```

> **Note:** OpenWrt's busybox does not include `nohup`. Use `>/dev/null 2>&1 &` instead.

## Step 9: Access the Dashboard

Open your phone browser to:

```
http://172.16.42.1:8080/cgi-bin/wardrive
```

You'll see:

- **GPS status** — color-coded fix indicator (red = no fix, orange = 2D, green = 3D)
- **START / STOP** buttons — AJAX-based, no page reloads
- **Live stats** — Total scans, unique APs, open networks, encrypted networks
- **Recent networks table** — SSID, channel, RSSI, auth type, MAC address

Wait for GPS to show **3D FIX** (green), then tap **START** and begin driving.

## Step 10: Retrieve CSV & Upload to WiGLE

After your drive, from any device on the management AP:

```bash
scp root@172.16.42.1:/root/wardrive_*.csv .
```

Upload the CSV file at **https://wigle.net/uploads**.

---

## Output Format

The CSV follows the WiGLE v1.4 format:

```
WigleWifi-1.4,appRelease=MK7,model=MK7,release=1.0,device=PineappleMK7,display=none,board=MK7,brand=Hak5
MAC,SSID,AuthMode,FirstSeen,Channel,RSSI,CurrentLatitude,CurrentLongitude,AltitudeMeters,AccuracyMeters,Type
aa:83:94:d6:e1:dd,JioFiber-80iE6,[RSN:],2026-04-09 11:13:55,1,-83.00,32.692212,74.872936,299.37,0,WIFI
```

---

## Troubleshooting

### GPS shows NO FIX

- Ensure you are **outdoors** with clear sky view
- Cold start can take up to 15 minutes in poor conditions
- Check antenna connection on ublox7 dongle
- Verify device: `ls /dev/ttyACM*`

### GPS reports lat/lon as 0.000000

- Restart gpsd with the `-b` flag: `killall gpsd && gpsd -b /dev/ttyACM0 -n`
- This is a known issue with ublox7 devices and gpsd's protocol handling

### Scanning returns no networks

- Verify `wlan0` can scan: `iw dev wlan0 scan | head -20`
- If `wlan1` was attempted: `iw dev wlan1mon del 2>/dev/null` to clean up
- Never use `airmon-ng` on MK7 — it is incompatible with mt76 chipsets

### Dashboard not loading on port 8080

- Verify uhttpd is running: `netstat -tlnp | grep 8080`
- Restart: `/etc/init.d/uhttpd restart`
- Check CGI permissions: `ls -la /www/cgi-bin/`

### Status flickers between RUNNING/STOPPED

- This was caused by `pgrep -f "wardrive.sh"` matching the CGI script itself
- The fix uses a PID file (`/tmp/wardrive.pid`) instead — ensure you're using the latest API script from Step 5

### `nohup: not found`

- OpenWrt's busybox does not include `nohup`
- Use `command >/dev/null 2>&1 &` instead

---

## File Locations

|File|Purpose|
|---|---|
|`/root/wardrive.sh`|Main scanning script|
|`/root/wardrive_YYYYMMDD_HHMMSS.csv`|Output CSV files (WiGLE format)|
|`/www/cgi-bin/wardrive`|Web dashboard (HTML)|
|`/www/cgi-bin/wardrive-api`|JSON API endpoint|
|`/tmp/wardrive.pid`|PID file for process tracking|

## Legal Warning!

This guide is provided as-is for educational and legal wardriving purposes. Wardriving (passive WiFi scanning) is legal in most countries (including mine). Always comply with local laws!

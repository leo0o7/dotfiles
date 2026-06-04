#!/bin/bash
# wifi_scan.sh
# Writes /tmp/sketchybar_wifi.json

CACHE="/tmp/sketchybar_wifi.json"

CURRENT=$(ipconfig getsummary en0 2>/dev/null | awk -F' SSID : ' '/ SSID : /{print $2; exit}')

# ── Preferred (saved) networks ────────────────────────────────────────────────
# Join with | so the whole list fits on one line — awk -v cannot handle
# multi-line values (causes "newline in string" errors).
PREFERRED_FLAT=$(networksetup -listpreferredwirelessnetworks en0 2>/dev/null |
  tail -n +2 |
  sed 's/^[[:space:]]*//' |
  tr '\n' '|')

system_profiler SPAirPortDataType 2>/dev/null | awk \
  -v current="$CURRENT" \
  -v preferred_flat="$PREFERRED_FLAT" \
  '
BEGIN {
    n = split(preferred_flat, pa, "|")
    for (i=1; i<=n; i++) {
        p = pa[i]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", p)
        if (p != "") pref[p] = 1
    }
    in_wifi=0; in_sec=0
    ssid=""; security="none"; signal=-100; connected=0; cnt=0
}
/^        en0:$/          { in_wifi=1; next }
/^        [a-z][a-z0-9]/ { if (in_wifi) { flush(); in_wifi=0; in_sec=0 }; next }
!in_wifi { next }
/Current Network Information:/  { flush(); in_sec=1; next }
/Other Local Wi-Fi Networks:/   { flush(); in_sec=2; next }
in_sec && /^[[:space:]]{12,}[^ ].*:$/ &&
    !/PHY Mode:|Channel:|Network Service|BSSID:|Country|Network Type:|Security:|Signal|Noise:|SNR:|MCS|Transmit|Receive|Age:/ {
    flush()
    s=$0; gsub(/^[[:space:]]+/,"",s); gsub(/:$/,"",s)
    ssid=s; security="none"; signal=-100; connected=(in_sec==1)?1:0; next
}
in_sec && ssid!="" && /Signal \/ Noise:|RSSI:/ {
    if (match($0,/-[0-9]+/)) signal=substr($0,RSTART,RLENGTH)+0; next
}
in_sec && ssid!="" && /Security:/ {
    if      ($0~/WPA3/) security="wpa3"
    else if ($0~/WPA2/) security="wpa2"
    else if ($0~/WPA/)  security="wpa"
    else if ($0~/WEP/)  security="wep"
    next
}
function flush(    conn,pv) {
    if (ssid=="") return
    conn = (connected || ssid==current) ? "true" : "false"
    pv   = (ssid in pref || conn=="true") ? "true" : "false"
    if (ssid in seen) {
        if (signal>seen_rssi[ssid]) { seen_rssi[ssid]=signal; seen_sec[ssid]=security }
        if (conn=="true") seen_conn[ssid]="true"
        if (pv=="true")   seen_pref[ssid]="true"
    } else {
        seen[ssid]=1; seen_rssi[ssid]=signal; seen_sec[ssid]=security
        seen_conn[ssid]=conn; seen_pref[ssid]=pv; order[++cnt]=ssid
    }
    ssid=""; security="none"; signal=-100; connected=0
}
END {
    flush()
    for (i=1;i<cnt;i++)
        for (j=i+1;j<=cnt;j++) {
            ai=order[i]; aj=order[j]
            pi=(seen_conn[ai]=="true")?2:(seen_pref[ai]=="true")?1:0
            pj=(seen_conn[aj]=="true")?2:(seen_pref[aj]=="true")?1:0
            if (pj>pi||(pj==pi&&seen_rssi[aj]>seen_rssi[ai])) {
                tmp=order[i];order[i]=order[j];order[j]=tmp
            }
        }
    printf "["
    for (i=1;i<=cnt;i++) {
        s=order[i]; esc=s; gsub(/"/,"\\\"",esc)
        if (i>1) printf ","
        printf "{\"ssid\":\"%s\",\"rssi\":%d,\"security\":\"%s\",\"connected\":%s,\"preferred\":%s}",
            esc,seen_rssi[s],seen_sec[s],seen_conn[s],seen_pref[s]
    }
    print "]"
}
' >"$CACHE"

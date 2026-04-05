#!/system/bin/sh
MODDIR="${0%/*}"

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done
sleep 15

log -t "IMS_VOLNA" "=== Phase 1: Fix subscription database ==="

content update --uri content://telephony/siminfo \
    --where "_id=1" \
    --bind "carrier_name:s:VOLNA" \
    --bind "volte_vt_enabled:i:1" \
    --bind "wfc_ims_enabled:i:1" \
    --bind "wfc_ims_mode:i:2" \
    --bind "wfc_ims_roaming_mode:i:2" \
    --bind "wfc_ims_roaming_enabled:i:1" \
    --bind "display_name:s:VOLNA" \
    --bind "iso_country_code:s:ru" \
    --bind "voims_opt_in_status:i:1"

log -t "IMS_VOLNA" "Subscription database updated"

log -t "IMS_VOLNA" "=== Phase 2: Force ImsResolver to bind Shannon ==="

cmd device_config set_sync_disabled_for_tests persistent 2>/dev/null
cmd device_config put telephony ims_service_package_name com.shannon.imsservice 2>/dev/null
cmd device_config put telephony ims_dynamic_binding true 2>/dev/null

log -t "IMS_VOLNA" "DeviceConfig set for Shannon IMS"

log -t "IMS_VOLNA" "=== Phase 3: Enable global IMS settings ==="

settings put global vt_ims_enabled 1
settings put global wfc_ims_enabled 1

log -t "IMS_VOLNA" "Global settings updated"

log -t "IMS_VOLNA" "=== Phase 4: Restart Shannon IMS ==="

am force-stop com.shannon.imsservice 2>/dev/null
sleep 3

am broadcast -a android.telephony.action.CARRIER_CONFIG_CHANGED -p android 2>/dev/null
sleep 2

am broadcast -a android.intent.action.SIM_STATE_CHANGED --es ss LOADED -p android 2>/dev/null
sleep 2

am broadcast -a android.intent.action.PHONE_STATE -p android 2>/dev/null
sleep 5

log -t "IMS_VOLNA" "=== Phase 5: Verify ==="

SLOT_CHECK=$(logcat -d | grep "SHANNON_IMS" | grep "slot" | tail -5)
log -t "IMS_VOLNA" "Shannon slot check: $SLOT_CHECK"

IMS_BIND=$(logcat -d | grep "ImsResolver" | tail -5)
log -t "IMS_VOLNA" "ImsResolver: $IMS_BIND"

log -t "IMS_VOLNA" "=== All phases complete ==="

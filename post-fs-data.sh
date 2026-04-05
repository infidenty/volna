#!/system/bin/sh
MODDIR="${0%/*}"

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done
sleep 3

resetprop gsm.operator.numeric "25060"
resetprop gsm.sim.operator.numeric "25060"
resetprop gsm.operator.iso-country "ru"
resetprop gsm.sim.operator.iso-country "ru"
resetprop gsm.operator.alpha "VOLNA"
resetprop gsm.sim.operator.alpha "VOLNA"
resetprop ro.carrier "volna"
resetprop persist.radio.is_vonr_enabled_0 1
resetprop persist.radio.is_vonr_enabled_1 1

log -t "IMS_VOLNA" "Post-fs-data complete"

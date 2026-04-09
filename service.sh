#!/system/bin/sh
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do sleep 5; done
sleep 2

# LMKD padrão
resetprop sys.lmk.minfree_levels "18432:0,23040:100,27648:200,32256:250,55296:900,80640:950"
setprop lmkd.reinit 1

# CPU normal
for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo schedutil > $gov 2>/dev/null
done

wm size reset
wm density reset
#!/system/bin/sh
export PATH=/system/bin:/system/xbin:/vendor/bin:$PATH

SKIPUNZIP=0

MODID=${MODID:-"Custom_BuSy"}
MODPATH=${MODPATH:-"/data/adb/modules/$MODID"}
BIN="$MODPATH/system/bin"

ARCH=$(getprop ro.product.cpu.abi)
ui_print "🔍 Detectando arquitetura: $ARCH"

case $ARCH in
    arm64-v8a)
        BUSY_PATH="$MODPATH/busy/busybox_arm64"
        ;;
    armeabi-v7a|armeabi|armv7l)
        BUSY_PATH="$MODPATH/busy/busybox_arm"
        ;;
    x86_64)
        BUSY_PATH="$MODPATH/busy/busybox_x86_64"
        ;;
    x86)
        BUSY_PATH="$MODPATH/busy/busybox_x86"
        ;;
    *)
        ui_print "❌ Arquitetura não suportada: $ARCH"
        exit 1
        ;;
esac

FILE="$BUSY_PATH"
BU=$(basename "$FILE")

# Corrigido: verificação correta do arquivo
if [ ! -f "$FILE" ]; then
    ui_print "❌ Erro: $BU não encontrado!"
    exit 1
fi

chmod 755 "$FILE"

BUV=$("$FILE" --help 2>&1 | head -n 1 | awk '{print $2}')

ui_print "═══════════════════════════════════════"
ui_print " "
ui_print "██████╗ ██╗   ██╗███████╗██╗   ██╗"
ui_print "██╔══██╗██║   ██║██╔════╝╚██╗ ██╔╝"
ui_print "██████╔╝██║   ██║███████╗ ╚████╔╝ "
ui_print "██╔══██╗██║   ██║╚════██║  ╚██╔╝  "
ui_print "██████╔╝╚██████╔╝███████║   ██║   "
ui_print "╚═════╝  ╚═════╝ ╚══════╝   ╚═╝   "
ui_print "              BuSy"
ui_print "          BY: INRRYOFF"
ui_print " "
ui_print "═══════════════════════════════════════"

# ============================================================
# FUNÇÃO DE ESCOLHAS
# ============================================================
choose_option() {
    local choice=2
    local total_options=3
    local timeout=5
    
    ui_print "  [ VOL+ : Trocar Opcao | VOL- : Confirmar ]"
    ui_print "  Pressione qualquer tecla para modo manual..."
    
    while [ $timeout -gt 0 ]; do
        ui_print "  ⏳ Padrao (Medium) em: $timeout..."
        local key=$(timeout 1 getevent -qlc 1 2>/dev/null | awk '{print $3}')
        [ ! -z "$key" ] && [ "$key" != "0000" ] && break
        timeout=$((timeout - 1))
    done

    [ $timeout -eq 0 ] && return 2

    ui_print " "
    ui_print "  -> MODO MANUAL ATIVADO"
    ui_print "  (Clique VOL+ para girar as opcoes)"
    
    getevent -ql | while read line; do
        echo "$line" | grep -q "KEY_VOLUME" || continue
        echo "$line" | grep -q " DOWN" || continue

        if echo "$line" | grep -q "KEY_VOLUMEUP"; then
            choice=$((choice + 1))
            [ $choice -gt $total_options ] && choice=1
            
            ui_print "     Selecionado: $choice" 
            
        elif echo "$line" | grep -q "KEY_VOLUMEDOWN"; then
            echo "$choice" > /tmp/busy_choice
            pkill getevent
            break
        fi
    done

    local final_choice=$(cat /tmp/busy_choice)
    rm -f /tmp/busy_choice
    
    ui_print " "
    case $final_choice in
        1) ui_print "  ✅ ESCOLHIDO: FULL BUSYBOX" ;;
        2) ui_print "  ✅ ESCOLHIDO: MEDIUM BUSYBOX" ;;
        3) ui_print "  ✅ ESCOLHIDO: SMALL BUSYBOX" ;;
    esac
    
    return $final_choice
}

# ============================================================
# MENU DE ESCOLHA
# ============================================================
escolher_versao() {
    ui_print "═══════════════════════════════════════"
    ui_print "       BuSy - Opções de Instalação"
    ui_print "═══════════════════════════════════════"
    ui_print "  1. FULL   | 2. MEDIUM (Auto) | 3. SMALL"
    ui_print "═══════════════════════════════════════"
    
    choose_option
    return $?
}

# ============================================================
# INSTALAÇÃO MEDIUM
# ============================================================
instalar_medium() {
    ui_print ""
    ui_print "🔰 Instalando MEDIUM BuSy..."

    mkdir -p "$BIN"
    cd "$BIN" || exit 1

    ABS_PATH="/data/adb/modules/$MODID/busy/$(basename "$FILE")"

    CMDS="
        ash chrt taskset renice ionice vi nano
        cat less more head tail cp mv rm mkdir
        rmdir touch ln ls find grep sed awk wc
        sort uniq cut tr df du free kill mount
        umount ping wget curl tar gzip gunzip
        zip unzip date sleep which whoami id
        export unset
    "

    for cmd in $CMDS; do
        ln -sf "$ABS_PATH" "$cmd"
    done

    TOTAL_CMDS=$(ls -1 | wc -l)
    ui_print "✅ MEDIUM BuSy instalado ($TOTAL_CMDS comandos)"
    echo "$TOTAL_CMDS" > /tmp/total_cmds_installed
}

# ============================================================
# INSTALAÇÃO SMALL
# ============================================================
instalar_small() {
    ui_print ""
    ui_print "🍥 Instalando SMALL BuSy..."

    mkdir -p "$BIN"
    cd "$BIN" || exit 1

    ABS_PATH="/data/adb/modules/$MODID/busy/$(basename "$FILE")"

    CMDS="
        ash taskset chrt renice ionice
    "

    for cmd in $CMDS; do
        ln -sf "$ABS_PATH" "$cmd"
    done

    TOTAL_CMDS=$(ls -1 | wc -l)
    ui_print "✅ SMALL BuSy instalado ($TOTAL_CMDS comandos)"
    echo "$TOTAL_CMDS" > /tmp/total_cmds_installed
}

# ============================================================
# INSTALAÇÃO FULL
# ============================================================
instalar_full() {
    ui_print ""
    ui_print "🚀 Instalando FULL BuSy..."

    mkdir -p "$BIN"
    cd "$BIN" || exit 1

    ABS_PATH="/data/adb/modules/$MODID/busy/$(basename "$FILE")"

    APPLETS=$("$FILE" --list)

    for applet in $APPLETS; do
        ln -sf "$ABS_PATH" "$applet"
    done

    REMOVER="
        su sh init adb surfaceflinger logcat
        logger chcon getcon setenforce
        getenforce getprop setprop load_policy
        insmod rmmod lsmod kill logd start
        stop am pm monkey wm reboot poweroff
        swapon swapoff service toolbox toybox
        cmd dumpsys killall uptime watch df ps chroot
        top tar free resetprop powertop mount umount
    "

    for cmd in $REMOVER; do
        rm -f "$cmd"
    done

    TOTAL_CMDS=$(ls -1 | wc -l)
    ui_print "✅ FULL BuSy instalado"
    ui_print "📦 Comandos disponíveis: $TOTAL_CMDS"
    echo "$TOTAL_CMDS" > /tmp/total_cmds_installed
}

# ============================================================
# CRIA DIRETÓRIOS
# ============================================================
mkdir -p "$MODPATH/busy"
mkdir -p "$BIN"

# ============================================================
# EXECUTA
# ============================================================
escolher_versao
CHOICE=$?

case $CHOICE in
    1) VERSAO="FULL" ;;
    2) VERSAO="MEDIUM" ;;
    3) VERSAO="SMALL" ;;
    *) VERSAO="MEDIUM (default)" ;;
esac

case $CHOICE in
    1) instalar_full ;;
    2) instalar_medium ;;
    3) instalar_small ;;
    *) instalar_medium ;;
esac

# Recuperar total de comandos instalados (se disponível)
if [ -f /tmp/total_cmds_installed ]; then
    TOTAL_CMDS=$(cat /tmp/total_cmds_installed)
    rm -f /tmp/total_cmds_installed
else
    TOTAL_CMDS="N/A"
fi

# ============================================================
# resetprop
# ============================================================
if [ -f "/data/adb/magisk/magisk" ]; then
    ln -sf ../../../magisk/magisk "$BIN/resetprop"
    ui_print "✅ Magisk resetprop configurado (via link simbólico)"
elif [ -f "/data/adb/magisk/resetprop" ]; then
    ln -sf ../../../magisk/resetprop "$BIN/resetprop"
    ui_print "✅ Magisk resetprop configurado (via link simbólico)"
else
    ui_print "⚠️ Magisk resetprop não configurado"
fi

# ============================================================
# REGISTRO DE INSTALAÇÃO
# ============================================================
LOG_FILE="$MODPATH/install.log"
ASH_PRESENTE=$(test -f "$BIN/ash" && echo "sim" || echo "não")
RESETPROP_STATUS=$(test -f "$BIN/resetprop" && echo "configurado" || echo "ausente")

cat > "$LOG_FILE" << EOF
========================================
        BuSy - Registro de Instalação
========================================
Data/Hora      : $(date '+%Y-%m-%d %H:%M:%S')
Versão Escolhida: $VERSAO
Arquitetura    : $ARCH
Binário Usado  : $BU
Versão BusyBox : $BUV
Comandos Instalados: $TOTAL_CMDS
resetprop      : $RESETPROP_STATUS
ASH presente   : $ASH_PRESENTE
Caminho do Módulo: $MODPATH
========================================
EOF

# ============================================================
# FINALIZAÇÃO
# ============================================================
ui_print ""
ui_print "═══════════════════════════════════════"
ui_print "✅ BuSy instalado!"
case $CHOICE in
    1) ui_print "📂 FULL (todos os comandos)" ;;
    2) ui_print "📂 MEDIUM (recomendado)" ;;
    3) ui_print "📂 SMALL (GameHub-PRO-X)" ;;
esac
ui_print "🌐 Dev: @inrryoff"
ui_print "✨ Version: $BUV"
ui_print "📦 BuSy Arch: $BU"
ui_print "═══════════════════════════════════════"
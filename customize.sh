#!/system/bin/sh

SKIPUNZIP=1

# Verifica dispositivo
DEVICE=$(getprop ro.product.device)

case "$DEVICE" in
    fogorow)
        ui_print "✔ Moto G24 detectado!"
        ;;
    *)
        ui_print "❌ Apenas Moto G24 suportado!"
        ui_print "   Detectado: $DEVICE"
        abort
        ;;
esac

# Extrai arquivos do ZIP (já mantém a estrutura original)
ui_print "- Extraindo arquivos..."
unzip -o "$ZIPFILE" -d "$MODPATH" >&2

# Define permissões
ui_print "- Definindo permissões..."

# Permissão para o booster.sh (no caminho correto que já vem no ZIP)
set_perm "$MODPATH/system/bin/booster.sh" 0 0 0755
set_perm "$MODPATH/common" 0 0 0755

# Configura alias no Termux
ui_print "- Configurando integração com Termux..."

TERMUX_RC="/data/data/com.termux/files/home/.bashrc"
if [ -f "$TERMUX_RC" ]; then
    # Remove alias antigo
    sed -i '/alias play=/d' "$TERMUX_RC"
    
    # Adiciona alias
    echo 'alias play="su -c '\''/data/data/com.termux/files/usr/bin/bash /data/adb/modules/GameHub-PRO-X/system/bin/booster.sh'\''"' >> "$TERMUX_RC"
    
    # Ajusta dono
    chown $(stat -c '%u' /data/data/com.termux) "$TERMUX_RC" 2>/dev/null
    
    ui_print "✔ Alias 'play' adicionado ao Termux"
fi

ui_print "═══════════════════════════════════════"
ui_print "✅ GameHub Pro X instalado!"
ui_print "═══════════════════════════════════════"
ui_print ""
ui_print "📱 No Termux, digite: play"
ui_print ""
ui_print "🎮 Divirta-se!"
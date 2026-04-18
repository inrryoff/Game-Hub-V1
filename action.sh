#!/system/bin/sh

MODDIR=${0%/*}
LOGFILE="$MODDIR/install.log"

echo "════════════════════════════════════════════════"
echo " "
echo "  ██████╗ ██╗  ██╗██╗   ██╗██████╗ "
echo " ██╔════╝ ██║  ██║██║   ██║██╔══██╗"
echo " ██║  ███╗███████║██║   ██║██████╔╝"
echo " ██║   ██║██╔══██║██║   ██║██╔══██╗"
echo " ╚██████╔╝██║  ██║╚██████╔╝██████╔╝"
echo "  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ "
echo "            GameHub - PRO  -  X"
echo "               BY: @INRRYOFF"
echo " "
echo "════════════════════════════════════════════════"

echo "=================================="
echo "      BuSy - Informações"
echo "=================================="

if [ -f "$LOGFILE" ]; then
    cat "$LOGFILE"
else
    echo "Erro: install.log não encontrado."
fi

echo " "
echo "=================="
echo "[Vol +] Abrir GitHub"
echo "[Vol -] Sair"
echo "=================="

while true; do
    while read -r line; do
        case "$line" in
            *KEY_VOLUMEUP*DOWN*)
                echo ""
                echo "═══════════════════════════════════════"
                echo "🔗 Abrindo GitHub do desenvolvedor..."
                echo "═══════════════════════════════════════"
                sleep 1
                nohup am start -a android.intent.action.VIEW -d "https://github.com/inrryoff" >/dev/null 2>&1 &
                exit 0
            ;;
            *KEY_VOLUMEDOWN*DOWN*)
                echo "Saindo..."
                exit 0
            ;;
        esac
    done < <(getevent -l 2>/dev/null)
done
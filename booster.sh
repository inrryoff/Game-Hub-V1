#!/system/bin/sh
MODPATH="/data/adb/modules/gamehub_termux"
CONFIG="$MODPATH/common/config.cfg"
PROTECTED_FILE="$MODPATH/common/protected.list"

# Cores
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Seus apps críticos originais + sistema
CRITICAL=("android" "com.android.systemui" "com.android.settings" "com.termux" "com.google.android.inputmethod.latin" "com.google.android.gms")

# Garante permissões e pastas
mkdir -p "$MODPATH/common"
touch "$CONFIG" "$PROTECTED_FILE"

pause() {
    echo -n -e "\n${YELLOW}Pressione ENTER para continuar...${NC}"
    read _unused
}

carregar_whitelist() {
    if [ ! -s "$PROTECTED_FILE" ]; then
        echo -e "${YELLOW}Criando/Resetando withe.list...${NC}"
        printf "%s\n" "${CRITICAL[@]}" > "$PROTECTED_FILE"
    fi

    WHITELIST=()
    while read -r line || [ -n "$line" ]; do
    case "$line" in
        \#*|"") continue ;;
    esac
    WHITELIST+=("$(echo "$line" | xargs)")
done < "$PROTECTED_FILE"

    # 3. Garante que os CRITICAL sempre estejam na lista (redundância de segurança)
    for c in "${CRITICAL[@]}"; do
        WHITELIST+=("$c")
    done
}


exterminar_apps() {
    carregar_whitelist
    echo -e "${RED}--- EXTERMINANDO APPS E SERVIÇOS (MODO BRUTO) ---${NC}"
    
    # Pega todos os pacotes do sistema
    TODOS_APPS=$(pm list packages | cut -d: -f2)
    
    for app in $TODOS_APPS; do
        skip=false
        for w in "${WHITELIST[@]}"; do
            if [ "$app" = "$w" ]; then
                skip=true
                break
            fi
        done
        
        if [ "$skip" = false ]; then
            echo "Fechando: $app"
            am force-stop "$app"
        fi
    done

    # Limpeza profunda de memória
    echo -e "${CYAN}Limpando Caches e RAM...${NC}"
    pm trim-caches 999G > /dev/null 2>&1
    echo 3 > /proc/sys/vm/drop_caches
    sync
    echo -e "${GREEN}RAM limpa com sucesso!${NC}"
}

carregar_jogos() {
    NAMES=()
    PKGS=()
    if [ -s "$CONFIG" ]; then
        while IFS="|" read -r name pkg || [ -n "$name" ]; do
            [ -z "$name" ] && continue
            
            NAMES+=("$name")
            PKGS+=("$pkg")
        done <<EOF
$(grep -v '^#' "$CONFIG" | grep -v '^$')
EOF
    fi
}


jogar() {
    echo -e "${CYAN}Resetando ZRAM...${NC}"

    if [ -f /data/adb/modules/ZramTG24/ram.sh ]; then
        sh /data/adb/modules/ZramTG24/ram.sh
        echo -e "${GREEN}ZRAM resetada!${NC}"
    else
        echo -e "${YELLOW}Módulo ZRAM não encontrado, pulando...${NC}"
    fi

    sleep 2

    exterminar_apps

    carregar_jogos
    if [ ${#NAMES[@]} -eq 0 ]; then
        echo -e "${RED}Nenhum jogo cadastrado! Vá na opção [3].${NC}"
        pause
        return
    fi

    echo -e "${CYAN}--- SELECIONE O JOGO ---${NC}"
    for i in "${!NAMES[@]}"; do
        echo -e "${GREEN}$((i+1))) ${NAMES[$i]}${NC}"
    done
    echo -n "Escolha o número: "
    read escolha

    idx=$((escolha - 1))
    PKG=${PKGS[$idx]}
    NOME=${NAMES[$idx]}

    if [ -z "$PKG" ]; then
        echo -e "${RED}Opção inválida!${NC}"
        pause
        return
    fi

    echo -e "${GREEN}Abrindo $NOME...${NC}"
    monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 > /dev/null 2>&1
    
    echo "Aguardando inicialização (8s)..."
    sleep 8
    
    PIDS=$(pidof "$PKG")
    if [ ! -z "$PIDS" ]; then
        for p in $PIDS; do
            echo -1000 > "/proc/$p/oom_score_adj"
            renice -n -20 -p "$p"
            ionice -c 1 -n 0 -p "$p"
        done
        echo -e "${GREEN}Proteção OOM e Boost CPU/IO Aplicados!${NC}"
    else
        echo -e "${RED}Erro: Jogo não detectado.${NC}"
    fi

    echo "Fechando Termux em 5 segundos..."
    sleep 5
    am force-stop com.termux
}

adicionar_jogo() {
    echo -n "Nome do jogo: "
    read nome
    echo -n "Pacote (ex: com.mojang.minecraftpe): "
    read pkg
    echo "$nome|$pkg" >> "$CONFIG"
    echo -e "${GREEN}Jogo adicionado!${NC}"
    pause
}

adicionar_whitelist() {
    echo -n "Pacote para proteger (ex: com.whatsapp): "
    read pkg
    echo "$pkg" >> "$PROTECTED_FILE"
    echo -e "${GREEN}App protegido com sucesso!${NC}"
    pause
}

menu() {
    while true; do
        clear
        echo -e "${CYAN}==== GAME HUB PRO (ROOT) ====${NC}"
        echo -e "${GREEN}[1] ▶ Jogar (Exterminar + Boost)${NC}"
        echo -e "${GREEN}[2] 🧹 Apenas Limpar RAM (Bruto)${NC}"
        echo -e "${YELLOW}[3] ➕ Adicionar Novo Jogo${NC}"
        echo -e "${YELLOW}[4] 🛡 Proteger App (Whitelist)${NC}"
        echo -e "${RED}[5] ❌ Sair${NC}"
        echo ""
        echo -n "Escolha uma opção: "
        read op
        case $op in
            1) jogar ;;
            2) exterminar_apps; pause ;;
            3) adicionar_jogo ;;
            4) adicionar_whitelist ;;
            5) exit 0 ;;
            *) echo "Opção inválida!"; sleep 1 ;;
        esac
    done
}

menu

BASE_PATH="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="$BASE_PATH/MacApp"
ONLINE_FILE="$BASE_PATH/online.txt"
LOG_FILE="$BASE_PATH/install-log.txt"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

clear

echo "======================================="
echo "      Sousify - macOS"
echo "======================================="
echo "Sistema: $(sw_vers -productName) $(sw_vers -productVersion)"
echo

echo "1 - Instalação Offline"
echo "2 - Instalação Online"
echo
echo "Pressione CTRL+C para cancelar."
echo

read -p "Escolha uma opção: " OPTION

# Verificar Homebrew

if ! command -v brew >/dev/null 2>&1; then
    echo
    echo "Homebrew não encontrado."

    read -p "Deseja instalá-lo? (S/N): " INSTALL_BREW

    if [[ "$INSTALL_BREW" =~ ^[Ss]$ ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "O Homebrew é necessário para instalações online."
    fi
fi

# OFFLINE

if [ "$OPTION" = "1" ]; then

    files=("$APP_PATH"/*)

    TOTAL=${#files[@]}
    COUNT=0

    log "Modo Offline iniciado."

    for file in "${files[@]}"; do

        [ -f "$file" ] || continue

        COUNT=$((COUNT+1))
        PERCENT=$((COUNT*100/TOTAL))

        echo
        echo "[$COUNT/$TOTAL - ${PERCENT}%]"
        echo "Instalando $(basename "$file")"

        log "Instalando $(basename "$file")"

        open "$file"

        echo "Quando a instalação terminar, pressione ENTER para continuar..."
        read

        log "Concluído $(basename "$file")"

    done

    echo
    echo "Instalação concluída."

# ONLINE

elif [ "$OPTION" = "2" ]; then

    mapfile -t COMMANDS < "$ONLINE_FILE"

    TOTAL=${#COMMANDS[@]}
    COUNT=0

    log "Modo Online iniciado."

    for CMD in "${COMMANDS[@]}"; do

        [ -z "$CMD" ] && continue

        COUNT=$((COUNT+1))
        PERCENT=$((COUNT*100/TOTAL))

        echo
        echo "[$COUNT/$TOTAL - ${PERCENT}%]"
        echo "$CMD"

        log "$CMD"

        eval "$CMD"

        log "Concluído"

    done

    echo
    echo "Instalação concluída."

else

    echo
    echo "Opção inválida."

fi
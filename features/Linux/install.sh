
BASE_PATH="$(cd "$(dirname "$0")" && pwd)"
LIN_APP="$BASE_PATH/LinApp"
ONLINE="$BASE_PATH/online.txt"
LOG="$BASE_PATH/install-log.txt"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
}

OS_NAME=$(uname -a)

clear
echo "==================================="
echo "   Sousify - LINUX - https://github.com/manuelhonoredesousa/Sousify"
echo "   $OS_NAME"
echo "==================================="
echo ""
echo "1 - Offline (LinApp)"
echo "2 - Online (online.txt)"
echo "CTRL + C para cancelar"
echo ""

read -p "Escolha: " mode

if [ "$mode" == "1" ]; then

    echo ""
    echo "Modo OFFLINE iniciado..."
    log "OFFLINE iniciado"

    files=("$LIN_APP"/*)
    total=${#files[@]}
    i=0

    for file in "${files[@]}"; do

        i=$((i+1))
        percent=$((i * 100 / total))

        echo ""
        echo "[$i/$total - $percent%] Instalando: $(basename "$file")"
        log "Instalando: $file"

        if [[ "$file" == *.deb ]]; then
            sudo apt install -y "$file"
        fi

        echo "Concluido: $(basename "$file")"
        log "Concluido: $file"
    done

    echo ""
    echo "Instalacao offline finalizada!"
    log "OFFLINE finalizado"

elif [ "$mode" == "2" ]; then

    echo ""
    echo "Modo ONLINE iniciado..."
    log "ONLINE iniciado"

    mapfile -t commands < "$ONLINE"
    total=${#commands[@]}
    i=0

    for cmd in "${commands[@]}"; do

        if [ -n "$cmd" ]; then

            i=$((i+1))
            percent=$((i * 100 / total))

            echo ""
            echo "[$i/$total - $percent%] Executando: $cmd"
            log "Executando: $cmd"

            eval "$cmd"

            echo "Concluido"
            log "Concluido: $cmd"
        fi
    done

    echo ""
    echo "Instalacao online finalizada!"
    log "ONLINE finalizado"
else
    echo "Opção inválida"
fi
#!/bin/bash

# Скрипт для автоматического обновления PKGBUILD для cursor-app
# Автор: mazixs

set -euo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для логирования
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Переменные
PKGBUILD_FILE="PKGBUILD"
BACKUP_FILE="${PKGBUILD_FILE}.backup"
CURSOR_API_URL="https://api.github.com/repos/getcursor/cursor/releases/latest"
CURSOR_DOWNLOAD_URL="https://downloader.cursor.sh/linux/appImage/x64"

# Флаги
FORCE_UPDATE=false
AUTO_COMMIT=false
DRY_RUN=false

# Функция помощи
show_help() {
    cat << EOF
Использование: $0 [ОПЦИИ]

Опции:
  -f, --force         Принудительное обновление даже если версия не изменилась
  -c, --commit        Автоматический коммит изменений в git
  -d, --dry-run       Показать что будет изменено без применения изменений
  -h, --help          Показать эту справку

Примеры:
  $0                  Обычное обновление
  $0 --force          Принудительное обновление
  $0 --commit         Обновление с автоматическим коммитом
  $0 --dry-run        Предварительный просмотр изменений

Зависимости:
  - curl (для API запросов)
  - jq (для парсинга JSON)
  - makepkg (для генерации .SRCINFO)
  - git (для коммитов, опционально)
EOF
}

# Проверка зависимостей
check_dependencies() {
    local deps=("curl" "jq" "makepkg")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Отсутствуют зависимости: ${missing_deps[*]}"
        log_info "Установите их с помощью: pacman -S ${missing_deps[*]}"
        exit 1
    fi
    
    if [[ "$AUTO_COMMIT" == true ]] && ! command -v git &> /dev/null; then
        log_error "Git не найден, но требуется для автоматического коммита"
        exit 1
    fi
}

# Получение последней версии Cursor
get_latest_version() {
    log_info "Получение информации о последней версии Cursor..."
    
    local response
    if ! response=$(curl -s "$CURSOR_API_URL"); then
        log_error "Не удалось получить информацию о релизах Cursor"
        return 1
    fi
    
    local version
    if ! version=$(echo "$response" | jq -r '.tag_name // empty'); then
        log_error "Не удалось парсить ответ API"
        return 1
    fi
    
    if [[ -z "$version" || "$version" == "null" ]]; then
        log_error "Не удалось получить версию из API"
        return 1
    fi
    
    # Убираем префикс 'v' если есть
    version=${version#v}
    
    echo "$version"
}

# Получение текущей версии из PKGBUILD
get_current_version() {
    if [[ ! -f "$PKGBUILD_FILE" ]]; then
        log_error "Файл $PKGBUILD_FILE не найден"
        return 1
    fi
    
    grep '^pkgver=' "$PKGBUILD_FILE" | cut -d'=' -f2
}

# Обновление PKGBUILD
update_pkgbuild() {
    local new_version="$1"
    local current_version="$2"
    
    log_info "Обновление PKGBUILD с версии $current_version на $new_version"
    
    # Создаем резервную копию
    cp "$PKGBUILD_FILE" "$BACKUP_FILE"
    log_info "Создана резервная копия: $BACKUP_FILE"
    
    # Обновляем версию
    sed -i "s/^pkgver=.*/pkgver=$new_version/" "$PKGBUILD_FILE"
    
    # Сбрасываем pkgrel на 1
    sed -i 's/^pkgrel=.*/pkgrel=1/' "$PKGBUILD_FILE"
    
    # Обновляем URL источника
    sed -i "s|cursor-.*\.AppImage::|cursor-${new_version}.AppImage::|" "$PKGBUILD_FILE"
    
    log_success "PKGBUILD обновлен"
}

# Генерация .SRCINFO
generate_srcinfo() {
    log_info "Генерация .SRCINFO..."
    
    if makepkg --printsrcinfo > .SRCINFO; then
        log_success ".SRCINFO сгенерирован"
    else
        log_error "Ошибка при генерации .SRCINFO"
        return 1
    fi
}

# Коммит изменений
commit_changes() {
    local version="$1"
    
    if [[ ! -d ".git" ]]; then
        log_warning "Не git репозиторий, пропускаем коммит"
        return 0
    fi
    
    log_info "Коммит изменений..."
    
    git add "$PKGBUILD_FILE" .SRCINFO
    git commit -m "Update cursor-app to version $version"
    
    log_success "Изменения закоммичены"
}

# Показ изменений (dry run)
show_changes() {
    local new_version="$1"
    local current_version="$2"
    
    echo
    log_info "Предварительный просмотр изменений:"
    echo "  Текущая версия: $current_version"
    echo "  Новая версия: $new_version"
    echo "  URL загрузки: $CURSOR_DOWNLOAD_URL"
    echo
    
    if [[ "$current_version" == "$new_version" ]]; then
        log_warning "Версии одинаковые, изменений не будет"
    else
        log_info "Будут обновлены:"
        echo "  - pkgver: $current_version -> $new_version"
        echo "  - pkgrel: будет сброшен на 1"
        echo "  - source URL: будет обновлен"
        echo "  - .SRCINFO: будет перегенерирован"
    fi
}

# Основная функция
main() {
    log_info "Запуск скрипта обновления cursor-app"
    
    # Проверяем зависимости
    check_dependencies
    
    # Получаем версии
    local latest_version
    if ! latest_version=$(get_latest_version); then
        exit 1
    fi
    
    local current_version
    if ! current_version=$(get_current_version); then
        exit 1
    fi
    
    log_info "Текущая версия: $current_version"
    log_info "Последняя версия: $latest_version"
    
    # Проверяем нужно ли обновление
    if [[ "$current_version" == "$latest_version" && "$FORCE_UPDATE" != true ]]; then
        log_success "Уже используется последняя версия ($latest_version)"
        exit 0
    fi
    
    # Dry run
    if [[ "$DRY_RUN" == true ]]; then
        show_changes "$latest_version" "$current_version"
        exit 0
    fi
    
    # Обновляем PKGBUILD
    if ! update_pkgbuild "$latest_version" "$current_version"; then
        exit 1
    fi
    
    # Генерируем .SRCINFO
    if ! generate_srcinfo; then
        log_error "Восстанавливаем из резервной копии..."
        mv "$BACKUP_FILE" "$PKGBUILD_FILE"
        exit 1
    fi
    
    # Коммитим изменения если нужно
    if [[ "$AUTO_COMMIT" == true ]]; then
        commit_changes "$latest_version"
    fi
    
    # Удаляем резервную копию
    rm -f "$BACKUP_FILE"
    
    log_success "Обновление завершено успешно!"
    log_info "Новая версия: $latest_version"
    
    if [[ "$AUTO_COMMIT" != true ]]; then
        log_info "Для коммита изменений выполните:"
        echo "  git add PKGBUILD .SRCINFO"
        echo "  git commit -m 'Update cursor-app to version $latest_version'"
    fi
}

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_UPDATE=true
            shift
            ;;
        -c|--commit)
            AUTO_COMMIT=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Неизвестная опция: $1"
            show_help
            exit 1
            ;;
    esac
done

# Запуск основной функции
main
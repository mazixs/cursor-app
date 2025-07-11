# Cursor App - Arch Linux Package

Этот репозиторий содержит PKGBUILD для установки [Cursor](https://cursor.so) - AI-первого редактора кода на Arch Linux.

## Установка

### Из AUR (рекомендуется)

```bash
# Используя yay
yay -S cursor-app

# Используя paru
paru -S cursor-app
```

### Ручная сборка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/mazixs/cursor-app.git
cd cursor-app
```

2. Соберите и установите пакет:
```bash
makepkg -si
```

## Использование

После установки Cursor можно запустить:

- Из меню приложений
- Из терминала: `cursor`
- Открыть файл: `cursor /path/to/file`
- Открыть папку: `cursor /path/to/directory`

## Особенности

- Автоматическое извлечение AppImage
- Интеграция с системой (desktop файл, иконки)
- Поддержка всех функций оригинального Cursor
- Регулярные обновления

## Зависимости

### Обязательные:
- gtk3
- libxss
- gconf
- nss
- alsa-lib

### Опциональные:
- libappindicator-gtk3 (для поддержки системного трея)

## Обновление

Для обновления до новой версии:

```bash
# Обновите PKGBUILD (если собираете вручную)
git pull
makepkg -si

# Или используйте AUR helper
yay -Syu cursor-app
```

## Автоматическое обновление

В репозитории есть скрипт `update_cursor_api.sh` для автоматического обновления PKGBUILD:

```bash
./update_cursor_api.sh --help
```

## Устранение неполадок

### Проблемы с загрузкой

Если возникают проблемы с загрузкой AppImage:

1. Проверьте интернет-соединение
2. Убедитесь, что URL актуален: https://downloader.cursor.sh/linux/appImage/x64
3. Попробуйте обновить пакет

### Проблемы с запуском

Если Cursor не запускается:

1. Проверьте зависимости: `pacman -Q gtk3 libxss gconf nss alsa-lib`
2. Запустите из терминала для просмотра ошибок: `cursor`
3. Проверьте права доступа: `ls -la /opt/cursor-app/`

## Вклад в проект

Вклады приветствуются! Пожалуйста:

1. Форкните репозиторий
2. Создайте ветку для ваших изменений
3. Сделайте коммит с описательным сообщением
4. Отправьте Pull Request

## Проблемы и предложения

Если у вас есть проблемы или предложения, пожалуйста, создайте [issue](https://github.com/mazixs/cursor-app/issues).

## Лицензия

Этот PKGBUILD распространяется под лицензией MIT. Сам Cursor имеет собственную лицензию.

## Ссылки

- [Официальный сайт Cursor](https://cursor.so)
- [Документация Cursor](https://docs.cursor.so)
- [Arch Linux Wiki - PKGBUILD](https://wiki.archlinux.org/title/PKGBUILD)
- [AUR Guidelines](https://wiki.archlinux.org/title/AUR_submission_guidelines)

---

**Примечание**: Этот пакет не является официальным. Для получения поддержки по самому Cursor обращайтесь к [официальной документации](https://docs.cursor.so).
# Настройка GitHub Actions для автоматического деплоя

Этот документ описывает процесс настройки CI/CD пайплайна для автоматической сборки и развертывания landing-страницы RunbookAI.

## 📋 Обзор процесса

При каждом пуше в ветку `main` происходит:

1. **Сборка Docker-образа** и публикация в GitHub Container Registry (GHCR)
2. **Подключение к серверу** по SSH
3. **Обновление кода** через `git pull`
4. **Обновление и перезапуск контейнеров** через `docker compose`

## 🔧 Необходимые GitHub Secrets

Для работы пайплайна необходимо настроить следующие секреты в репозитории:

### Как добавить секреты:

1. Перейдите в репозиторий GitHub
2. Откройте **Settings** → **Secrets and variables** → **Actions**
3. Нажмите **New repository secret**
4. Добавьте каждый из следующих секретов:

### Список секретов:

| Имя секрета | Описание | Пример значения |
|-------------|----------|-----------------|
| `DEPLOY_SSH_HOST` | IP-адрес или домен сервера для деплоя | `123.45.67.89` или `server.example.com` |
| `DEPLOY_SSH_USER` | Имя пользователя для SSH-подключения | `deploy` или `ubuntu` |
| `DEPLOY_SSH_KEY` | Приватный SSH-ключ для аутентификации | Содержимое файла `~/.ssh/id_rsa` |

> **Примечание**: `GITHUB_TOKEN` создается автоматически и не требует ручной настройки.

## 🔑 Генерация SSH-ключа

Если у вас еще нет SSH-ключа для деплоя, создайте его:

```bash
# Генерация нового SSH-ключа
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_deploy_key

# Копирование публичного ключа на сервер
ssh-copy-id -i ~/.ssh/github_deploy_key.pub user@server.example.com

# Вывод приватного ключа для добавления в GitHub Secrets
cat ~/.ssh/github_deploy_key
```

**Важно**: Скопируйте ВЕСЬ вывод команды `cat`, включая строки `-----BEGIN OPENSSH PRIVATE KEY-----` и `-----END OPENSSH PRIVATE KEY-----`.

## 📁 Требования к серверу

### Структура директорий

На сервере должна существовать директория `~/landing` с клонированным репозиторием:

```bash
# Клонирование репозитория (выполнить на сервере один раз)
cd ~
git clone https://github.com/YOUR_USERNAME/runbookai-landing.git landing
cd landing
```

### Установленное ПО

На сервере должны быть установлены:

- **Git** (для обновления кода)
- **Docker** (версия 20.10+)
- **Docker Compose** (версия 2.0+)

Проверка установки:

```bash
git --version
docker --version
docker compose version
```

### Переменные окружения на сервере

Создайте файл `.env` в директории `~/landing`:

```bash
# ~/landing/.env
GITHUB_REPOSITORY_OWNER=your-github-username
APP_URL=https://app.runbookai.com
PRICE=2400
FUNCTIONS_COUNT=500
```

## 🚀 Процесс деплоя

После настройки секретов и подготовки сервера:

1. Внесите изменения в код
2. Закоммитьте и запушьте в ветку `main`:

```bash
git add .
git commit -m "Update landing page"
git push origin main
```

3. GitHub Actions автоматически:
   - Соберет Docker-образ
   - Опубликует его в GHCR
   - Подключится к серверу
   - Обновит код и перезапустит контейнеры

## 📊 Мониторинг деплоя

Отслеживайте процесс деплоя:

1. Перейдите во вкладку **Actions** в репозитории
2. Выберите последний запуск workflow **"Build and Deploy to Landing"**
3. Просматривайте логи каждого шага

## 🔍 Устранение неполадок

### Ошибка аутентификации SSH

```
Permission denied (publickey)
```

**Решение**: Убедитесь, что:
- Приватный ключ в `DEPLOY_SSH_KEY` соответствует публичному ключу на сервере
- Публичный ключ добавлен в `~/.ssh/authorized_keys` на сервере
- Права доступа корректны: `chmod 600 ~/.ssh/authorized_keys`

### Ошибка при git pull

```
error: Your local changes to the following files would be overwritten by merge
```

**Решение**: На сервере выполните:

```bash
cd ~/landing
git reset --hard origin/main
```

### Ошибка при docker compose

```
ERROR: for web  Cannot create container for service web
```

**Решение**: Проверьте:
- Docker запущен: `sudo systemctl status docker`
- Переменная `GITHUB_REPOSITORY_OWNER` установлена в `.env`
- Образ доступен: `docker pull ghcr.io/YOUR_USERNAME/runbookai-landing:latest`

## 🔐 Безопасность

- **Никогда** не коммитьте приватные SSH-ключи в репозиторий
- Используйте отдельный SSH-ключ только для деплоя
- Ограничьте права пользователя деплоя на сервере
- Регулярно ротируйте SSH-ключи

## 📝 Дополнительная информация

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

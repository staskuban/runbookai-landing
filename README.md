# RunbookAI Landing Page

JAMstack лендинг на базе Docker и Nginx.

## 🚀 Быстрый старт

### Запуск проекта

```bash
docker-compose up -d
```

Сайт будет доступен по адресу: http://localhost:2000

### Конфигурация переменных окружения

Лендинг поддерживает следующие конфигурируемые параметры:

- **APP_URL** (по умолчанию: `http://localhost:3000`) - URL приложения для CTA кнопок
- **PRICE** (по умолчанию: `2400`) - цена за 1M токенов
- **FUNCTIONS_COUNT** (по умолчанию: `500`) - количество функций с автоматическим склонением

Пример изменения через файл `.env`:

```env
APP_URL=http://localhost:3000
PRICE=2400
FUNCTIONS_COUNT=500
```

Подробнее: [docs/APP_URL_CONFIGURATION.md](docs/APP_URL_CONFIGURATION.md)

### Остановка

```bash
docker-compose down
```

### Пересборка

```bash
docker-compose up -d --build
```

## 📁 Структура проекта

```
.
├── public/           # Статические файлы
│   └── index.html   # Главная страница
├── nginx.conf       # Конфигурация Nginx
├── Dockerfile       # Docker образ
└── docker-compose.yml
```

## 🔧 Технологии

- **JAMstack**: Статический HTML с Tailwind CSS
- **Nginx**: 1.25-alpine (легковесный веб-сервер)
- **Docker**: Контейнеризация
- **Docker Compose**: Оркестрация

## 🏗️ Архитектура

- Порт: **2000**
- Health check endpoint: `/health`
- Gzip сжатие включено
- Кеширование статических ресурсов (1 год)
- Security headers настроены
- Динамическая подстановка переменных окружения через `envsubst`:
  - `APP_URL` - URL приложения
  - `PRICE` - цена за токены
  - `FUNCTIONS_COUNT` - количество функций
  - `FUNCTIONS_WORD` - автоматическое склонение слова "функция"

## 📊 Health Check

Проверка состояния контейнера:

```bash
docker-compose ps
curl http://localhost:5000/health
```

## 🔍 Логи

```bash
docker-compose logs -f web
```

## 🛠️ Разработка

Для внесения изменений:

1. Отредактируйте файлы в папке `public/`
2. Пересоберите контейнер: `docker-compose up -d --build`
3. Проверьте изменения в браузере

## 📝 Лицензия

Все права защищены © 2024

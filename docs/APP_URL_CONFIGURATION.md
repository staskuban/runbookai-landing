# Конфигурация переменных окружения

## Описание

Лендинг поддерживает конфигурирование через переменные окружения:

- **APP_URL** - URL приложения для CTA кнопок ("Начать работу", "Попробовать бесплатно", "Создать аккаунт")
- **PRICE** - цена за 1M токенов в блоке прайсинга
- **FUNCTIONS_COUNT** - количество функций кода в описании прайсинга (с автоматическим склонением слова "функция")

## Принцип работы

1. В [docker-compose.yml](../docker-compose.yml) задаются переменные окружения `APP_URL`, `PRICE` и `FUNCTIONS_COUNT`
2. При старте контейнера [docker-entrypoint.sh](../docker-entrypoint.sh):
   - Определяет правильную форму слова "функция" на основе `FUNCTIONS_COUNT`
   - Создает переменную `FUNCTIONS_WORD` с правильным склонением
   - Использует `envsubst` для подстановки всех значений в HTML
3. Шаблон [index.html.template](../public/index.html) содержит плейсхолдеры `${APP_URL}`, `${PRICE}`, `${FUNCTIONS_COUNT}` и `${FUNCTIONS_WORD}`
4. На выходе получается готовый [index.html](../public/index.html) с подставленными значениями и правильным склонением

## Как изменить значения

### Способ 1: Через переменную окружения в shell

```bash
export APP_URL=http://localhost:5000
export PRICE=3000
export FUNCTIONS_COUNT=750
docker-compose up -d
```

### Способ 2: Через файл .env

Создайте файл `.env` в корне проекта:

```env
APP_URL=http://localhost:5000
PRICE=3000
FUNCTIONS_COUNT=750
```

Затем запустите:

```bash
docker-compose up -d
```

### Способ 3: Напрямую в docker-compose.yml

Отредактируйте [docker-compose.yml](../docker-compose.yml):

```yaml
environment:
  - APP_URL=http://localhost:5000
  - PRICE=3000
  - FUNCTIONS_COUNT=750
```

## Значения по умолчанию

Если переменные не заданы, используются следующие значения по умолчанию:

- **APP_URL**: `http://localhost:3000`
- **PRICE**: `2400`
- **FUNCTIONS_COUNT**: `500`

Значения заданы в [docker-compose.yml](../docker-compose.yml):

```yaml
environment:
  - APP_URL=${APP_URL:-http://localhost:3000}
  - PRICE=${PRICE:-2400}
  - FUNCTIONS_COUNT=${FUNCTIONS_COUNT:-500}
```

## Проверка работы

После запуска контейнера можно проверить, что значения подставились правильно:

### Проверка APP_URL
```bash
docker exec runbookai-landing grep 'href=' /usr/share/nginx/html/index.html | head -5
```

Вы должны увидеть ссылки с вашим настроенным URL.

### Проверка PRICE
```bash
docker exec runbookai-landing grep -A 2 'Стартовый пакет' /usr/share/nginx/html/index.html | grep '₽'
```

Вы должны увидеть цену в формате `₽ ВАША_ЦЕНА`.

### Проверка FUNCTIONS_COUNT
```bash
docker exec runbookai-landing grep 'Достаточно для' /usr/share/nginx/html/index.html
```

Вы должны увидеть правильно склоненное слово "функция":
- Для 1, 21, 31, ... → "функция"
- Для 2, 3, 4, 22, 23, 24, ... → "функции"
- Для 5-20, 25-30, ... → "функций"

## Примеры использования

### Для локальной разработки
```bash
export APP_URL=http://localhost:3000
export PRICE=1500
export FUNCTIONS_COUNT=300
docker-compose up -d
```

Результат: "Достаточно для ~300 **функций** кода"

### Для продакшена
```bash
export APP_URL=https://app.yourdomain.com
export PRICE=2400
export FUNCTIONS_COUNT=500
docker-compose up -d
```

Результат: "Достаточно для ~500 **функций** кода"

### Для staging
```bash
export APP_URL=https://staging-app.yourdomain.com
export PRICE=2000
export FUNCTIONS_COUNT=401
docker-compose up -d
```

Результат: "Достаточно для ~401 **функция** кода"

### Примеры склонения

Слово "функция" автоматически склоняется:

| FUNCTIONS_COUNT | Результат |
|-----------------|-----------|
| 1 | Достаточно для ~1 **функция** кода |
| 2 | Достаточно для ~2 **функции** кода |
| 5 | Достаточно для ~5 **функций** кода |
| 21 | Достаточно для ~21 **функция** кода |
| 22 | Достаточно для ~22 **функции** кода |
| 25 | Достаточно для ~25 **функций** кода |
| 100 | Достаточно для ~100 **функций** кода |
| 101 | Достаточно для ~101 **функция** кода |

## Затронутые элементы

### APP_URL

Следующие кнопки на лендинге ведут на `APP_URL`:

1. **"Начать работу"** - в навигационной панели ([index.html:120](../public/index.html#L120))
2. **"Попробовать бесплатно"** - в hero секции ([index.html:148](../public/index.html#L148))
3. **"Создать аккаунт"** - в секции призыва к действию ([index.html:429](../public/index.html#L429))

### PRICE

Отображается цена в блоке прайсинга:

1. **Стартовый пакет** - секция с ценами ([index.html:401](../public/index.html#L401))

### FUNCTIONS_COUNT

Отображается количество функций кода с правильным склонением:

1. **Описание прайсинга** - "Достаточно для ~N функций/функции/функция кода" ([index.html:407](../public/index.html#L407))

## Технические детали

- **Инструмент**: `envsubst` из пакета `gettext`
- **Переменные**: `APP_URL`, `PRICE`, `FUNCTIONS_COUNT`, `FUNCTIONS_WORD` (вычисляется автоматически)
- **Шаблон**: `/usr/share/nginx/html/index.html.template`
- **Результат**: `/usr/share/nginx/html/index.html`
- **Entrypoint**: [/docker-entrypoint.sh](../docker-entrypoint.sh)

### Алгоритм склонения

Функция `pluralize_functions()` в entrypoint скрипте определяет правильную форму слова:

```sh
pluralize_functions() {
    local n=$1
    local mod100=$((n % 100))
    local mod10=$((n % 10))

    # Для 11-19 всегда "функций"
    if [ $mod100 -ge 11 ] && [ $mod100 -le 19 ]; then
        echo "функций"
    # Для чисел, оканчивающихся на 1 → "функция"
    elif [ $mod10 -eq 1 ]; then
        echo "функция"
    # Для чисел, оканчивающихся на 2, 3, 4 → "функции"
    elif [ $mod10 -ge 2 ] && [ $mod10 -le 4 ]; then
        echo "функции"
    # Для всех остальных → "функций"
    else
        echo "функций"
    fi
}
```

### Команда подстановки

```sh
envsubst '${APP_URL} ${PRICE} ${FUNCTIONS_COUNT} ${FUNCTIONS_WORD}' < index.html.template > index.html
```

## Troubleshooting

### URL не подставляется

1. Проверьте, что переменная окружения задана:
   ```bash
   docker exec runbookai-landing env | grep APP_URL
   ```

2. Проверьте логи контейнера:
   ```bash
   docker logs runbookai-landing
   ```

3. Пересоберите и перезапустите контейнер:
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

### Старое значение остается после изменения

Необходимо пересоздать контейнер:
```bash
docker-compose down
docker-compose up -d
```

Или принудительно пересоздать:
```bash
docker-compose up -d --force-recreate
```

## Dockerized Django Project

Проєкт містить Django-застосунок, PostgreSQL базу даних та Nginx вебсервер, налаштовані через Docker Compose.

### Стек

- Python 3.11
- Django
- PostgreSQL 16
- Nginx 1.27
- Docker
- Docker Compose

### Структура проєкту

```text
.
├── config/
│   ├── settings.py
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
├── nginx/
│   └── nginx.conf
├── Dockerfile
├── docker-compose.yml
├── manage.py
├── requirements.txt
├── .env.example
└── README.md
```

### Сервіси Docker Compose

- `web` — Django-застосунок
- `db` — PostgreSQL база даних
- `nginx` — вебсервер для проксирування запитів до Django

### Налаштування змінних середовища

Приклад змінних знаходиться у файлі:

```text
.env.example
```

Перед запуском проєкту створіть локальний файл `.env` на основі `.env.example`:

```bash
cp .env.example .env
```

Файл `.env` не додається в Git, оскільки він може містити локальні значення змінних середовища.

Для запуску можна залишити значення з `.env.example` без змін.

### Запуск проєкту

Створити локальний файл `.env`:

```bash
cp .env.example .env
```

Запустити всі сервіси:

```bash
docker compose up -d
```

Перевірити статус контейнерів:

```bash
docker compose ps
```

Застосувати міграції Django:

```bash
docker compose exec web python manage.py migrate
```

Після запуску застосунок буде доступний за адресою:

```text
http://localhost
```

### Перевірка доступності через Nginx

Перевірити HTTP-відповідь застосунку:

```bash
curl -I http://localhost
```

Очікуваний результат:

```text
HTTP/1.1 200 OK
```

### Перевірка PostgreSQL

Перевірити створені таблиці у базі даних:

```bash
docker compose exec db psql -U django_user -d django_db -c "\dt"
```

Очікувано мають бути створені стандартні таблиці Django, зокрема:

```text
auth_user
auth_group
django_admin_log
django_content_type
django_migrations
django_session
```

### Зупинка проєкту

```bash
docker compose down
```

### Примітка щодо Nginx

Nginx проксирує HTTP-запити до Django-сервісу `web` на порт `8000`.

```nginx
proxy_pass http://web:8000;
```

### Примітка щодо Docker Compose

У проєкті використовується файл:

```text
docker-compose.yml
```

Для запуску використовується сучасна команда Docker Compose v2:

```bash
docker compose up -d
```
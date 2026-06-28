## helm-lesson-7: Розгортання Django-застосунку в AWS EKS за допомогою Helm

### 1. Опис проєкту

Проєкт демонструє розгортання Dockerized Django-застосунку в Kubernetes-кластері AWS EKS. Інфраструктура описується за допомогою Terraform, Docker image зберігається в Amazon ECR, а Kubernetes-ресурси керуються через Helm chart.

Рішення охоплює створення мережевої інфраструктури AWS, EKS-кластера, ECR-репозиторію, збірку Docker image, завантаження image до ECR та розгортання застосунку через Helm.

### 2. Структура проєкту

```text
.
├── app/
│   ├── Dockerfile
│   ├── manage.py
│   ├── requirements.txt
│   ├── config/
│   └── nginx/
├── charts/
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── configmap.yaml
│           ├── deployment.yaml
│           ├── hpa.yaml
│           └── service.yaml
├── modules/
│   ├── ecr/
│   ├── eks/
│   ├── s3-backend/
│   └── vpc/
├── backend.tf
├── main.tf
├── outputs.tf
├── variables.tf
└── README.md
```

### 3. Terraform-інфраструктура

Terraform-конфігурація створює AWS-інфраструктуру в регіоні `us-west-2`.

Основні ресурси:

- VPC;
- public та private subnets;
- Internet Gateway;
- NAT Gateway;
- S3 bucket для remote Terraform state;
- ECR repository `lesson-7-ecr`;
- EKS cluster `lesson-7-eks`;
- EKS node group.

Ініціалізація Terraform:

```bash
terraform init
```

Форматування та перевірка конфігурації:

```bash
terraform fmt -recursive
terraform validate
```

Планування та створення інфраструктури:

```bash
terraform plan
terraform apply
```

Підключення `kubectl` до EKS cluster:

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
```

Перевірка Kubernetes nodes:

```bash
kubectl get nodes
```

### 4. Docker image Django-застосунку

Django-застосунок розміщено в директорії `app/`.

Локальна збірка image:

```bash
docker build -t django-app ./app
```

Для запуску в EKS image збирається під платформу `linux/amd64`:

```bash
docker buildx build \
  --platform linux/amd64 \
  -t 894662486142.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest \
  --push \
  ./app
```

### 5. Amazon ECR

Авторизація Docker в Amazon ECR:

```bash
aws ecr get-login-password --region us-west-2 \
  | docker login --username AWS --password-stdin 894662486142.dkr.ecr.us-west-2.amazonaws.com
```

Позначення image тегом ECR та завантаження:

```bash
docker tag django-app:latest 894662486142.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest
docker push 894662486142.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest
```

Перевірка image в ECR:

```bash
aws ecr describe-images \
  --region us-west-2 \
  --repository-name lesson-7-ecr
```

### 6. Helm chart

Helm chart знаходиться в директорії:

```text
charts/django-app
```

Chart містить такі Kubernetes-ресурси:

- `Deployment` — запуск Django image з ECR;
- `Service` — доступ до застосунку через `LoadBalancer`;
- `ConfigMap` — передавання env-змінних у контейнер через `envFrom`;
- `HPA` — автоматичне масштабування pod-ів від 2 до 6 при CPU > 70%;
- `values.yaml` — конфігурація image, service, config та autoscaling.

Перевірка Helm chart:

```bash
helm lint charts/django-app
helm template django-app charts/django-app
```

Розгортання застосунку:

```bash
helm upgrade --install django-app charts/django-app
```

### 7. Перевірка Kubernetes-ресурсів

Перевірка pod-ів:

```bash
kubectl get pods
```

Перевірка Deployment:

```bash
kubectl get deployment
```

Перевірка Service:

```bash
kubectl get svc
```

Перевірка ConfigMap:

```bash
kubectl get configmap
```

Перевірка HPA:

```bash
kubectl get hpa
```

Очікуваний стан ресурсів:

- Django pod-и перебувають у статусі `Running`;
- Deployment має стан `READY 2/2`;
- Service має тип `LoadBalancer`;
- ConfigMap містить env-змінні застосунку;
- HPA має параметри `MINPODS 2`, `MAXPODS 6`, CPU target `70%`.

### 8. Зовнішня адреса застосунку

Зовнішня адреса формується Kubernetes Service типу `LoadBalancer`.

Команда для перегляду адреси:

```bash
kubectl get svc django-app
```

DNS-адреса AWS Load Balancer відображається в полі `EXTERNAL-IP`.

Приклад зовнішньої адреси:

```text
a99c3b7ac6d2a46779e7ee888a073f4c-990824588.us-west-2.elb.amazonaws.com
```

### 9. Контрольна перевірка

Для перевірки проєкту використовуються такі команди:

```bash
terraform fmt -recursive
terraform validate
helm lint charts/django-app
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get hpa
git status
```

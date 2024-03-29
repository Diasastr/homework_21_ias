# Terraform AWS Інфраструктура

Цей проект використовує Terraform для створення інфраструктури в AWS, яка включає VPC з публічними та приватними підмережами, NAT і Internet Gateways, два сервери (контролер Jenkins та сервер застосунків) та групи безпеки.

## Кроки для Розгортання

### Крок 1: Встановлення Terraform

Перед початком роботи встановила Terraform на комп'ютер  [офіційний сайт Terraform](https://www.terraform.io/downloads.html). Також треба встановити AWS CLI, додати IAM User для terraform з потрібними permissions (ec2fullaccess, vpsfullaccess, iamSShKeyTransfer etc). Потім використала команду aws configure з credentials для попередньо створеного юзера. Додатково створила пару приватного-публічного ключів для мого комп'ютера і вористала цей ключ для створення серверів в подальшому.

### Крок 2: Налаштування Провайдера AWS

Створила файл `provider.tf` у кореневій директорії проекту з наступним вмістом:

```hcl
provider "aws" {
  region = var.region
  shared_credentials_files = ["C:\\Users\\user\\.aws\\credentials"]
  profile                 = "default"
}

```
Додала також файл variables.tf з оголошенням змінних, які будуть використовуватися провайдером та іншими ресурсами.

Додайте також файл `variables.tf` з оголошенням змінних, які будуть використовуватися провайдером та іншими ресурсами.

### Крок 3: Створення Модуля Мережі

1.  Створення Директорії Модуля: У кореневій директорії проекту створила піддиректорію `modules/Networking`.
2.  Визначення Ресурсів Мережі: У директорії `modules/Networking` створила `main.tf`, де визначила VPC, підмережі, NAT Gateway, Internet Gateway та таблиці маршрутизації. Для простоти додала визначення інстансів туди ж.

### Крок 4: Розгортання Серверів

У модулі мережі (`modules/Networking/main.tf`) визначила два екземпляри EC2: один для Jenkins контролера та один для сервера застосунків. Налаштуйте групи безпеки з правилами для з'єднань між ними (дозвонила групі безпеки дженкінс контролера мати ssh доступ до app-server). Також для простоти додала secutiry rule для ssh через isntance-connect.

### Крок 5: Використання Модуля у Головній Конфігурації

У кореневій директорії проекту визначила модуль і змінні які він використовує в `production.tf`.

### Крок 6: Ініціалізація та Застосування Конфігурації

Виконада команди `terraform init`, `terraform validate`, `terraform plan` та `terraform apply` для ініціалізації, перевірки, планування та застосування вашої конфігурації Terraform.

Видалення Інфраструктури
------------------------

Для видалення всієї інфраструктури, створеної Terraform, виконайте команду:

```shell

`terraform destroy`
```


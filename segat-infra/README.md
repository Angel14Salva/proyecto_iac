# SEGAT — Infraestructura como Código

> Sistema de Gestión de Reportes Medio Ambientales para el Servicio de Gestión Ambiental de Trujillo

**Universidad Privada Antenor Orrego**
Facultad de Ingeniería — Ingeniería de Sistemas e Inteligencia Artificial
Curso: Infraestructura como Código (ISIA-107) — Semestre 2025-20
Docente: Leturia Rodriguez, Walter Ivan

---

## Integrantes

| Apellidos y Nombres |
|---|
| Reyes Figueroa, Brandon |
| Salvador Mauricio, Luis |
| Terrones Llamo, Jan |
| Vilca Jiménez, Juan Carlos |

---

## Descripción del proyecto

Trujillo enfrenta un problema de acumulación de residuos en puntos críticos de la ciudad. Este proyecto implementa la infraestructura en la nube para un sistema web que permite a los ciudadanos reportar incidencias ambientales, a los supervisores asignar tareas y a los trabajadores del SEGAT atender y confirmar cada reporte.

La infraestructura está diseñada para garantizar alta disponibilidad, escalabilidad automática y seguridad en capas, desplegada completamente en AWS mediante Infraestructura como Código con Terraform.

---

## Arquitectura

El sistema está organizado en 6 capas desplegadas dentro de una VPC Multi-AZ en la región us-east-1:
┌─────────────────────────────────────────────────────────┐
│                    CAPA DE PRESENTACIÓN                  │
│         Route 53 → AWS WAF → CloudFront → S3            │
├─────────────────────────────────────────────────────────┤
│              CAPA DE AUTENTICACIÓN Y ENTRADA             │
│              Amazon Cognito → API Gateway                │
├─────────────────────────────────────────────────────────┤
│                  CAPA DE CÓMPUTO (Multi-AZ)             │
│     ALB Interno → ECS Fargate Task A + Task B           │
│              Auto Scaling (2 a 6 tareas)                │
├─────────────────────────────────────────────────────────┤
│                    CAPA DE DATOS                         │
│   RDS Aurora PostgreSQL │ ElastiCache Redis │ DynamoDB  │
│              S3 Fotos de Reportes                        │
├─────────────────────────────────────────────────────────┤
│               CAPA DE MENSAJERÍA ASÍNCRONA              │
│     SQS Reportes + DLQ │ SQS Notificaciones + DLQ      │
│                  SNS Negocio + Alertas                   │
├─────────────────────────────────────────────────────────┤
│            CAPA DE OBSERVABILIDAD Y SEGURIDAD           │
│   CloudWatch │ Secrets Manager │ CloudTrail │ IAM       │
└─────────────────────────────────────────────────────────┘

---

## Estructura del repositorio
segat-infra/
├── main.tf           → Provider AWS y configuración base de Terraform
├── variables.tf      → Variables reutilizables con valores por defecto
├── vpc.tf            → VPC Multi-AZ, subredes, NAT Gateway, Security Groups
├── iam.tf            → Roles IAM con principio de mínimo privilegio
├── ecs.tf            → ECS Cluster, Fargate Tasks A y B, ALB, Auto Scaling
├── data.tf           → RDS Aurora, ElastiCache Redis, DynamoDB, S3, VPC Endpoints
├── messaging.tf      → SQS colas + Dead Letter Queues + SNS topics
├── observability.tf  → CloudWatch alarmas, Secrets Manager, CloudTrail
├── outputs.tf        → Valores exportados tras el despliegue
├── .gitignore        → Excluye .terraform/, tfstate y credenciales
└── README.md         → Este archivo

---

## Recursos desplegados

| Archivo | Capa | Servicios AWS | Recursos |
|---------|------|---------------|----------|
| vpc.tf | Red | VPC, Subredes, IGW, NAT GW, Security Groups | 16 |
| iam.tf | Seguridad | IAM Roles y Políticas | 6 |
| ecs.tf | Cómputo | ECR, ECS Cluster, Fargate, ALB, Auto Scaling | 10 |
| data.tf | Datos | Aurora PostgreSQL, Redis, DynamoDB x2, S3 x2, VPC Endpoints | 14 |
| messaging.tf | Mensajería | SQS x4, SNS x2, Suscripciones | 9 |
| observability.tf | Observabilidad | CloudWatch x2, Secrets Manager, CloudTrail, S3 | 7 |
| **Total** | | | **62 recursos** |

---

## Requisitos previos

- Terraform >= 1.5.0
- AWS CLI configurado con credenciales válidas
- Cuenta AWS activa con permisos suficientes

---

## Cómo usar este código

### 1. Clonar el repositorio
```bash
git clone https://github.com/Angel14Salva/proyecto_iac.git
cd proyecto_iac/segat-infra
```

### 2. Configurar credenciales AWS
```bash
aws configure
```

### 3. Inicializar Terraform
```bash
terraform init
```

### 4. Validar sintaxis
```bash
terraform validate
```

### 5. Ver plan de ejecución sin crear nada
```bash
terraform plan
```

### 6. Desplegar infraestructura
```bash
terraform apply
```

### 7. Eliminar infraestructura para evitar costos
```bash
terraform destroy
```

---

## Relación con los requerimientos no funcionales

| RNF | Descripción | Implementación |
|-----|-------------|----------------|
| RNF-04 | Continuidad ante fallos | Fargate Multi-AZ + Aurora Multi-AZ |
| RNF-06 | Registro en alta carga | SQS cola de reportes |
| RNF-07 | Acceso según rol | Cognito + IAM roles |
| RNF-09 | Cifrado en tránsito | Security Groups HTTPS |
| RNF-12 | Protección de datos | Subredes privadas + cifrado AES256 |
| RNF-13 | Backups automáticos | backup_retention_period = 30 días |
| RNF-15 | Ningún reporte se pierde | SQS + Dead Letter Queue |
| RNF-19 | Escalabilidad automática | Auto Scaling 2 a 6 tareas |
| RNF-20 | Tiempos de respuesta | ElastiCache Redis |
| RNF-21 | Rendimiento en campañas | Auto Scaling por CPU al 70% |

---

## Módulos del monolito

Cada Fargate Task ejecuta el monolito con los siguientes módulos:

- Mod. Autenticación — gestión de sesiones y tokens
- Mod. Reportes — registro y seguimiento de incidencias
- Mod. Tareas — asignación de trabajadores a reportes
- Mod. Geolocalización GPS — coordenadas en tiempo real via DynamoDB
- Mod. Notificaciones — alertas a ciudadanos y trabajadores via WhatsApp
- Mod. Subida de Archivos — fotografías de evidencia almacenadas en S3

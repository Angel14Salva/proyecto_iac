# =============================================================================
# variables.tf — Variables globales del proyecto SEGAT
# =============================================================================

variable "aws_region" {
  description = "Region AWS donde se desplegara toda la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo en todos los recursos"
  type        = string
  default     = "segat"
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC principal Multi-AZ"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_private_a_cidr" {
  description = "CIDR Subred Privada A — Fargate Task A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_private_b_cidr" {
  description = "CIDR Subred Privada B — Fargate Task B"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_private_c_cidr" {
  description = "CIDR Subred Privada C — RDS Aurora y ElastiCache"
  type        = string
  default     = "10.0.3.0/24"
}

variable "subnet_private_c2_cidr" {
  description = "CIDR Subred Privada C2 — replica RDS Multi-AZ segunda AZ"
  type        = string
  default     = "10.0.4.0/24"
}

variable "subnet_public_cidr" {
  description = "CIDR subred publica A — ALB y NAT Gateway"
  type        = string
  default     = "10.0.10.0/24"
}

variable "subnet_public_b_cidr" {
  description = "CIDR subred publica B — ALB requiere 2 AZs"
  type        = string
  default     = "10.0.11.0/24"
}

variable "ecs_task_cpu" {
  description = "CPU asignada a cada Fargate Task (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "ecs_task_memory" {
  description = "Memoria asignada a cada Fargate Task en MB"
  type        = number
  default     = 1024
}

variable "ecs_desired_count" {
  description = "Numero deseado de tareas Fargate corriendo"
  type        = number
  default     = 2
}

variable "ecs_min_count" {
  description = "Numero minimo de tareas para Auto Scaling"
  type        = number
  default     = 2
}

variable "ecs_max_count" {
  description = "Numero maximo de tareas para Auto Scaling"
  type        = number
  default     = 6
}

variable "db_name" {
  description = "Nombre de la base de datos principal"
  type        = string
  default     = "segat_db"
}

variable "db_username" {
  description = "Usuario administrador de RDS Aurora"
  type        = string
  default     = "segat_admin"
  sensitive   = true
}

variable "db_password" {
  description = "Contrasena de RDS Aurora"
  type        = string
  default     = "ChangeMe_Pr0duction!"
  sensitive   = true
}

variable "sqs_visibility_timeout" {
  description = "Segundos que un mensaje es invisible despues de ser leido"
  type        = number
  default     = 30
}

variable "sqs_message_retention" {
  description = "Segundos que SQS retiene un mensaje (4 dias)"
  type        = number
  default     = 345600
}

variable "sqs_dlq_max_receive" {
  description = "Intentos antes de mover mensaje a Dead Letter Queue"
  type        = number
  default     = 3
}

variable "alert_email" {
  description = "Correo del equipo tecnico para alertas de CloudWatch"
  type        = string
  default     = "equipo-tecnico@segat.gob.pe"
}

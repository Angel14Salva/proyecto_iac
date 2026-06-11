# =============================================================================
# data.tf — FASE 4: Capa de datos
# RDS Aurora PostgreSQL + ElastiCache Redis + DynamoDB + S3
# =============================================================================

resource "aws_db_subnet_group" "rds" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = [aws_subnet.private_c.id, aws_subnet.private_c2.id]
  tags       = { Name = "${var.project_name}-rds-subnet-group" }
}

resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier      = "${var.project_name}-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  backup_retention_period = 30
  preferred_backup_window = "03:00-04:00"
  deletion_protection     = false
  storage_encrypted       = true
  skip_final_snapshot     = true
  tags = { Name = "${var.project_name}-aurora-cluster" }
}

resource "aws_rds_cluster_instance" "primary" {
  identifier           = "${var.project_name}-aurora-primary"
  cluster_identifier   = aws_rds_cluster.aurora_postgresql.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.aurora_postgresql.engine
  engine_version       = aws_rds_cluster.aurora_postgresql.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds.name
  tags = { Name = "${var.project_name}-aurora-primary", Role = "Primary" }
}

resource "aws_rds_cluster_instance" "replica" {
  identifier           = "${var.project_name}-aurora-replica"
  cluster_identifier   = aws_rds_cluster.aurora_postgresql.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.aurora_postgresql.engine
  engine_version       = aws_rds_cluster.aurora_postgresql.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds.name
  tags = { Name = "${var.project_name}-aurora-replica", Role = "Replica" }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = [aws_subnet.private_c.id, aws_subnet.private_c2.id]
  tags       = { Name = "${var.project_name}-redis-subnet-group" }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
  tags = { Name = "${var.project_name}-redis-cache" }
}

resource "aws_dynamodb_table" "gps_locations" {
  name         = "${var.project_name}-gps-locations"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "reporte_id"
  range_key    = "timestamp"

  attribute {
    name = "reporte_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = true
  }

  tags = { Name = "${var.project_name}-dynamodb-gps" }
}

resource "aws_dynamodb_table" "notifications" {
  name         = "${var.project_name}-notifications"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "notification_id"
  range_key    = "user_id"

  attribute {
    name = "notification_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = { Name = "${var.project_name}-dynamodb-notifications" }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  tags = { Name = "${var.project_name}-vpc-endpoint-s3" }
}

resource "aws_s3_bucket" "reportes" {
  bucket = "${var.project_name}-reportes-fotos-${var.environment}"
  tags   = { Name = "${var.project_name}-s3-reportes" }
}

resource "aws_s3_bucket_public_access_block" "reportes" {
  bucket                  = aws_s3_bucket.reportes.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reportes" {
  bucket = aws_s3_bucket.reportes.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
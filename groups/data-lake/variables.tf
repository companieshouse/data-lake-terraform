variable "region" {}

variable "database_password" {
  type        = string
  description = "The Redshift database password"
}

variable "database_username" {
  type        = string
  description = "The Redshift database username"
}

variable "mongo_export_db_url" {
  type        = string
  description = "The MongoDB URL for the export Lambda"
}

variable "mongo_export_s3_path" {
  type        = string
  default     = "DMS-Output/lambda"
  description = "The S3 bucket prefix for the export Lambda; will be prefixed with the bucket name automatically"
}

# Environment outputs
output "environment_id" {
  description = "The ID of the created Confluent environment"
  value       = confluent_environment.dev.id
}

output "environment_name" {
  description = "The name of the created Confluent environment"
  value       = confluent_environment.dev.display_name
}

output "environment_resource_name" {
  description = "The resource name of the created Confluent environment"
  value       = confluent_environment.dev.resource_name
}

# Kafka Cluster outputs
output "kafka_cluster_id" {
  description = "The ID of the created Kafka cluster"
  value       = confluent_kafka_cluster.basic.id
}

output "kafka_cluster_name" {
  description = "The name of the created Kafka cluster"
  value       = confluent_kafka_cluster.basic.display_name
}

output "kafka_cluster_bootstrap_endpoint" {
  description = "The bootstrap endpoint of the Kafka cluster"
  value       = confluent_kafka_cluster.basic.bootstrap_endpoint
}

output "kafka_cluster_rest_endpoint" {
  description = "The REST endpoint of the Kafka cluster"
  value       = confluent_kafka_cluster.basic.rest_endpoint
}

output "kafka_cluster_rbac_crn" {
  description = "The RBAC CRN of the Kafka cluster"
  value       = confluent_kafka_cluster.basic.rbac_crn
}

output "kafka_cluster_api_version" {
  description = "The API version of the Kafka cluster"
  value       = confluent_kafka_cluster.basic.api_version
}

output "kafka_cluster_kind" {
  description = "The kind of the Kafka cluster resource"
  value       = confluent_kafka_cluster.basic.kind
}

# Kafka Topic outputs
output "kafka_topic_name" {
  description = "The name of the created Kafka topic"
  value       = confluent_kafka_topic.stock_ticks.topic_name
}

output "kafka_topic_id" {
  description = "The ID of the created Kafka topic"
  value       = confluent_kafka_topic.stock_ticks.id
}

output "kafka_topic_partitions_count" {
  description = "The number of partitions of the Kafka topic"
  value       = confluent_kafka_topic.stock_ticks.partitions_count
}

# Service Account outputs
output "service_account_id" {
  description = "The ID of the created service account"
  value       = confluent_service_account.app-ksql.id
}

output "service_account_name" {
  description = "The name of the created service account"
  value       = confluent_service_account.app-ksql.display_name
}

output "service_account_api_version" {
  description = "The API version of the service account"
  value       = confluent_service_account.app-ksql.api_version
}

output "service_account_kind" {
  description = "The kind of the service account resource"
  value       = confluent_service_account.app-ksql.kind
}

# Role Binding outputs
output "role_binding_id" {
  description = "The ID of the created role binding"
  value       = confluent_role_binding.app-ksql-kafka-cluster-admin.id
}

# API Key outputs
output "api_key_id" {
  description = "The ID of the created Kafka API key"
  value       = confluent_api_key.app-ksql-kafka-api-key.id
}

output "api_key_secret" {
  description = "The secret of the created Kafka API key"
  value       = confluent_api_key.app-ksql-kafka-api-key.secret
  sensitive   = true
}

output "api_key_display_name" {
  description = "The display name of the created Kafka API key"
  value       = confluent_api_key.app-ksql-kafka-api-key.display_name
}

# ksqlDB Cluster outputs
output "ksql_cluster_id" {
  description = "The ID of the created ksqlDB cluster"
  value       = confluent_ksql_cluster.main.id
}

output "ksql_cluster_name" {
  description = "The name of the created ksqlDB cluster"
  value       = confluent_ksql_cluster.main.display_name
}

output "ksql_cluster_api_endpoint" {
  description = "The API endpoint of the ksqlDB cluster"
  value       = confluent_ksql_cluster.main.rest_endpoint
}

output "ksql_cluster_resource_name" {
  description = "The resource name of the ksqlDB cluster"
  value       = confluent_ksql_cluster.main.resource_name
}

output "ksql_cluster_api_version" {
  description = "The API version of the ksqlDB cluster"
  value       = confluent_ksql_cluster.main.api_version
}

output "ksql_cluster_kind" {
  description = "The kind of the ksqlDB cluster resource"
  value       = confluent_ksql_cluster.main.kind
}

# Connection details for applications
output "kafka_bootstrap_servers" {
  description = "The bootstrap servers configuration parameter for Kafka clients"
  value       = confluent_kafka_cluster.basic.bootstrap_endpoint
}

output "kafka_client_credentials" {
  description = "The credentials to use with Kafka clients"
  value = {
    api_key    = confluent_api_key.app-ksql-kafka-api-key.id
    api_secret = confluent_api_key.app-ksql-kafka-api-key.secret
  }
  sensitive = true
}

output "ksql_api_endpoint" {
  description = "The endpoint URL for connecting to ksqlDB"
  value       = confluent_ksql_cluster.main.rest_endpoint
}

# Full resource summaries (useful for debugging or advanced use cases)
output "kafka_cluster_summary" {
  description = "Summary of the Kafka cluster configuration"
  value = {
    id             = confluent_kafka_cluster.basic.id
    name           = confluent_kafka_cluster.basic.display_name
    availability   = confluent_kafka_cluster.basic.availability
    cloud          = confluent_kafka_cluster.basic.cloud
    region         = confluent_kafka_cluster.basic.region
    bootstrap      = confluent_kafka_cluster.basic.bootstrap_endpoint
    rest_endpoint  = confluent_kafka_cluster.basic.rest_endpoint
    environment_id = confluent_environment.dev.id
  }
}

output "ksqldb_cluster_summary" {
  description = "Summary of the ksqlDB cluster configuration"
  value = {
    id             = confluent_ksql_cluster.main.id
    name           = confluent_ksql_cluster.main.display_name
    csu            = confluent_ksql_cluster.main.csu
    endpoint       = confluent_ksql_cluster.main.rest_endpoint
    kafka_id       = confluent_kafka_cluster.basic.id
    environment_id = confluent_environment.dev.id
  }
}

# Output specifically named "resource-ids" for terraform output resource-ids command
output "resource-ids" {
  description = "Consolidated map of all resource IDs for easy extraction"
  value = {
    environment_id        = confluent_environment.dev.id
    kafka_cluster_id      = confluent_kafka_cluster.basic.id
    kafka_topic_id        = confluent_kafka_topic.stock_ticks.id
    service_account_id    = confluent_service_account.app-ksql.id
    role_binding_id       = confluent_role_binding.app-ksql-kafka-cluster-admin.id
    api_key_id            = confluent_api_key.app-ksql-kafka-api-key.id
    api_key_secret        = confluent_api_key.app-ksql-kafka-api-key.secret
    ksql_cluster_id       = confluent_ksql_cluster.main.id
  }
  sensitive = true  # Marking as sensitive because it contains the API key secret
}
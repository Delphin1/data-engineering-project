terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.24.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# Create environment
resource "confluent_environment" "dev" {
  display_name = "Development"
}

# Create Kafka Cluster - this will use trial credits
resource "confluent_kafka_cluster" "basic" {
  display_name = "inventory_cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"

  # Basic tier uses trial credits
  basic {}

  environment {
    id = confluent_environment.dev.id
  }
}

resource "confluent_kafka_topic" "stock_ticks" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name    = "stock_ticks"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key    = confluent_api_key.app-ksql-kafka-api-key.id
    secret = confluent_api_key.app-ksql-kafka-api-key.secret
  }
}

# Create service account for ksqlDB
resource "confluent_service_account" "app-ksql" {
  display_name = "app-ksql"
  description  = "Service account for ksqlDB"
}

# Create role binding for the service account
resource "confluent_role_binding" "app-ksql-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-ksql.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
}

# Create API key for the service account
resource "confluent_api_key" "app-ksql-kafka-api-key" {
  display_name = "app-ksql-kafka-api-key"
  description  = "Kafka API Key owned by 'app-ksql' service account"
  owner {
    id          = confluent_service_account.app-ksql.id
    api_version = confluent_service_account.app-ksql.api_version
    kind        = confluent_service_account.app-ksql.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind
    environment {
      id = confluent_environment.dev.id
    }
  }

  depends_on = [
    confluent_role_binding.app-ksql-kafka-cluster-admin
  ]
}

# Create ksqlDB cluster
resource "confluent_ksql_cluster" "main" {
  display_name = "ksql_cluster"
  csu          = 1  # Trial accounts can use 1 CSU

  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  credential_identity {
    id = confluent_service_account.app-ksql.id
  }

  environment {
    id = confluent_environment.dev.id
  }

  depends_on = [
    confluent_role_binding.app-ksql-kafka-cluster-admin,
    confluent_api_key.app-ksql-kafka-api-key
  ]
}

# resource "confluent_api_key" "app-ksqldb-api-key" {
#   display_name = "app-ksqldb-api-key"
#   description  = "KsqlDB API Key that is owned by 'app-ksql' service account"
#   owner {
#     id          = confluent_service_account.app-ksql.id
#     api_version = confluent_service_account.app-ksql.api_version
#     kind        = confluent_service_account.app-ksql.kind
#   }
#
#   managed_resource {
#     id          = confluent_ksql_cluster.main.id
#     api_version = confluent_ksql_cluster.main.api_version
#     kind        = confluent_ksql_cluster.main.kind
#
#     environment {
#       id = confluent_environment.dev.id
#     }
#   }
# }
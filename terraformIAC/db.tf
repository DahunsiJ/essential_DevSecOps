

# Random Integer
# resource "random_integer" "DevSecOps_ri" {
#   min = 1
#   max = 10000
# }

# CosmosDB Account
resource "azurerm_cosmosdb_account" "DevSecOps-db-ac" {
  name = "devsecopscosmosdb"
  #   name                = "devsecopscosmosdb${random_integer.DevSecOps_ri.result}"
  location            = azurerm_resource_group.DevSecOps_rg.location
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.DevSecOps_rg.location
    failover_priority = 0
  }
}

# CosmosDB Database
resource "azurerm_cosmosdb_mongo_database" "DevSecOps-db" {
  name                = "DevSecops-cosmos-mongo-database"
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  account_name        = azurerm_cosmosdb_account.DevSecOps-db-ac.name
  throughput          = 400
}

# CosmosDB Collection
resource "azurerm_cosmosdb_mongo_collection" "DevSecOps-db-Collection" {
  name                = "DevSecOps-cosmos-mongo-db-collection"
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  account_name        = azurerm_cosmosdb_account.DevSecOps-db-ac.name
  database_name       = azurerm_cosmosdb_mongo_database.DevSecOps-db.name

  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400

  index {
    keys   = ["_id"]
    unique = true
  }
}

# CosmosDB Collection
resource "azurerm_cosmosdb_mongo_collection" "backup-DevSecOps-db-Collection" {
  name                = "backup-DevSecOps-cosmos-mongo-db-collection"
  resource_group_name = azurerm_resource_group.DevSecOps_rg.name
  account_name        = azurerm_cosmosdb_account.DevSecOps-db-ac.name
  database_name       = azurerm_cosmosdb_mongo_database.DevSecOps-db.name

  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400

  index {
    keys   = ["_id"]
    unique = true
  }
}
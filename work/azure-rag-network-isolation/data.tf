#
## Cognitive Account
#
resource "azurerm_cognitive_account" "main" {
  for_each              = var.cognitive_accounts
  custom_subdomain_name = local.cognitive_account_cdn[each.key]
  kind                  = each.value.kind
  name                  = local.cognitive_account_name[each.key]
  sku_name              = each.value.sku_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  tags                  = var.tags

  network_acls {
    default_action = each.value.acl_action
    ip_rules       = each.value.ip_rules
  }
}

#
## Cosmosdb
#

resource "azurerm_cosmosdb_account" "main" {
  name                              = local.resource_names.cosmosdb_account
  location                          = var.location
  resource_group_name               = azurerm_resource_group.main.name
  offer_type                        = var.cosmosdb_offer_type
  kind                              = var.cosmosdb_kind
  ip_range_filter                   = var.ip_range_filter-cosmosdb
  is_virtual_network_filter_enabled = true

  virtual_network_rule {
    id                                   = module.network.appservice_subnet_id
    ignore_missing_vnet_service_endpoint = false
  }

  dynamic "capabilities" {
    for_each = var.cosmosdb_capabilities
    content {
      name = capabilities.value
    }
  }
  geo_location {
    location          = var.location
    failover_priority = var.failover_priority

  }
  consistency_policy {
    consistency_level = var.consistency_level

  }
  backup {
    type = var.cosmosdb_backup_type
  }
  tags = merge(var.tags, var.cosmosdb_tags)
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = local.resource_names.cosmosdb_sql_database
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_sql_container" "main" {
  for_each              = var.cosmosdb_sql_containers
  name                  = each.value.name
  resource_group_name   = azurerm_cosmosdb_account.main.resource_group_name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths   = ["${each.value.partition_key_path}"]
  partition_key_version = 2
}

#
## Search Service
#
resource "azurerm_search_service" "main" {
  name                = local.resource_names.search
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.search_sku
  semantic_search_sku = var.semantic_search_sku
  tags                = var.tags
  partition_count = var.partition_count
}

#
## Storage
#
resource "azurerm_storage_account" "main" {
  name                             = local.resource_names.storage
  location                         = var.location
  resource_group_name              = azurerm_resource_group.main.name
  access_tier                      = var.storage_access_tier
  account_kind                     = var.storage_account_kind
  account_replication_type         = var.storage_replication_type
  account_tier                     = var.storage_account_tier
  allow_nested_items_to_be_public  = var.allow_nested_items_to_be_public
  cross_tenant_replication_enabled = var.cross_tenant_replication_enabled
  is_hns_enabled                   = var.hns_enabled
  large_file_share_enabled         = var.large_file_share_enabled
  min_tls_version                  = var.min_tls_version
  tags                             = var.tags
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  network_rules {
    default_action = "deny" # put allow for first deploy and then switch to deny
    bypass         = ["AzureServices", "Metrics", "Logging"]
    # deny all by default, allow the correct subnet
    virtual_network_subnet_ids = [
      module.network.private_subnet_id,
      module.network.function_subnet_id,
      module.network.appservice_subnet_id
    ]

    ip_rules = var.ip_range_filter_blob
  }
}

resource "azurerm_storage_container" "main" {
  name = local.resource_names.container
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}
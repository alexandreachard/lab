
variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists."
}
variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

variable "cosmosdb_offer_type" {
  type = string
  default = "Standard"
}

variable "cosmosdb_kind" {
  type = string
  default = "GlobalDocumentDB"
}

variable "cosmosdb_capabilities" {
  type        = map(string)
  description = "A mapping of capabilities to assign to the cosmosDB resource."
  default = {
    "name" = "EnableServerless"
  }
}

variable "cosmosdb_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the cosmosDB resource."
}

variable "consistency_level" {
  type        = string
  description = "The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix."
  default = "Session"

}

variable "failover_priority" {
  type        = number
  description = "The failover priority of the region. A failover priority of 0 indicates a write region. The maximum value for a failover priority = (total number of regions - 1). "
  default     = 0
}

variable "cosmosdb_sql_containers" {
  type = map(object({
    name               = string
    partition_key_path = string
  }))
}

variable "partition_count" {
  type = number
  description = "Number of partition"
  default = 1
}
variable "search_sku" {
  type        = string
  description = "SKU of the search service"
  default = "basic"
}

variable "semantic_search_sku" {
  type        = string
  description = "Specifies the Semantic Search SKU which should be used for this Search Service. Possible values include free and standard."
  default = "standard"
}

variable "asp_os_type" {
  type        = string
  description = " The O/S type for the App Services to be hosted in this plan. Possible values include Windows, Linux, and WindowsContainer"
  default = "Linux"
}

variable "maximum_elastic_worker_count" {
  type        = number
  description = "The maximum number of workers to use in an Elastic SKU Plan. Cannot be set unless using an Elastic SKU."
  default     = 30

}

variable "asp_sku_name" {
  type        = string
  description = "The SKU for the plan."
  default = "P2v2"
}

variable "asp_worker_count" {
  type        = number
  description = "The number of Workers (instances) to be allocated."
  default     = 1
}

variable "asp_zone_balancing" {
  type        = bool
  description = "Should the Service Plan balance across Availability Zones in the region."
  default = true
}

#App Service 
variable "https_only" {
  type        = bool
  description = "Should the Windows Web App require HTTPS connections"
  default     = true
}

variable "always_on" {
  type        = bool
  default     = false
  description = "If this Windows Web App is Always On enabled."
}

variable "ftps_state" {
  type        = string
  description = "The State of FTP / FTPS service. Possible values include: AllAllowed, FtpsOnly, Disabled."
  default     = "Disabled"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Should public network access be enabled for the Web App."
  default     = true
}

variable "apps" {
  type = map(object({
    suffix            = string
    app_settings      = map(string)
    docker_image_name = string
  }))
}

variable "storage_account_tier" {
  type        = string
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. "
  default     = "Standard"
}

variable "storage_access_tier" {
  type        = string
  default     = "Hot"
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool"
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = false
  description = "Allow or disallow nested items within this Account to opt into being public."

}

variable "cross_tenant_replication_enabled" {
  type        = bool
  default     = false
  description = "Should cross Tenant replication be enabled?"
}

variable "large_file_share_enabled" {
  type        = bool
  default     = true
  description = "Are Large File Shares Enabled? "
}

variable "hns_enabled" {
  type        = bool
  description = "Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2"
  default     = true
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "storage_replication_type" {
  type        = string
  default     = "LRS"
  description = " Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. "
}

variable "storage_account_kind" {
  type        = string
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  default     = "StorageV2"
}

variable "visual_system_prompt" {
  description = "Prompt used for visual system"
  type        = string
}

variable "max_visual_tokens" {
  description = "Maximum number of tokens for visual system"
  type        = number
  default     = 1024
}

variable "visual_temperature" {
  description = "Temperature setting for visual system"
  type        = number
  default     = 0.7
}
variable "azure_openai_api_version" {
  description = "The API version for Azure OpenAI"
  type        = string
  default     = "2024-12-01-preview"
}

variable "azure_openai_embedding_deployment_name" {
  description = "The name of the OpenAI embedding deployment"
  type        = string
  default     = "text-embedding-3-large"
}

variable "azure_openai_embedding_dimensions" {
  description = "The number of dimensions for the OpenAI embedding"
  type        = number
  default     = 3072
}

variable "azure_openai_model_deployment_name" {
  description = "The name of the OpenAI model deployment"
  type        = string
  default     = "gpt-5.1"
}

variable "azure_queue_name" {
  description = "The name of the Azure Queue"
  type        = string
  default     = "queue-indexation"
}

variable "azure_table_name" {
  description = "The name of the Azure Table"
  type        = string
  default     = "IndexingLogs"
}

variable "azure_search_index" {
  description = "The name of the Azure Search Index"
  type        = string
  default     = "idx-proc-dev-01"
}

# variables nécessaires pour communication entre tfstate/core/bot
variable "tfstate_resource_group_name" {
  description = "Nom du Resource Group où est stocké le tfstate"
  type        = string
}

variable "tfstate_storage_account_name" {
  description = "Nom du Storage Account où est stocké le tfstate"
  type        = string
}

variable "tfstate_container_name" {
  description = "Nom du container où est stocké le tfstate"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "client_id" {
  description = "Azure AD client ID"
  type        = string
}
variable "build_flag" {
  description = "BUILD_FLAGS"
  type        = string
}
variable "enable_oryx_build" {
  type        = bool
  description = "ENABLE_ORYX_BUILD"
  default     = true
}
variable "FUNCTIONS_WORKER_RUNTIME" {
  description = "FUNCTIONS_WORKER_RUNTIME"
  type        = string
}
variable "SCM_DO_BUILD_DURING_DEPLOYMENT" {
  description = "SCM_DO_BUILD_DURING_DEPLOYMENT"
  type        = string
}
variable "MAX_OUTPUT_SIZE" {
  description = "MAX_OUTPUT_SIZE"
  type        = string
}
variable "MAX_INPUT_SIZE" {
  description = "MAX_INPUT_SIZE"
  type        = string
}
variable "AZURE_OPENAI_TEMPERATURE" {
  description = "AZURE_OPENAI_TEMPERATURE"
  type        = string
}
variable "XDG_CACHE_HOME" {
  description = "XDG_CACHE_HOME"
  type        = string
}
variable "WEBSITES_ENABLE_APP_SERVICE_STORAGE" {
  description = "WEBSITES_ENABLE_APP_SERVICE_STORAGE"
  type        = bool
}

#cognitive Account
variable "cognitive_accounts" {
  type = map(object({
    # name       = string
    kind       = string
    sku_name   = string
    ip_rules   = list(string)
    acl_action = string
    cdn_suffix = string

  }))
}

variable "acr_sku" {
  type = string
  default = "Premium"
}

variable "acr_admin_enabled" {
  type        = bool
  description = "Specifies whether the admin user is enabled."
  default = false
}

variable "data_endpoint_enabled" {
  type        = bool
  description = "Whether to enable dedicated data endpoints for this Container Registry? This is only supported on resources with the Premium SKU."
  default     = false
}

variable "anonymous_pull_enabled" {
  type        = bool
  description = " Whether allows anonymous (unauthenticated) pull access to this Container Registry? This is only supported on resources with the Standard or Premium SKU."
  default     = false
}

variable "cosmosdb_backup_type" {
  type        = string
  description = "backup type for cosmosDB"
  default     = "Continuous"
}

variable "ip_range_filter-cosmosdb" {
  description = "Liste des IPs autorisées à accéder aux ressources"
  type        = list(string)
  default     = []
}
variable "ip_range_filter_blob" {
  description = "Liste des IPs autorisées à accéder aux blob"
  type        = list(string)
  default     = []
}

variable "address_space" {
  description = "scope ip global du vnet"
  type        = list(string)
  default     = ["10.231.0.0/16"]
}
variable "appservice_subnet_prefixes" {
  description = "appservice_subnet_prefixes"
  type        = list(string)
  default     = []
}
variable "function_subnet_prefixes" {
  description = "function_subnet_prefixes"
  type        = list(string)
  default     = []
}
variable "private_subnet_prefixes" {
  description = "private_subnet_prefixes"
  type        = list(string)
  default     = []
}
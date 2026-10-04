variable "prefix" {
  description = "Naming prefix applied to all resources in this landing zone."
  type        = string
  default     = "lz"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment tag/suffix (e.g. dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "hub_address_space" {
  description = "Address space for the hub VNet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_subnet_prefix" {
  description = "Subnet prefix inside the hub VNet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "spoke_address_space" {
  description = "Address space for the spoke VNet."
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke_subnet_prefix" {
  description = "Subnet prefix inside the spoke VNet."
  type        = string
  default     = "10.1.1.0/24"
}

variable "allowed_locations" {
  description = "Locations allowed by the 'allowed locations' policy assignment."
  type        = list(string)
  default     = ["westeurope", "northeurope"]
}

variable "mandatory_tag_name" {
  description = "Tag name enforced by the 'require tag' policy assignment."
  type        = string
  default     = "CostCenter"
}

variable "rbac_assignments" {
  description = "Map of RBAC role assignments to create at the landing zone subscription scope. Key is an arbitrary name, value has principal_id and role_definition_name."
  type = map(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = {}
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    managedBy = "terraform"
  }
}

# terraform.rego
package terraform.analysis

# Import necessary libraries
import rego.v1
import input as tfplan

# Define protected tags
protected_tags := {"environment": "production", "critical": "true"}

# Define critical resource types
critical_resource_types := {
    "azurerm_resource_group",
    "azurerm_virtual_network",
    "azurerm_subnet"
}

# Check if resource has protected tags
default has_protected_tags(resource) := false
has_protected_tags(resource) := true if {
    tags := resource.change.before.tags
    some k, v in protected_tags
    tags[k] == v
}

# Check if resource is a critical type
default is_critical_type(resource) := false
is_critical_type(resource) := true if {
    critical_resource_types[resource.type]
}

# Require approval if protected resources are being destroyed or recreated
requires_approval contains resource if {
    resource := tfplan.resource_changes[_]
    has_protected_tags(resource)
    resource.change.actions[_] == "delete"
}

requires_approval contains resource if {
    resource := tfplan.resource_changes[_]
    has_protected_tags(resource)
    array.slice(resource.change.actions, 0, 2) == ["delete", "create"]
}

# Get details for Slack notification
destroy_details contains detail if {
    resource := requires_approval[_]
    detail := {
        "resource_type": resource.type,
        "resource_name": resource.name,
        "tags": resource.change.before.tags,
        "is_critical_type": is_critical_type(resource),
        "has_protected_tags": has_protected_tags(resource),
        "action": resource.change.actions
    }
}

# Deny rule (but allow with approval)
deny contains msg if {
    resource := requires_approval[_]
    msg := concat(" ", [
        "🚨 Protected resource",
        sprintf("'%v'", [resource.address]),
        sprintf("requires approval for %v.", [resource.change.actions]),
        "Please review and approve."
    ])
}
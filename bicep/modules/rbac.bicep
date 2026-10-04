targetScope = 'subscription'

@description('Map of RBAC role assignments to create at subscription scope. Key is an arbitrary name, value has principalId and roleDefinitionId (GUID only, no full resource ID).')
param rbacAssignments object

resource assignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for key in items(rbacAssignments): {
  name: guid(subscription().id, key.key, key.value.principalId, key.value.roleDefinitionId)
  properties: {
    principalId: key.value.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', key.value.roleDefinitionId)
  }
}]

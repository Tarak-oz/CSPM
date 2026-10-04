targetScope = 'subscription'

@description('Environment tag/suffix, used to make assignment names unique.')
param environment string

@description('Locations allowed by the allowed-locations policy assignment.')
param allowedLocations array

@description('Tag name enforced by the require-tag policy assignment.')
param mandatoryTagName string

var allowedLocationsPolicyId = '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
var requireTagPolicyId = '/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99'

resource allowedLocationsAssignment 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'allowed-locations-${environment}'
  properties: {
    displayName: 'Allowed locations'
    policyDefinitionId: allowedLocationsPolicyId
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
  }
}

resource requireTagAssignment 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'require-tag-${environment}'
  properties: {
    displayName: 'Require a tag on resource groups'
    policyDefinitionId: requireTagPolicyId
    parameters: {
      tagName: {
        value: mandatoryTagName
      }
    }
  }
}

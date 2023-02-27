# Notes on Managed Identity

1. Set your default region and resource group

    ```bash
    az config set defaults.location=uksouth defaults.group=jenkins
    ```

1. Find the objectId for the managed identity

    ```bash
    managed_identity=$(az vm show --resource-group jenkins --name jenkins --query identity.principalId --output tsv)
    ```

1. Find the resource ID for the storage account

    ```bash
    rgId=$(az group show --name $(az config get defaults.group --query value -otsv) --query id -otsv)
    sa=terraform$(md5sum <<< $rgId | cut -c1-12)
    saId=$(az storage account show --name $sa --resource-group jenkins --query id --output tsv)
    ```

1. Assign RBAC roles for the managed identity

    ```bash
    subscriptionId=/subscriptions/$(az account show --query id --output tsv)
    az role assignment create --assignee $managed_identity --role "Contributor" --scope $subscriptionId
    az role assignment create --assignee $managed_identity --role "Storage Blob Data Contributor" --scope $saId
    ```

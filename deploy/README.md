# Deploy Notes App on Azure

This directory contains a set of Terraform configuration files to deploy Notes App to Azure App Service.

You can learn more about the resources used by referencing the following example scenario from Azure's documentation: https://learn.microsoft.com/en-us/azure/architecture/example-scenario/private-web-app/private-web-app

These Terraform configurations go a step further from that initial example. The password used for authenticating against the Notes App SQL database is stored in Azure Key Vault. The App Service accesses Key Vault using a Managed Identity and populates database credentials in the container's environment using a Key Vault Reference. Like the database, communication between the App Service and Key Vault occurs via a Private Endpoint.

In order to run this example, you need to have the following prerequisites:
 - An Azure subscription
 - Terraform installed
 - The Azure CLI installed & logged in
 - Terraform Azure Provider installed
 - Terraform Azure CAF Provider installed


# Kognitiv Terraform modules

This is the centralized repository for TF modules code on Kognitiv, and it's intended to be used as the source of truth for creating resources in Azure in a standardized way.

This module should cover all the resource types you'll need to use to deploy your app in the Azure Cloud, with the proper naming/tagging/etc. conventions pre-defined and enforced.

The modules available for you to use are:
- [aks](./terraform/modules/azure/aks/README.md)
- [bastion-host](./terraform/modules/azure/bastion-host/README.md)
- [cdn](./terraform/modules/azure/cdn/README.md)
- [db-postgresql](./terraform/modules/azure/db-postgresql/README.md)
- [redis](./terraform/modules/azure/redis/README.md)
- [resource-group](./terraform/modules/azure/resource-group/README.md)
- [storage-account](./terraform/modules/azure/storage-account/README.md)
- [subnet](./terraform/modules/azure/subnet/README.md)
- [virtual-network](./terraform/modules/azure/virtual-network/README.md)


## Object Storage (Images Bucket)

| **Property**       | **Value**                                                     |
| ------------------ | ------------------------------------------------------------- |
| Terraform Resource | `oci_objectstorage_bucket.media_bucket`                       |
| Bucket Name        | `alephium-media`                                              |
| Namespace          | (verify with `data.oci_objectstorage_namespace.ns.namespace`) |
| Access Type        | `Private`                                                     |
| Purpose            | Store book covers and author photos                           |

## Dynamic Group

| **Property**       | **Value**                                                                         |
| ------------------ | --------------------------------------------------------------------------------- |
| Terraform Resource | `oci_identity_dynamic_group.library_instances`                                    |
| Name               | `library-instances-dg`                                                            |
| Rule               | `instance.compartment.id = '<compartment_id>'`                                    |
| Purpose            | Group all instances within the compartment to assign permissions without API keys |

## IAM Policy

| **Property**       | **Value**                                           |
| ------------------ | --------------------------------------------------- |
| Terraform Resource | `oci_identity_policy.library_object_storage_policy` |
| Name               | `library-media-policy`                              |
| Statements         | See below                                           |
# How This Authentication Works

1. Instances authenticate with OCI using **Instance Principals** (their own identity, no passwords required).
2. The **Dynamic Group** aggregates these instances based on a rule (all instances within the compartment).
3. The **IAM Policy** grants permissions to that group to perform operations on the bucket.
4. Django (running on the App server) uses the OCI SDK, which automatically detects the instance identity and signs the requests.

**Advantage:** No API keys are stored on the VMs.
# terraform-k8s-linode
Create K8s clusters with Terraform on Linode Kubernetes Engine (LKE), a managed Kubernetes service. In this project I took advantage of the Linode  [signup promotion](https://www.linode.com/lp/brand-free-credit/?utm_source=learnk8s&utm_medium=sponsor&utm_campaign=sponsor-learnk8s-terraform&utm_content=video-hardening_access&utm_term=) which includes  100 USD in credits to spend on any service for the next 60 days after signing  up. Now let's get building! 

### Prerequisites
- Install [Terraform](https://developer.hashicorp.com/terraform/downloads)
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows)

## Getting started
- Create [main.tf](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/main.tf) to store your resource definitions.
- Create [variables.tf ](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/variables.tf) to define input variables that were referenced in [main.tf](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/main.tf) file. Notice that the vars token and kubeconfig are marked as sensitive as that they are not exposed CLI output, log output, or source control.
- Create [terraform.tfvar](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/terraform.tfvars) to define the values you would like to use in order to create your Kubernetes cluster. This enables reusing of the of the [main.tf](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/main.tf) and [variables.tf ](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/variables.tf) to create new clusters/resources in the future. This also makes a template. 

## Deploy the cluster
1. Run `terraform init`  initialize the working directory containing Terraform configuration files and install any required plugins i.e. Linode LKE Provider
2. Export your API token to an environment variable.Terraform [environment variables](https://developer.hashicorp.com/terraform/cli/config/environment-variables) prefixes are TF_VAR_* and can be used in the command line. This is so that you're not storing the token secret in plain text in the file. This method can be used locally. If using  CI/CD pipeline you may pass the secret as an env var securely. 
    ```
     export TF_VAR_token=XXXXXXXXX
    ```
3. Run `terraform plan -var-file="terraform.tfvars"` to see what resources will be deployed. 
4. Run ` terraform apply -var-file="terraform.tfvars"` to deploy the cluster. Now the cluster will be deployed and is ready to be connected to via `kubectl`
5. Configure `kubectl` configs to connect to your cluster. This command will use the terraform output as an env var, decode it , and then insert it into the `kubectl` config file `kubeconfig.yaml`
    ```
    export KUBE_VAR=`terraform output kubeconfig` && echo $KUBE_VAR | base64 -di > kube-config.yaml` 
    ```
6. Add the kubeconfig file to your $KUBECONFIG environment variable `export KUBECONFIG=kubeconfig.yaml`
7. View your nodes ` kubectl get nodes`
8. Tear down the resources you have created `terraform destroy --target linode_lke_cluster.saifk8s` 

## Configure Terraform backend with Linode Object Storage

A backend is where Terraform stores its [state](https://developer.hashicorp.com/terraform/language/state) data files. Terraform utilizes persisted state data to keep record of the resources it manages. Think of the state files as a checkpoint; Terraform uses state to know what has been already created or updated.

Also it is important to have the Terraform state stored remotely, so a need comes up for allowing to safely store the terraform configuration publicly without worrying about leaking sensitive information through the state. In this case, a Configuration for Terraform backend with Linode Object Storage is needed. Terraform doesn't fully support Linode as a backend, however Linode Object Storage _can_ be used as an S3 backend with few extra configurations. Let's build it!

1. In the  `main.tf` file, define the Linode storage cluster to be used, and storage bucket
```
data "linode_object_storage_cluster" "primary" {
  id = "us-east-1"
}

resource "linode_object_storage_bucket" "saif-tf-state" {
  cluster = data.linode_object_storage_cluster.primary.id
  label   = "saif-tf-state"
} 
```
2. Create the  `backend.tf` file which has the below Linode storage cluster details. 
NOTE: set skip_credentials_validation to true as terraform will reach out to AWS STS to try to validate the access keys which will fail as we're not using AWS.
```
terraform {
  backend "s3" {
    endpoint                    = "us-east-1.linodeobjects.com"
    profile                     = "linode-s3"
    skip_credentials_validation = true
    bucket                      = "saif-tf-state"
    key                         = "state.json"
    region                      = "us-east-1"
}
}
```
3. Create a Linode Personal Access token to apply the config and create the bucket and set it as an env var
```
export TF_VAR_token=<TF_VAR_token>

```
4. Configure storage access for terraform to be able to use the bucket as a backend as well as write to the bucket when the state is changed. This can be done on the Linode object storage [access keys tab](https://cloud.linode.com/object-storage/access-keys). Once the creds are obtained, run the following to initalize with the `access_key` and `secret_key` 
 ```
terraform init \
    -backend-config "access_key=<REDACTED>"  \
    -backend-config "secret_key=<REDACTED>"
```
   - **NOTE:** configuring these creds as such vs exporting it as an env var is a workaround due to the backend not supporting env vars. (see this [terraform issue](https://github.com/hashicorp/terraform/issues/13022#issuecomment-1426887003) for more details)


5. Now the files and configs are ready to be applied to create the bucket and to be used to store the terrform backend
```
terraform plan
terraform apply
```
5. You may use the command to view the state.json file `linode-cli obj ls <bucket_name>` 
```
linode-cli obj ls saif-tf-state
```
Output: 
```
$ linode-cli obj ls saif-tf-state
2023-02-11 22:27  7273  state.json
```
Above shows an update to the file since the last apply or destory command ran as the file will update the terraform state each time the state is changed.


## Deploy a Site on LKE

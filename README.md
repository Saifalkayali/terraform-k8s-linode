# terraform-k8s-linode
Creating K8s clusters with Terraform on Linode. Linode offers a [signup promotion](https://www.linode.com/lp/brand-free-credit/?utm_source=learnk8s&utm_medium=sponsor&utm_campaign=sponsor-learnk8s-terraform&utm_content=video-hardening_access&utm_term=) that includes USD100 credit to spend on any service for the next 60 days after signing  up. Linode Kubernetes Engine (LKE) is a managed Kubernetes service.

### Prerequisites
- Install [Terraform](https://developer.hashicorp.com/terraform/downloads)
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows)

## Getting started
- Create [main.tf](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/main.tf) to store your resource definitions.
- Create [variables.tf ](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/variables.tf) to define input variables that were referenced in [main.tf](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/main.tf) file.
- Create [terraform.tfvar](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/terraform.tfvars) to define the values you would like to use in order to create your Kubernetes cluster. This enables reusing of the of the [main.tf](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/main.tf) and [variables.tf ](https://github.com/Saifalkayali/terraform-k8s-linode/blob/main/variables.tf) to create new clusters/resources in the future. This also makes a template. 

## Deploy the cluster
1. Run `terraform init`  initialize the working directory containing Terraform configuration files and install any required plugins i.e. Linode lke Provider
2. Export your API token to an environment variable.Terraform environment variables prefixes are TF_VAR_* and can be used in the command line. This is so that you're not storing the token secret in plain text in the file. This method can be used locally. If using  CI/CD pipeline you may pass the secret as an env var securely. 
    ```
     export TF_VAR_token=XXXXXXXXX
    ```
3. Run `terraform plan -var-file="terraform.tfvars"` to see what will be deployed. 
4. Run ` terraform apply -var-file="terraform.tfvars"` to deploy the cluster. Now your cluster will be deploy and are ready to connect to it via `kubectl`
5. Configure `kubectl` configs to connect to your cluster. This command will use the terraform output as an env var and then decoding it to insert it into the `kubectl` config file `kubeconfig.yaml`
    ```
    export KUBE_VAR=`terraform output kubeconfig` && echo $KUBE_VAR | base64 -di > kube-config.yaml` This command will use the terraform output and 
    ```
6. Add the kubeconfig file to your $KUBECONFIG environment variable `export KUBECONFIG=kubeconfig.yaml`
7. View your nodes ` kubectl get nodes`
8. Tear down the resources you have created `terraform destroy`





# Metropolis
## Quickstart Guide

This project contains the quickstart guide to integrating with Metropolis.

This project is configured with two projects, a React front-end and a Ruby on Rails backend, and deployments are sent out via Kubernetes and helm, however using any other tools is possible and encouraged, too.

Once setup, pull requests will automatically provision sandbox environments for testing and use the GitHub Deployment API to expose the environment to you during development.

### Development Environment

Run the backend on port `4000` with the following command:

```
rails s -p 4000
```

Run the frontend on port `5000` with the following command:

```
PORT=5000 npm start
```

API AJAX commands can be proxied from the react front-end to the backend because of the `proxy` that is setup in `frontend/package.json`.

## Getting Started

**Step 1**, click the _Fork_ button and fork the repository to your GitHub account.

**Step 2**, copy the _Clone or Download_ URL and clone the repository on your computer.

```
git clone [GITHUB URL]
```

**Step 3**, built a template for the `terraform.tfvars` by copying the example in place.

```
cp infrastructure/terraform/terraform.tfvars.example infrastructure/terraform/terraform.tfvars
```

**Step 4**, populate this file with properties below.

**GitHub Configuration**

* Set the `github_clone_url` the file to be the same as your forked repo.
* Set the `github_repo` to be the path to access your GitHub repo for your fork.

**Metropolis Configuration**

Sign into the platform on Metropolis and visit your `Account Settings` page on your dashboard.

* Add your API public key and secret key into the `terraform.tfvars` file.

**Google Cloud**

* Sign into the [Google Cloud Console](http://console.cloud.google.com)

_Setup the Project_

* On the top navigation bar, click the project navigation tab to launch the project selection dialog.
* Click the button to create a new project.
* Enter a name of the project.
* Copy the Project ID and include it in the `terraform.tfvars` file.

_Setup the Service Account_

* In the side navigation select the option for `IAM & Admin`.
* Choose the option for `Service Accounts`.
* Click the option to `+ Create Service Account`.
* Give the service account a name, perhaps `Metropolis Quickstart`.
* Grant the account permissions for `Owner`.
* Click the button to `Create Key (optional)`.
* Download the JSON file to the location `infrastructure/terraform/gcp-service-account.json`.

**Google Container Registry**

* Update the `gcr_email` to include your email address.
* Replace `hello-metropolis` with the `project-id` you set for your Google Cloud Project in the `docker_repo_frontend` and `docker_repo_backend` fields.

**Kubernetes Configuration**

* Update `cluster_name` to include a unique identifier for your project, perhaps by changing the hash at the end of it.
* Update the `zone` and `region` if you'd like your Kubernetes Cluster to be configured in a different environment.

**Update Your DNS Record**

Currently the `terraform.tfvars` file has `domain_name` set to:

```
domain_name = "quickstart.hellometropolis.com"
```

This is configured in such a way so that if `Cloud DNS` is configured, subdomains will be created for each sandbox environment.  So for example `feature-123.quickstart.hellometropolis.com` could go to a sandbox with the id `feature-123`.

Alternatively, you can remove the quickstart DNS record configuration from the Metropolis Quickstart example by making adjustments to the `infrastructure/terraform/deployment.tf` file.

**SQL User Password**

Terraform will provision a CloudSQL instance with the user `metropolis` and the password you set in this file.  Change the `sql_user_password` field to be a unique and secure password for your installation.


### Provision

Navigate to the `infrastructure/terraform` folder and run:

```
terraform apply
```

And enter `yes` when prompted if this is correct.  This will provision your environment.

### Teardown

```
state rm google_sql_user.users
terraform destroy
```

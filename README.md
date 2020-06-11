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

### Step 1 – Fork the Project

Click the _Fork_ button and fork the repository to your GitHub account.

### Step 2 – Clone the Project

Copy the _Clone or Download_ URL and clone the repository on your computer.

```
git clone [GITHUB URL]
```
### Step 3 – Configure Terraform

> Terraform will configure the provisioning of Kubernetes Clusters, a Cloud SQL database and Metropolis compositions.  The GitHub configuration provided will be used to perform `git clone` within the CI pipeline in the compositions that Terraform makes.  

Build a template for the `terraform.tfvars` by copying the example in place.

```
cp infrastructure/terraform/terraform.tfvars.example infrastructure/terraform/terraform.tfvars
```

Then this file with properties below.

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
* Grant the account permissions for `Owner` and `Security Admin`.
* Click the button to `Create Key (optional)`.
* Download the JSON file to the location `infrastructure/terraform/gcp-service-account.json`.

_Setup `gcloud` command line utility_

We will use the `gcloud` CLI, so configure the project to be the one you created by first authenticating the CLI to the service account you just created.

```
gcloud auth activate-service-account --key-file gcp-service-account.json
```

Then switch the project to match the service account.  Run:

```
gcloud projects list
```

It may prompt you if you want to enable APIs in your account.  If it does, give your account permission to do so.  Then run this command to switch to the project in the CLI (replacing `PROJECT_ID` with your project id).

```
gcloud config set project PROJECT_ID
```

Run the following command to see which account your `gcloud` is authenticated against.

```
gcloud auth list
```

Then add the role of `roles/container.clusterAdmin` to the email address of the account.  Change the `EMAIL` to the email address of the account you're authenticated as.

```
gcloud projects add-iam-policy-binding metropolis-quickstart --member="serviceAccount:EMAIL" --role="roles/container.clusterAdmin"
```

_Setup `Cloud Build` Service Account Permissions_

> Cloud Build will automatically run `gcloud` with a service account that is configured for the `Cloud Build API`.  Configure this service account with to have access to the kubernetes cluster by doing the following.

* Visit the [Cloud Build API](https://console.cloud.google.com/marketplace/product/google/cloudbuild.googleapis.com) and enable it in your account.
* Visit the [Cloud Build Settings](https://console.cloud.google.com/cloud-build/settings/service-account) and find the `Service account email` and copy this email address.
* Allow CloudBuild to execute jobs against your Kubernetes cluster by running the following command (and replacing the `EMAIL` with the email you saw above):

```
gcloud projects add-iam-policy-binding metropolis-quickstart --member="serviceAccount:EMAIL" --role="roles/roles/secretmanager.secretAccessor"
```

```
gcloud projects add-iam-policy-binding metropolis-quickstart --member="serviceAccount:EMAIL" --role="roles/container.developer"
```

```
gcloud projects add-iam-policy-binding metropolis-quickstart --member="serviceAccount:EMAIL" --role="roles/cloudsql.admin"
```


**Google Container Registry**

* Update the `gcr_email` to include your email address.
* Replace `hello-metropolis` with the `project-id` you set for your Google Cloud Project in the `docker_repo_frontend` and `docker_repo_backend` fields.

**Kubernetes Configuration**

* Update `cluster_name` to include a unique identifier for your project, perhaps by changing the hash at the end of it.
* Update the `zone` and `region` if you'd like your Kubernetes Cluster to be configured in a different environment.

**Update Your DNS Record**

Currently the `terraform.tfvars` file has `domain_name` and `managed_zone` set to:

```
domain_name            = "metropolis-quickstart.host"
managed_zone           = "metropolis-quickstart-host"
```

This is configured in such a way so that if `Cloud DNS` is configured, subdomains will be created for each sandbox environment.  So for example `feature-123.metropolis-quickstart.host` could go to a sandbox with the id `feature-123`.

Alternatively, you can remove the quickstart DNS record configuration from the Metropolis Quickstart example by making adjustments to the `infrastructure/terraform/deployment.tf` file.

**Terraform State in Google Storage Bucket**

We will store the Terraform state data in Google Cloud Storage, but we will need to create a bucket.  Run the following command to create a Google Cloud Storage bucket, replacing `PROJECT_NAME` with the name name of your project.


```
gsutil mb gs://PROJECT_NAME-project-terraform-state
```

Update your `terraform.tfvars` file to set the `terraform_state_bucket` variable to the name of the bucket you created above.


### Step 4 – Configure Metropolis Runtime Engine

> Metropolis will need to be able to connect to a runtime engine to queue the jobs.  We will need to configure our Metropolis account to work in this environment.  These steps will configure Metropolis to Queue jobs on Google Cloud Platform's Cloud Build API.

1. Visit the [Metropolis Account Dashboard](http://hellometropolis.com/alpha/account_dashboard).
2. Create an account setting with the name `runtime-engine/gcp-project-id` and the value of your Google Cloud Platform Project for the jobs to run under.  It's usually easiest, to use the same project-id you used as a `project` in your `terraform.tfvars` file.
3. Create an account setting with the name `runtime-engine/gcp-service-account` and include the JSON for a Google Cloud Platform Service Account that has permissions to queue jobs on CloudBuild.  It's usually easiest, to use the same contents as the `gcp-service-account.json` file.

### Step 5 – Configure Metropolis Notification Engine

> Metropolis will need to be able to connect to third party services in order to notify when builds start and builds finish.  We will use the GitHub deployment API for this.

* Visit the [Metropolis GitHub Application](https://github.com/apps/hello-metropolis) and install the application to the `quickstart` repository you just forked.  This will allow Metropolis to use the `Deployment API` on behalf of your application when configured with GitHub's installation id.
* Confirm the flow to set the `notification-engine/github-application-installation-id` account setting to the value of the github application id.

### Step 6 – Configure Secrets

Some secrets will need to be shared between your Terraform, your CI servers, and your sandbox environments.  The quickstart environment uses [Google Cloud Secret Manager](https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets) to do just this.

A few commands need to be executed to store values in the secret manager to share them across the environments that need them in a secure way.

**Add the Rails Master Key** to the secrets manager.

**First**, regenerate your `master.key` encryption file.  Navigate to the folder of your backend project.

```
cd backend
```

**Second**, run the following command to create the `master.key` file locally.

```
rm config/master.key && rm config/credentials.yml.enc && EDITOR=vim rails credentials:edit
```

Press escape, :wq to save and quit the file.

**Third**, store the contents of this file in the `Google Cloud Secret Manager`:



```
cat config/master.key | gcloud beta secrets create "metropolis-quickstart-rails-master-key" --data-file - --replication-policy "automatic"
```

**Fourth**, commit and push the encrypted `credentials.yml.enc` file to GitHub.

```
git add --all
git commit -am "Ran rails credentials:edit to regenerate encoded credentials yaml file."
git push origin master
```

> **Note** If you ever need to change the credentials, if they are mounted in the
> Kubernetes pod you will need to rebuild the Kubernetes Secret too.
>
> 
> `terraform taint kubernetes_secret.metropolis_rails_master_key`
>
> Will do this command if you need to in the future.  You will only need to do this
> if you are trying to change this value after Kubernetes cluster is already provisioned.


**Add a secure random password for SQL**

If you have `openssl` and you want to use that to generate a password, the command `openssl rand -hex 12` can generate a new unique password for you to use.  Otherwise, feel free to use any password you wish, and replace `SQL_PASSWORD` with your actual password.

```
echo -n SQL_PASSWORD | gcloud beta secrets create "metropolis-quickstart-database-password" --data-file - --replication-policy "automatic"
```

**Generate a Deploy Key** and add it to the secrets manager.

Generate an SSH key pair

```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f github_deploy_key
```

Visit your GitHub repository.

* Click the **Settings** option.
* Click the **Deploy Keys** option.
* Click the **Add a deploy key** button.
* Run the following command to output your public key.

```
cat github_deploy_key.pub
```

* Copy and paste this into the field with a name.
* Press the **Add Key** button.
* Confirm your password.

Add your SSH key to the secrets manager.

```
cat github_deploy_key | gcloud beta secrets create "github_deploy_key" --data-file - --replication-policy "automatic"
```




### Step 7 – Test it out

#### Provision Infrastructure

Navigate to the `infrastructure/terraform` folder and run:

```
terraform apply
```

It may give you errors the first few times you run it.  Each time, it will prompt you to enable APIs on your account in the error messages.  Follow the links in the error messages to add access to these APIs.

And enter `yes` when prompted if this is correct.  This will provision your environment.

Wait for the terraform script to finish.

#### Visit the Dashboard

When you visit your Metropolis Dashboard you will see your Sandbox deployment running.  When the build finishes it will present with you the URL of the environment it just provisioned.

#### Test a Change

* Make a new branch
* Make a simple change, for example change the `message` in the `backend/app/controllers/health_checks_controller.rb` to a different hardcoded value to make the JSON the API produces something else.
* Push the new branch to GitHub
* Make a new Pull Request.
* Watch as Metropolis takes it from there and provisions a sandbox environment and updates GitHub.


#### Teardown (optional)

> You probably won't want these resources provisioned forever.  You can use terraform to remove them.

```
state rm google_sql_user.users
terraform destroy
```

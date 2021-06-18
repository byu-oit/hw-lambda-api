# hw-lambda-api
Example of creating and deploying an API with Lambda and Terraform on AWS

## Prerequisites

* Install [Terraform](https://www.terraform.io/downloads.html)
* Install the [AWS CLI](https://aws.amazon.com/cli/)
* Log into your `dev` account (with [`aws sso login`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/sso/login.html))
* Ensure your account has a [Terraform State S3 Backend](https://github.com/byu-oit/terraform-aws-backend-s3) deployed
* If you're outside the [`byu-oit` GitHub organization](https://github.com/byu-oit), obtain a DivvyCloud username and password from the Cloud Office at cloudoffice@byu.edu

## Setup
* Create a new repo [using this template](https://github.com/byu-oit/hw-lambda-api/generate).

  You need your own repo so that you can push changes and have CodePipeline deploy them.
  
  Keep your repo name relatively short. Since we're creating AWS resources based off the name, we've seen [issues with repo names longer than about 24 characters](https://github.com/byu-oit/hello-world-api/issues/22).

* Clone your new repo
```
git clone https://github.com/byu-oit/my-new-repo
```
* Check out the `dev` branch 
```
cd my-new-repo
git checkout -b dev
```
* Find and replace across the repo:
  * replace `977306314792` with your `dev` AWS account number
  * replace `539738229445` with your `prd` AWS account number
  * replace `hw-lambda-api` with the name of your repo
  * replace `byu-oit-terraform-dev` with the name of your `dev` AWS account
  * replace `byu_oit_terraform_dev` with the name of your `dev` AWS account (with underscores)
  * replace `byu-oit-terraform-prd` with the name of your `prd` AWS account
  * replace `byu_oit_terraform_prd` with the name of your `prd` AWS account (with underscores)
  * replace `#slack-bot-testing` with the name the Slack channel where you want to send deployment notifications
  * replace `Codepipeline-Standard-Change` with your [Standard Change Template ID](https://it.byu.edu/nav_to.do?uri=%2Fu_standard_change_template_list.do) - If you need to create a new template, ask in [#servicenow](https://byu-oit.slack.com/archives/C18T2SYTT) for help getting it into the [sandbox ServiceNow environment](https://support-test.byu.edu/)
* _Rename_ [`.postman/hw-lambda-api.postman_collection.json`](.postman/hw-lambda-api.postman_collection.json) with the name of your repo replacing `hw-lambda-api` in the filename
* Add yourself (or your team) as a [Dependabot reviewer](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/configuration-options-for-dependency-updates#reviewers) in [`dependabot.yml`](.github/dependabot.yml)
* Commit/push your changes
```
git commit -am "update template with repo specific details" 
git push
```

## Deployment

### Deploy the "one time setup" resources

```
cd terraform-iac/dev/setup/
terraform init
terraform apply
```

In the AWS Console, see if you can find the resources from `setup.tf` (SSM Param).

### Enable GitHub Actions on your repo

* Use this [order form](https://it.byu.edu/it?id=sc_cat_item&sys_id=d20809201b2d141069fbbaecdc4bcb84) to give your repo access to the secrets that will let it deploy into your AWS accounts. Fill out the form twice to give access to both your `dev` and `prd` accounts.
* In GitHub, go to the `Actions` tab for your repo (e.g. https://github.com/byu-oit/my-repo/actions)
* Click the `Enable Actions on this repo` button

If you look at [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml), you'll see that it is set up to run on pushes to the dev branch. Because you have already pushed to the dev branch, this workflow should be running now.

* In GitHub, click on the workflow run (it has the same name as the last commit message you pushed)
* Click on the `Build and Deploy` job
* Expand any of the steps to see what they are doing

### View the deployed application

Anytime after the `Terraform Apply` step succeeds:
```
cd ../app/
terraform init
terraform output
```

This will output a DNS Name. Enter this in a browser. You should get a JSON response. Between `index.js` and `main.tf`, can you find what pieces are necessary to make this data available to the app?

In the AWS Console, see if you can find the other resources from `main.tf`.

### Push a change to your application

Make a small change to `index.js` (try adding a `console.log`, a simple key/value pair to the JSON response, or a new path). Commit and push this change to the `dev` branch.

```
git commit -am "try deploying a change"
git push
```

In GitHub Actions, watch the deploy steps run (you have a new push, so you'll have to go back and select the new workflow run instance and the job again). Once it gets to the CodeDeploy step, you can watch the deploy happen in the CodeDeploy console in AWS. Once CodeDeploy says that production traffic has been switched over, hit your application in the browser and see if your change worked. If the service is broken, look at you Lambda logs in CloudWatch to see if you can figure out why.

> Note: 
>
> It's always best to test your changes locally before pushing to GitHub and AWS. Testing locally will significantly increase your productivity as you won't be constantly waiting for GitHub Actions and CodeDeploy to deploy, just to discover bugs.
>
> You can either test locally inside Docker, or with Node directly on your computer. Whichever method you choose, you'll have to setup any environment variables that your code is expecting when it runs in AWS. You can find these environment variables in `index.js` and `main.tf`. You'll also have to provide an alternate way of serving your API. Fronting the API code with an express app is a common pattern for local development. Then switching to using the Lambda Handler when deployed in AWS.

## Learn what was built

By digging through the `.tf` files, you'll see what resources are being created. You should spend some time searching through the AWS Console for each of these resources. The goal is to start making connections between the Terraform syntax and the actual AWS resources that are created.

Several OIT created Terraform modules are used. You can look these modules up in our GitHub Organization. There you can see what resources each of these modules creates. You can look those up in the AWS Console too.

<!--TODO add some architecture docs and diagrams -->

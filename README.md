# funkyswagger

Azure Function hosted Swagger UI using blob storage and Function proxies

## Background

Whilst working on something else, I came across a potential need to host the swagger UI in an Azure Function. Don't ask me why (not even sure it is really needed) but it seemed like a great chance to experiment with Azure Function Proxies, allowing me to run static websites from BLOB storage and only 
pay while they are being served.

## Approach

I wanted to be able to pull the latest files for "swagger-ui-dist" (the standalone version of swagger) and publish it without any modifications. This would allow me to produce something that was re-runnable without any custom hacks to get it working.

## Setup

My setup is as follows:

+ Windows 10
+ VSCode
+ Bash for Windows (running in VSCode terminal)

## Pre-Reqs

| Item      | Reason                              | Source                                               |
|-----------|:-----------------------------------:|-----------------------------------------------------:|
| Terraform | Used to build out environment       | [Downloads](https://www.terraform.io/downloads.html) |
| Azure-Cli | Used to deploy files to environment | sudo apt-get install azure-cli                       |
| npm       | Used to pull down swagger ui        | sudo apt-get install npm                             |
| jq        | Parsing json output of terraform    | sudo apt-get install jq                              |
| git       | For cloning my code :)              | sudo apt-get install git                             |

## Things I need to sort

Login - currently to authenticate run az login, plan to extend script to use service principal

jq output includes quotes within string values. I have included a work around, but being a C# developer and not a bash pro, I am sure there is a better way.

## Step 1

Clone repo
```
$ git clone https://github.com/JimPaine/funkyswagger.git
```

## Step 2

Login to the Azure cli

```
$ az login
```

## Step 3

Run deploy script

```
$ cd funkyswagger
$ ./deploy.sh {containername} {functionname} {subscriptionid} {backend_storage_account} {backend_storage_container} {backend_storage_access_key} {backend_key}
```

{containername} is the blob container that is used to store the swagger ui files, need reference to this to update the Azure Function Proxies

{functionname} what it says on the tin

{subscriptionid} so both the Azure cli and terraform can run agaist the right subscription

items for backend configuration

{backend_storage_account} storage account name - account must exist

{backend_storage_container} container name used to store state - container must exist

{backend_storage_access_key} storage account access key

{backend_key} key used to name blob eg. demo.funkyswagger.tfstate

## Step 4

Browse to https://{functionname}.azurewebsites.net

Paste in the link to your swagger spec and woo hoo! Remember you may need to extend CORS to allow the new origin.

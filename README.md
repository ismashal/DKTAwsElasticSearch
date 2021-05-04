## Elastic search on aws 

The follwing are the reasons to select AWS manged Elasticsearch services.

- High availability with Multi A/Z support
- AWS Manged Elasticsearch is easy to upgrade
- Capacity planning is very easy to add master and data nodes
- Infrastructure management is easy to mange in cluster
- Daily snapshots to S3 
- Easy logging, monitoring and alerting of the cluster
- Supports Reserved Instance pricing
- Manage authentication and access control using congnito(SSO) and IAM 
- Security point of view only SG is required to access the kibana 
- Amazon ES is PCI DSS, SOC, ISO etc regulatory requirements so need to worry about compliance.


### Run it!

1. Clone the repo: `git clone https://github.com/ismashal/DKTAwsElasticSearch.git`
- [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
- Export AWS access and secrete key your terminal
- Run terraform plan: `terraform plan`
- Build out infrastructure: `terraform apply`
- Will see the vpc and kibana endpoint
- Done!

#### _NOTE: This repo is not ready for production!_


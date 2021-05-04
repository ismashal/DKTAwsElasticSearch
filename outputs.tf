output "VPC" {
 value = "${aws_vpc.devops-vpc.id}"
}  
#Kibana dashboard endpoint
output "Kibana_Endpoint" {
 value = "${aws_elasticsearch_domain.devops_elastic_search.kibana_endpoint}"
}  


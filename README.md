# Déploiement automatisé d'infrastructure AWS avec Terraform

Ce projet vise à automatiser le déploiement d'une infrastructure AWS comprenant différents composants tels que VPC, Subnets, Security Groups, EC2 Instances, etc. La génération du script Terraform est automatisée à partir d'un fichier CSV paramétré selon les spécifications suivantes :
Structure du fichier CSV

Le fichier CSV doit être structuré comme suit :

```sh
Nom du template, Nom à attribuer, Paramètre(s) du template
```
Paramètres pour chaque template :

    VPC : cidr_block (par exemple 10.0.0.0/16)
    Subnet : vpc_id, cidr_block, availability_zone, route_table_association
    Security Group : vpc_id, port_to_open
    Security Group pour le serveur web : vpc_id, admin_port_to_open, http_https_ports_to_open
    Peering : main_vpc_id, second_vpc_id, cidr_vpc_1
    EC2 Instance : ami_id, ssh_key_name, subnet_id, user_data_script_file
    ALB (Application Load Balancer) : vpc_id, security_group_id, subnet_1, subnet_2, subnet_3
    Routage : vpc_id
    Serveur web : cidr_block, ssh_key_name, installation_script

Utilisation

    Créez votre fichier CSV avec les paramètres appropriés pour chaque template, en suivant la structure décrite ci-dessus.

    Exécutez le script de génération Terraform en passant le chemin vers votre fichier CSV comme argument :

    ./gen.sh chemin_vers_votre_fichier.csv

Le script générera les fichiers Terraform appropriés pour chaque template en fonction des paramètres fournis dans le fichier CSV.

Initialisez Terraform pour installer les modules nécessaires :

```sh
terraform init
```



Exécutez Terraform pour planifier et appliquer les changements :

```sh
terraform plan
terraform apply
```
Après avoir confirmé, Terraform commencera à provisionner les ressources sur AWS selon les spécifications fournies dans les fichiers Terraform générés.

Nettoyage

Après avoir terminé l'utilisation de votre infrastructure, n'oubliez pas de nettoyer les ressources AWS créées en exécutant la commande Terraform suivante :

```sh
terraform destroy
```

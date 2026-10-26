# Automated Docker Deployment on AWS

A cloud deployment project using Terraform, Ansible, Docker, Flask, and MySQL.

## Project Overview
This project automates the deployment of a Flask web application and a MySQL database on AWS EC2 using Infrastructure as Code and configuration management.

## Architecture
- **AWS VPC:** Isolated cloud network.
- **Public Subnet:** Hosts the web application server.
- **Private Subnet:** Hosts the database server.
- **Terraform:** Provisions AWS infrastructure.
- **Ansible:** Automates server configuration and deployment.
- **Docker:** Runs the Flask application and MySQL database.
- **Flask + Gunicorn:** Serves the web application.
- **MySQL 8.4:** Provides database services.

## AWS Infrastructure
- Region: `us-east-1`
- VPC CIDR: `10.0.0.0/16`
- Public Subnet: `10.0.1.0/24`
- Private Subnet: `10.0.2.0/24`
- Web Server: Amazon EC2
- Database Server: Amazon EC2
- Database: `appdb`

## Application Features
- Simple responsive web interface
- Application health endpoint: `/health`
- Database health endpoint: `/db-health`
- Docker container deployment
- Automated infrastructure provisioning with Terraform
- Server configuration using Ansible

## Project Structure
```text
automated-docker-deployment/
├── app/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── templates/
│   │   └── index.html
│   └── static/
│       └── css/
│           └── style.css
├── ansible/
│   ├── deploy-mysql.yml
│   ├── install-docker.yml
│   ├── db-vars.yml.example
│   └── inventory.ini.example
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── data.tf
    └── versions.tf
```

## Health Checks
Replace `YOUR_WEB_PUBLIC_IP` with the current public IP of your web EC2 instance.

Check application status:
```bash
curl http://YOUR_WEB_PUBLIC_IP/health
```

Check database connectivity:
```bash
curl http://YOUR_WEB_PUBLIC_IP/db-health
```

## Deployment Workflow
1. Provision AWS infrastructure using Terraform.
2. Configure EC2 servers using Ansible.
3. Deploy MySQL in a Docker container on the database server.
4. Build the Flask Docker image.
5. Deploy the Flask application on the web server.
6. Verify application health and database connectivity.

## Security Considerations
- Never commit passwords, SSH private keys, `.env` files, or Terraform state files.
- Store sensitive variables securely using Ansible Vault or AWS Secrets Manager.
- Restrict SSH access to trusted IP addresses.
- Keep the database in a private subnet.
- Use HTTPS for production deployments.
- Review AWS resources and delete unused resources to avoid unexpected charges.

## Technologies Used
`AWS` `EC2` `VPC` `Terraform` `Ansible` `Docker` `Flask` `Gunicorn` `MySQL` `Linux` `Git` `GitHub`

## Disclaimer
This project is intended for educational and portfolio purposes. Review security, availability, and cost requirements before using it in production.

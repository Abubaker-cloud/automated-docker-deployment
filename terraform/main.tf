# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# -------------------------
# Public Subnet
# -------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# -------------------------
# Private Subnet
# -------------------------

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# -------------------------
# Public Route Table
# -------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Elastic IP for NAT Gateway
# -------------------------

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# -------------------------
# NAT Gateway
# -------------------------

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat"
  }
}

# -------------------------
# Private Route Table
# -------------------------

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# -------------------------
# Web Security Group
# -------------------------

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow SSH and HTTP to Flask server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Flask application"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# -------------------------
# Database Security Group
# -------------------------

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Allow MySQL only from web server"
  vpc_id      = aws_vpc.main.id

  # Allow MySQL from Web Server
  ingress {
    description     = "Allow MySQL only from web server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # Allow SSH from Web Server
  ingress {
    description     = "SSH from web server for administration"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}


# -------------------------
# SSH Key Pair
# -------------------------

resource "aws_key_pair" "project" {
  key_name   = var.key_name
  public_key = file(pathexpand("~/.ssh/ansible-lab-key.pub"))

  tags = {
    Name    = var.key_name
    Project = var.project_name
  }
}

# -------------------------
# EC2 Web Server
# -------------------------

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.project.key_name

  tags = {
    Name    = "${var.project_name}-web"
    Role    = "web"
    Project = var.project_name
  }
}

# -------------------------
# EC2 Database Server
# -------------------------

resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = aws_key_pair.project.key_name

  tags = {
    Name    = "${var.project_name}-db"
    Role    = "database"
    Project = var.project_name
  }
}

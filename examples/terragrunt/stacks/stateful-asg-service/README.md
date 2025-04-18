# Stateful ASG Service Example

This is an example of how to use the following units in a stack:

- [mysql](/units/mysql) - Sets up a MySQL RDS instance for persistent storage
- [ec2-asg-stateful-service](/units/ec2-asg-stateful-service) - Deploys an EC2 Auto Scaling Group running a Bun application
- [asg-to-db-sg-rule](/units/asg-to-db-sg-rule) - Configures security group rules to allow ASG instances to connect to MySQL

## Usage

To deploy this example:

1. Navigate to the example directory:

   ```bash
   cd examples/terragrunt/stacks/stateful-asg-service
   ```

2. Run the following command to deploy the service:

   ```bash
   terragrunt stack run apply
   ```

3. After deployment, you can access the service through the ALB's DNS name, which will be shown in the output.

   ```bash
   terragrunt stack output
   ```

## Infrastructure Diagram

```mermaid
graph TB
    subgraph ALB[Application Load Balancer]
        ALB_NODE[ALB]
    end

    subgraph ASG[Auto Scaling Group]
        EC1[EC2 Instance 1]
        EC2[EC2 Instance 2]
        EC3[EC2 Instance 3]
    end

    subgraph DB[Database]
        MYSQL[(MySQL)]
    end

    ALB_NODE -->|3000| EC1
    ALB_NODE -->|3000| EC2
    ALB_NODE -->|3000| EC3

    EC1 -->|3306| MYSQL
    EC2 -->|3306| MYSQL
    EC3 -->|3306| MYSQL
```

## Components

### Application Load Balancer

- Listens on port 80 (configurable via `alb_port`)
- Forwards traffic to EC2 instances on port 3000 (configurable via `server_port`)
- Provides high availability and load balancing

### EC2 Auto Scaling Group

- Runs multiple EC2 instances (min 2, max 4 by default)
- Each instance runs a Bun application
- Application features:
  - REST API endpoints for movie data
  - Uses Drizzle ORM for database operations
  - Automatically runs migrations and seeds initial data
  - Endpoints:
    - `GET /` - Health check
    - `GET /movies` - List all movies
    - `GET /movies/:id` - Get movie by ID

### Database

- MySQL RDS instance for persistent storage
- Stores movie data in a `movies` table
- Security group rules allow access from ASG instances on port 3306

## Cleanup

When you're done testing, you can destroy the infrastructure:

```bash
terragrunt stack run destroy
```

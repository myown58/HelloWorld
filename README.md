# HelloWorld Spring Boot Application

A simple Spring Boot application with Docker and AWS ECR support.

## Features

- Spring Boot 3.2.0 with Java 17
- RESTful API endpoints
- Health check endpoint
- Docker containerization with multi-stage build
- AWS ECR integration
- GitHub Actions CI/CD pipeline

## Prerequisites

- Java 17 or higher
- Maven 3.6 or higher
- Docker (for containerization)
- AWS CLI (for ECR integration)
- AWS Account (for pushing to ECR)

## Project Structure

```
.
├── src/
│   ├── main/
│   │   ├── java/com/example/helloworld/
│   │   │   ├── HelloWorldApplication.java
│   │   │   └── controller/
│   │   │       └── HelloWorldController.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/com/example/helloworld/
│           └── HelloWorldApplicationTests.java
├── scripts/
│   ├── create-ecr-repository.sh
│   └── push-to-ecr.sh
├── .github/
│   └── workflows/
│       └── build-and-push-ecr.yml
├── Dockerfile
├── docker-compose.yml
├── pom.xml
└── README.md
```

## Local Development

### Building the Application

```bash
# Build the project
mvn clean package

# Run tests
mvn test

# Run the application
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

### Available Endpoints

- `GET /api/hello` - Returns a hello world message
- `GET /api/health` - Returns application health status
- `GET /actuator/health` - Spring Boot actuator health endpoint

### Testing the Endpoints

```bash
# Test hello endpoint
curl http://localhost:8080/api/hello

# Test health endpoint
curl http://localhost:8080/api/health

# Test actuator health endpoint
curl http://localhost:8080/actuator/health
```

## Docker

### Building the Docker Image

```bash
docker build -t helloworld:latest .
```

### Running with Docker

```bash
# Run the container
docker run -p 8080:8080 helloworld:latest

# Run in detached mode
docker run -d -p 8080:8080 --name helloworld-app helloworld:latest

# View logs
docker logs helloworld-app

# Stop the container
docker stop helloworld-app
```

### Using Docker Compose

```bash
# Start the application
docker-compose up

# Start in detached mode
docker-compose up -d

# Stop the application
docker-compose down
```

## AWS ECR Integration

### Prerequisites

1. Install and configure AWS CLI:
```bash
aws configure
```

2. Ensure you have the following permissions:
   - `ecr:GetAuthorizationToken`
   - `ecr:CreateRepository`
   - `ecr:BatchCheckLayerAvailability`
   - `ecr:PutImage`
   - `ecr:InitiateLayerUpload`
   - `ecr:UploadLayerPart`
   - `ecr:CompleteLayerUpload`

### Creating ECR Repository

```bash
# Create an ECR repository (optional - will be created automatically if it doesn't exist)
./scripts/create-ecr-repository.sh helloworld us-east-1
```

### Pushing to AWS ECR

```bash
# Push to ECR with default settings (us-east-1, repository: helloworld, tag: latest)
./scripts/push-to-ecr.sh YOUR_AWS_ACCOUNT_ID

# Push with custom settings
./scripts/push-to-ecr.sh YOUR_AWS_ACCOUNT_ID us-west-2 my-repo v1.0.0
```

### Manual ECR Push (Step by Step)

```bash
# 1. Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# 2. Build the Docker image
docker build -t helloworld:latest .

# 3. Tag the image for ECR
docker tag helloworld:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/helloworld:latest

# 4. Push the image to ECR
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/helloworld:latest
```

## GitHub Actions CI/CD

The project includes a GitHub Actions workflow that automatically:
1. Builds and tests the application
2. Pushes the Docker image to AWS ECR (on push to main/master)

### Setting up GitHub Actions

1. Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. Update the workflow file (`.github/workflows/build-and-push-ecr.yml`) if needed:
   - Change `AWS_REGION` if using a different region
   - Change `ECR_REPOSITORY` if using a different repository name

3. The workflow will run automatically on:
   - Push to main/master branch
   - Pull requests to main/master branch
   - Manual trigger (workflow_dispatch)

## Deploying to AWS

### Using ECS (Elastic Container Service)

```bash
# Pull the image from ECR
docker pull YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/helloworld:latest

# Run on ECS using the ECR image
# (Configure ECS task definition to use the ECR image URL)
```

### Using EKS (Elastic Kubernetes Service)

```yaml
# kubernetes-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld
spec:
  replicas: 2
  selector:
    matchLabels:
      app: helloworld
  template:
    metadata:
      labels:
        app: helloworld
    spec:
      containers:
      - name: helloworld
        image: YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/helloworld:latest
        ports:
        - containerPort: 8080
```

## Configuration

### Application Properties

Edit `src/main/resources/application.properties` to configure:
- Server port
- Spring application name
- Actuator endpoints
- Other Spring Boot properties

### Environment Variables

The following environment variables can be set:
- `SPRING_PROFILES_ACTIVE` - Active Spring profile (default, dev, prod)
- `SERVER_PORT` - Server port (default: 8080)
- `JAVA_OPTS` - JVM options (default: -Xmx512m -Xms256m)

## Troubleshooting

### Docker Build Issues

If you encounter issues building the Docker image:
```bash
# Clean Maven cache
mvn clean

# Rebuild with no cache
docker build --no-cache -t helloworld:latest .
```

### AWS ECR Authentication Issues

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Test ECR access
aws ecr describe-repositories --region us-east-1
```

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

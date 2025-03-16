pipeline {
    agent any
    stages {
        stage('Run Nginx in Docker on RHEL') {
            steps {
                sshCommand remote: 'rhel-server', command: '''
                    echo "Starting Nginx deployment in Docker..."

                    # Install Docker if not installed
                    sudo dnf install -y docker
                    sudo systemctl enable --now docker

                    # Pull the latest Nginx image
                    docker pull nginx:latest

                    # Stop and remove existing container if it exists
                    docker rm -f my-nginx || true

                    # Run Nginx container on port 80
                    docker run -d --name my-nginx -p 80:80 nginx:latest

                    # Open port 80 in the firewall
                    sudo firewall-cmd --add-port=80/tcp --permanent
                    sudo firewall-cmd --reload

                    echo "Nginx is deployed and running in Docker!"
                '''
            }
        }
        stage('Test Nginx Access') {
            steps {
                sshCommand remote: 'rhel-server', command: '''
                    echo "Testing Nginx..."

                    # Test if Nginx is accessible
                    if curl -s http://localhost | grep -q "Welcome to nginx"; then
                        echo "✅ Nginx is running and accessible!"
                    else
                        echo "❌ Nginx is NOT running properly!" >&2
                        exit 1
                    fi
                '''
            }
        }
    }
}

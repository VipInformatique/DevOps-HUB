pipeline {
    agent { label 'rhel' }
    stages {
        stage('System Update') {
            steps {
                sh 'sudo dnf update -y'
            }
        }
        stage('Deploy Nginx') {
            steps {
                sh 'docker pull nginx:latest'
            }
        }
        stage('Testing') {
            steps {
                script {
                    sh '''
                    # Run Nginx container
                    docker run -d --name test-nginx -p 8088:80 nginx:latest
                    sleep 5

                    # Test if Nginx is working
                    if curl -s http://localhost:8088 | grep -q "Welcome to nginx"; then
                        echo "Nginx is working properly."
                    else
                        echo "Error: Nginx is not working!" >&2
                        exit 1
                    fi

                    # Stop and remove the container
                    docker stop test-nginx
                    docker rm test-nginx
                    '''
                }
            }
        }
    }
}

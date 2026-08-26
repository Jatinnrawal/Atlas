pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate') {
            steps {
                sh '''
                    echo "Validating ATLAS project..."

                    test -f app/atlas-app.sh
                    test -f Dockerfile
                    test -f .dockerignore
                    test -f ansible/playbooks/server.yml
                    test -f ansible/roles/atlas_server/tasks/main.yml
                    test -f ansible/collections/requirements.yml

                    echo "Validation passed"
                '''
            }
        }

        stage('Test Application') {
            steps {
                sh '''
                    echo "Testing ATLAS application..."

                    bash -n app/atlas-app.sh

                    echo "Application syntax test passed"
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "Building ATLAS Docker image..."

                    docker build -t atlas:1.0.0 .

                    echo "ATLAS Docker image built successfully"

                    docker images atlas:1.0.0
                '''
            }
        }

        stage('Prepare Ansible') {
            steps {
                sh '''
                    cd ansible

                    if [ ! -d ".jenkins-venv" ]; then
                        echo "Creating Jenkins Ansible virtual environment..."
                        python3 -m venv .jenkins-venv
                    fi

                    . .jenkins-venv/bin/activate

                    echo "Installing Ansible dependencies..."

                    pip install --upgrade pip
                    pip install ansible boto3 botocore

                    echo "Installing AWS Ansible collection..."

                    ansible-galaxy collection install -r collections/requirements.yml

                    echo "Ansible executable:"
                    which ansible-playbook

                    echo "Ansible version:"
                    ansible-playbook --version

                    echo "AWS collection:"
                    ansible-galaxy collection list | grep amazon.aws
                '''
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'atlas-aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    sh '''
                        cd ansible

                        . .jenkins-venv/bin/activate

                        export AWS_DEFAULT_REGION=ap-south-1

                        echo "Deploying ATLAS..."

                        ansible-playbook playbooks/server.yml

                        echo "ATLAS deployment completed"
                    '''
                }
            }
        }

        stage('Verify') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'atlas-aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    sh '''
                        cd ansible

                        . .jenkins-venv/bin/activate

                        export AWS_DEFAULT_REGION=ap-south-1

                        echo "Verifying ATLAS service..."

                        ansible atlas_server \
                            -m ansible.builtin.command \
                            -a "systemctl is-active atlas"

                        echo "ATLAS verification successful"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'ATLAS pipeline completed.'
            echo 'ATLAS deployment successful!'
        }

        failure {
            echo 'ATLAS deployment failed!'
        }
    }
}

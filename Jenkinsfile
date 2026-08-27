pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_REGISTRY = '772954893836.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPOSITORY = 'atlas'
        IMAGE_TAG = "${BUILD_NUMBER}"
        ECR_IMAGE = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate') {
            steps {
                sh '''
                    set -e

                    test -f app/atlas-app.sh
                    test -f Dockerfile
                    test -f ansible/playbooks/server.yml
                    test -f ansible/roles/atlas_server/tasks/main.yml

                    bash -n app/atlas-app.sh

                    echo "Validation passed"
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    echo "Building ${ECR_IMAGE}"

                    docker build \
                        -t ${ECR_IMAGE} \
                        .

                    echo "Docker build successful"
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-atlas',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "Authenticating with AWS ECR..."

                        aws ecr get-login-password \
                            --region ${AWS_DEFAULT_REGION} | \
                        docker login \
                            --username AWS \
                            --password-stdin ${ECR_REGISTRY}

                        echo "Pushing ${ECR_IMAGE}"

                        docker push ${ECR_IMAGE}

                        echo "ECR push successful"
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-atlas',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        set -e

                        cd ansible

                        . .jenkins-venv/bin/activate

                        ansible-galaxy collection install \
                            -r collections/requirements.yml

                        echo "Deploying ATLAS image: ${ECR_IMAGE}"

                        ansible-playbook \
                            playbooks/server.yml \
                            -e "atlas_image_tag=${IMAGE_TAG}"
                    '''
                }
            }
        }

        stage('Verify') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-atlas',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        set -e

                        cd ansible

                        . .jenkins-venv/bin/activate

                        echo "Checking systemd service..."

                        ansible atlas_server \
                            -m ansible.builtin.command \
                            -a "systemctl is-active atlas"

                        echo "Checking ATLAS container..."

                        ansible atlas_server \
                            -m ansible.builtin.command \
                            -a "docker ps --filter name=atlas"

                        echo "Deployment verification passed"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "ATLAS deployment successful!"
            echo "Image deployed: ${ECR_IMAGE}"
        }

        failure {
            echo "ATLAS deployment failed!"
        }
    }
}

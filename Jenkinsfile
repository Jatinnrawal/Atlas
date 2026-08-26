pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
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
                    docker build -t atlas:${BUILD_NUMBER} .
                    docker tag atlas:${BUILD_NUMBER} atlas:latest
                '''
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
                        cd ansible

                        . .jenkins-venv/bin/activate

                        ansible-galaxy collection install \
                            -r collections/requirements.yml

                        ansible-playbook playbooks/server.yml
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
                        cd ansible

                        . .jenkins-venv/bin/activate

                        ansible atlas_server \
                            -m ansible.builtin.command \
                            -a "systemctl is-active atlas"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'ATLAS deployment successful!'
        }

        failure {
            echo 'ATLAS deployment failed!'
        }
    }
}

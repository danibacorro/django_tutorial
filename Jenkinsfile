pipeline {
    agent none
    environment {
        IMAGEN = "danibacorro/django_ic"
        LOGIN = 'USER_DOCKERHUB'
    }
    stages {
        stage('CI - Entorno Contenedor') {
            agent {
                docker {
                    image 'python:3.12-slim'
                    args '-u root:root'
                }
            }
            stages {
                stage('Clone') {
                    steps {
                        git branch: 'master', url: 'https://github.com/danibacorro/django_tutorial.git'
                    }
                }
                stage('Install') {
                    steps {
                        sh 'pip install -r requirements.txt'
                    }
                }
                stage('Test') {
                    steps {
                        sh 'python3 manage.py test'
                    }
                }
            }
        }
        stage('CD - Entorno Máquina Jenkins') {
            agent any
            stages {
                stage('Docker Build') {
                    steps {
                        sh "docker build -t $IMAGEN:latest ."
                    }
                }
                stage('Docker Push') {
                    steps {
                        withDockerRegistry(credentialsId: LOGIN, url: 'https://index.docker.io/v1/') {
                            sh "docker push $IMAGEN:latest"
                        }
                    }
                }
                stage('Docker Clean') {
                    steps {
                        sh "docker rmi $IMAGEN:latest"
                    }
                }
                stage('Docker Deploy') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'VPS', usernameVariable: 'VPS_USER', passwordVariable: 'VPS_PASS')]) {
                            
                            echo "Preparando directorio y enviando docker-compose.yaml a la VPS interna (192.168.0.3)..."
                            sh "sshpass -p '$VPS_PASS' ssh -o StrictHostKeyChecking=no \$VPS_USER@192.168.0.3 'mkdir -p /home/\$VPS_USER/app'"
                            sh "sshpass -p '$VPS_PASS' scp -o StrictHostKeyChecking=no docker-compose.yaml \$VPS_USER@192.168.0.3:/home/\$VPS_USER/app/"

                            echo "Recreando el entorno de producción con la nueva imagen..."
                            sh """
                            sshpass -p '$VPS_PASS' ssh -o StrictHostKeyChecking=no \$VPS_USER@192.168.0.3 "
                                cd /home/\$VPS_USER/app/ &&
                                docker compose down &&
                                docker compose pull &&
                                docker compose up -d
                            "
                            """
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            mail to: 'danibacorro@gmail.com',
            subject: "Status of pipeline: ${currentBuild.fullDisplayName}",
            body: "${env.BUILD_URL} has result ${currentBuild.result}"
        }
    }
}
#comentario de prueba

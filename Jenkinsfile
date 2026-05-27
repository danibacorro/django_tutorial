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

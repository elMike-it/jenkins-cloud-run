pipeline {
    agent any
    environment {
        PROJECT_ID = 'test-interno-trendit'
        SERVICE_NAME = 'mike-cloud-run-service'
        REGION = 'us-central1' // e.g., us-central1
        IMAGE_NAME = "gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
        GCP_KEYFILE = credentials('gcp-service-account-key') // Configurado en Jenkins
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate with GCP') {
            steps {
                script {
                withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    // Activa la cuenta de servicio para gcloud
                    sh """
                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                    gcloud config set project $PROJECT_ID
                    gcloud auth list
                    gcloud auth configure-docker us-central1-docker.pkg.dev
                    """
                     }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${IMAGE_NAME} .
                    """
                }
            }
        }
        stage('Create Artifact Registry Repo') {
            steps {
                script {
                    sh """
                    gcloud artifacts repositories describe ${SERVICE_NAME}-repo --location=${REPO_LOCATION} || \
                    gcloud artifacts repositories create ${SERVICE_NAME}-repo \
                        --repository-format=docker \
                        --location=${REPO_LOCATION} \
                        --description="Docker repo for ${SERVICE_NAME}"
                    """
                }
            }
        }
        stage('Push Docker Image to Artifact Registry') {
            steps {
                script {
                    sh """
                    gcloud auth configure-docker ${REPO_LOCATION}-docker.pkg.dev --quiet
                    docker tag ${IMAGE_NAME} ${REPO_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${SERVICE_NAME}-repo/${SERVICE_NAME}
                    docker push ${REPO_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${SERVICE_NAME}-repo/${SERVICE_NAME}
                    """
                }
            }
        }
        stage('Deploy to Cloud Run') {
            steps {
                script {
                    sh """
                    gcloud run deploy ${SERVICE_NAME} \
                        --image ${REPO_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${SERVICE_NAME}-repo/${SERVICE_NAME} \
                        --region ${REGION} \
                        --platform managed \
                        --allow-unauthenticated
                    """
                }
            }
        }
    }
    post {
        always {
            cleanWs() // Limpia el workspace después del pipeline
        }
    }
}

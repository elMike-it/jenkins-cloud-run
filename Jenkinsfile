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
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${IMAGE_NAME} .
                    """
                }
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
        stage('Push Docker Image to GCR') {
            steps {
                script {
                    sh """
                    gcloud auth configure-docker --quiet
                    docker push ${IMAGE_NAME}
                    """
                }
            }
        }
        stage('Deploy to Cloud Run') {
            steps {
                script {
                    sh """
                    gcloud run deploy ${SERVICE_NAME} \
                        --image ${IMAGE_NAME} \
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

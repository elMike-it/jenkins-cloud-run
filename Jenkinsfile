pipeline {
    agent any
    environment {
        PROJECT_ID = 'test-interno-trendit'
        SERVICE_NAME = 'mike-cloud-run-service'
        //REGION = 'your-region' // e.g., us-central1
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
                    sh """
                    echo "${GCP_KEYFILE}" > keyfile.json
                    gcloud auth activate-service-account --key-file=keyfile.json
                    gcloud config set project ${PROJECT_ID}
                    """
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

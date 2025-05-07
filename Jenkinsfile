pipeline{
    agent any
    stages {
        // --- CODE STAGE ---
        stage('Check Secrets - TruffleHog') {
            steps {
                echo 'TruffleHog Scanning...'
                // Add your build steps here
                script {
                    // Example of a shell command
                    sh 'echo "Building the project..."'
                }
            }
        }
        stage('SAST - SonarQube'){
            steps {
                echo 'Sonar Scanning...'
            }
        // --- BUILD STAGE ---
        stage('Dockerfile Lint - Hadolint') {
            steps {
                echo 'Hadolint scanning...'
                // Add your test steps here
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Image...'
                // Add your test steps here
            }
        }
        stage('Image Hardening - Dockle') {
            steps {
                echo 'Dockle scanning...'
                // Add your test steps here
            }
        }
        stage('Vuln Scan  - Trivy') {
            steps {
                echo 'Tri scanning...'
                // Add your test steps here
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                // Add your deployment steps here
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'This will always run, regardless of success or failure.'
        }
    }
    options {
        // timeout(time: 1, unit: 'HOURS') // Set a timeout for the entire pipeline
        timestamps() // Add timestamps to the console output
        // disableConcurrentBuilds() // Prevent concurrent builds of this pipeline
    }
}
    

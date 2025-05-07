pipeline{
    agent any
    stages {
        // --- CODE STAGE ---
        stage('Check Secrets - TruffleHog') {
            steps {
                echo 'Scanning Secret using TruffleHog...'
                scripts {
                    sh """
                        docker run --rm -it -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github --repo https://github.com/NandaNara/test-MEL > trufflehog.txt
                        cat trufflehog.txt
                    """
                }
                //sh 'docker run --rm -it -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github --repo https://github.com/NandaNara/test-MEL > trufflehog.txt'
                //sh 'cat trufflehog.txt'
            }
        }
        stage('SAST - SonarQube'){
            steps {
                echo 'Sonar Scanning...'
            }
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
        stage('Push Image to Registry') {
            steps {
                echo 'Pushing Image to Registry...'
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

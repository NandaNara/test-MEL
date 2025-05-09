pipeline{
    agent any
    tools {
        maven 'maven'
    }
    stages {
        // ======= CODE STAGE =======
        stage('Secret Scan - TruffleHog') {
            steps {
                echo 'Scanning secret using TruffleHog... '
                script{
                    sh """
                        docker run --rm -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github --repo https://github.com/NandaNara/test-MEL > trufflehog.txt
                        cat trufflehog.txt
                    """
                }
            }
        }
        // stage('Dependency Scan - Trivy (SCA)'){
        //     steps {
        //         echo 'Scanning dependencies using Trivy... '
        //         script {
        //             sh """
        //                 cat trufflehog.txt
        //             """
        //         }
        //     }
        // }
        stage('SAST - SonarQube') {
            steps {
                echo 'Sonar Scanning...'
                withSonarQubeEnv('sonar') {
                    sh """
                        mvn sonar:sonar
                        cat target/sonar/report-task.txt
                    """
                }
            }
        }
        // stage('Quality Gate - SonarQube') {
        //     steps {
        //         timeout(time: 3, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }
                withSonarQubeEnv('sonar') {
                    sh """
                        mvn sonar:sonar
                        cat target/sonar/report-task.txt
                    """
                }
            }
        }
        // stage('Quality Gate - SonarQube') {
        //     steps {
        //         timeout(time: 3, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }

        // --- BUILD STAGE ---
        stage('Dockerfile Lint - Hadolint') {
            steps {
                echo 'Hadolint linting...'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Image...'
            }
        }
        stage('Hardening Image - Trivy') {
            steps {
                echo 'Trivy hardening image...'
            }
        }
        stage('Misconfig & Images Scan - Trivy') {
            steps {
                echo 'Trivy scanning...'
            }
        }
        stage('Push Image to Registry') {
            steps {
                echo 'Pushing Image to Registry...'
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
        disableConcurrentBuilds() // Prevent concurrent builds of this pipeline
    }
}

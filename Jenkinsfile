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
                sh """
                    docker run --rm -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github \
                    --repo https://github.com/NandaNara/test-MEL > trufflehog.txt
                    cat trufflehog.txt
                """
            }
        }
        stage('Dependency Scan (SCA) - Trivy') {
            steps {
                echo 'Scanning dependency using Trivy... '
                sh """
                    trivy fs --scanners vuln,license --exit-code 1 --severity HIGH,CRITICAL \
                    --ignore-unfixed --no-progress --skip-dirs .git --skip-dirs node_modules \
                    --skip-dirs target --skip-dirs .idea --skip-dirs .gradle --skip-dirs .mvn \
                    --skip-dirs .settings --skip-dirs .classpath --skip-dirs .project . > trivy_sca.txt
                    cat trivy_sca.txt
                """
            }
        }
        stage('SAST - SonarQube'){
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
        stage('Quality Gate - SonarQube') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // ======= BUILD STAGE =======
        stage('Dockerfile Lint - Hadolint') {
            steps {
                script {
                    def dockerfiles = findFiles(glob: '**/Dockerfile')

                    if (dockerfiles.isEmpty()) {
                        error 'No Dockerfile found in the repository.'
                    }

                    dockerfiles.each { Df ->
                        def dirPath = Df.path.replace('/Dockerfile', ' ')
                        echo "Linting Dockerfile in directory: ${dirPath}"

                        sh """
                            docker run --rm -v $(pwd)/${dirPath}:/workspace hadolint/hadolint:latest-debian \
                            /workspace/Dockerfile > hadolint-report.txt
                            if [ -s hadolint-report.txt ]; then
                                echo 'Hadolint found issues in the Dockerfiles.'
                                cat hadolint-report.txt
                            else
                                echo 'Hadolint found no issues in the Dockerfiles.'
                            fi
                        """
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Image...'
                // Add your test steps here
            }
        }
        stage('Vuln Scan  - Trivy') {
            steps {
                echo 'Tri scanning...'
                // Add your test steps here
            }
        }
        stage('  - Trivy') {
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
        disableConcurrentBuilds() // Prevent concurrent builds of this pipeline
    }
}

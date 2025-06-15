pipeline{
    agent any
    environment {
        reports_dir = "${WORKSPACE}/reports"            // all reports dir

        code_dir = "${reports_dir}/code-stage"          // code stage reports dir
        build_dir = "${reports_dir}/build-stage"        // build stage reports dir
        test_dir = "${reports_dir}/dast-zap"            // test stage report dir

        trufflehog_dir = "${code_dir}/trufflehog"       // trufflehog report dir
        sca_dir = "${code_dir}/sca-trivy"               // trivy sca report dir
        sast_dir = "${code_dir}/sast-sonarqube"         // sonarqube report dir
        lint_dir = "${code_dir}/hadolint"               // hadolint report dir

        vuln_dir = "${build_dir}/vuln-scan-trivy"       // trivy vuln report dir
        harden_dir = "${build_dir}/harden-trivy"        // hardening report dir
    }
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
                    --repo https://github.com/NandaNara/test-MEL > ${trufflehog_dir}/trufflehog.txt
                    if [ -s trufflehog.txt ]; then
                        echo 'TruffleHog found secrets in the repository.'
                    else
                        echo 'TruffleHog found no secrets in the repository.'
                    fi
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
                    --skip-dirs .settings --skip-dirs .classpath --skip-dirs .project . --format json > ${sca_dir}/trivy_sca.json
                    if [ -s ${sca_dir}/trivy_sca.json ]; then
                        echo 'Trivy found issues in the dependencies.'
                    else
                        echo 'Trivy found no issues in the dependencies.'
                    fi
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
        stage('Dockerfile Lint - Hadolint') {
            steps {
                echo 'Linting Dockerfile using Hadolint...'
                // script {
                //     def dockerfiles = findFiles(glob: '**/Dockerfile')

                //     if (dockerfiles.isEmpty()) {
                //         error 'No Dockerfile found in the repository.'
                //     }

                //     dockerfiles.each { Df ->
                //         def dirPath = Df.path.replace('/Dockerfile', ' ')
                //         echo "Linting Dockerfile in directory: ${dirPath}"

                //         sh """
                //             docker run --rm -v \$(pwd)/${dirPath}:/workspace hadolint/hadolint:latest-debian \
                //             /workspace/Dockerfile > hadolint-report.txt
                //             if [ -s hadolint-report.txt ]; then
                //                 echo 'Hadolint found issues in the Dockerfiles.'
                //                 cat hadolint-report.txt
                //             else
                //                 echo 'Hadolint found no issues in the Dockerfiles.'
                //             fi
                //         """
                //     }
                // }
            }
        }

        // ======= BUILD STAGE =======
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
            archiceArtifacts artifacts: 'reports/**/*',
            allowEmptyArchive: true,         // Archive all reports and artifacts
            fingerprint: true,
            followSymlinks: false
        }
    }
    options {
        buildDiscarder(
            logRotator(
                artifactDaysToKeepStr: '30',        // Keep artifacts for 30 days
                artifactNumToKeepStr: '10',      // Keep the last 10 artifacts
                daysToKeepStr: '7',             // Keep logs for 7 days
            )
        )
        timestamps()        // Add timestamps to the console output
        disableConcurrentBuilds()       // Prevent concurrent builds of this pipeline
    }
}

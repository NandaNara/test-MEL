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
        stage('Setup Report Directories') {
            steps {
                echo 'Preparing workspace...'
                sh """
                    mkdir -p ${reports_dir} ${code_dir} ${build_dir} ${test_dir}
                    mkdir -p ${trufflehog_dir} ${sca_dir} ${sast_dir}
                    mkdir -p ${vuln_dir} ${harden_dir}
                """
            }
        }

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
                    --skip-dirs .settings --skip-dirs .classpath --skip-dirs .project . > ${sca_dir}/trivy_sca.txt

                    trivy fs --scanners vuln,config,secret,license --severity CRITICAL,HIGH,MEDIUM --exit-code 1 \
                    --dependency-types direct,dev . > ${sca_dir}/trivy_sca_full.txt
                    if [ ! -s ${sca_dir}/trivy_sca.txt ]; then
                        echo 'Trivy found no issues in the dependencies.'
                    else
                        echo 'Trivy found issues in the dependencies.'
                    fi
                """
            }
        }
        stage('SAST - SonarQube'){
            steps {
                script {
                    echo 'Sonar Scanning...'
                    def scannerHome = tool 'sonar';
                    withSonarQubeEnv(installationName: 'sonar') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.exclusions="**/*.java" \
                            -Dsonar.projectName="test-MEL" > ${sast_dir}/sast_report.txt 2>&1
                            if [ ! -s ${sast_dir}/sast_report.txt ]; then
                                echo 'SonarQube found no issues in the code.'
                            else
                                echo 'SonarQube found issues in the code.'
                            fi
                        """
                    }
                }
            }
        }
        stage('Dockerfile Lint - Hadolint') {
            steps {
                script {
                    catchError (buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        sh '''
                        lint_dir="reports/code-stage/hadolint"
                        mkdir -p "$lint_dir"
                        find . -name Dockerfile -exec sh -c '
                            lint_status=0
                            for dockerfile; do
                                filename=$(echo "$dockerfile" | sed "s|^\\./||" | tr "/" "_")
                                report="$lint_dir/${filename}_lint.txt"
                                echo "Linting: $dockerfile"
                                if ! docker run --rm -i hadolint/hadolint:latest-debian < "$dockerfile" > "$report" 2>&1;
                                #then
                                    #lint_status=$((lint_status + 1))
                                fi
                            done
                        ' sh {} +
                    '''
                    }
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

        // ======= TEST STAGE =======
        stage('DAST - ZAP Scan') {
            steps {
                echo 'Running DAST scan using ZAP...'
                // Add your DAST scan steps here
            }
        }

        // ======= ARCHIEVE ARTIFACTS =======
        stage('Archieve Artifacts') {
            steps {
                echo 'Archiving artifacts...'
                archiveArtifacts artifacts: 'reports/**/*.txt',
                allowEmptyArchive: true,
                fingerprint: true,
                followSymlinks: false
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
        // always {
        //     archiceArtifacts artifacts: 'reports/**/*.txt',
        //     allowEmptyArchive: true,
        //     fingerprint: true,
        //     followSymlinks: false
        // }
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

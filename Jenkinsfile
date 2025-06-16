pipeline{
    agent any
    environment {
        reports_dir = "${WORKSPACE}/reports"                // all reports dir

        code_dir = "${reports_dir}/code-stage"              // code stage reports dir
        build_dir = "${reports_dir}/build-stage"            // build stage reports dir
        test_dir = "${reports_dir}/dast-zap"                // test stage report dir

        trufflehog_dir = "${code_dir}/trufflehog"           // trufflehog report dir
        sca_dir = "${code_dir}/sca-trivy"                   // trivy sca report dir
        sast_dir = "${code_dir}/sast-sonarqube"             // sonarqube report dir
        lint_dir = "${code_dir}/hadolint"                   // hadolint report dir

        img_scan_dir = "${build_dir}/img-scan-trivy"        // iamge scan report dir
        build_log_dir = "${build_dir}/build-log"            // build log dir
    }
    tools {
        maven 'maven'
    }
    stages {
        stage('Clean Old Artifacts') {
            steps {
                echo 'Cleaning old artifacts... '
                // sh "rm -rf ${reports_dir}/*"
            }
        }
        stage('Setup Report Directories') {
            steps {
                echo 'Preparing workspace... '
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
                // sh """
                //     docker run --rm -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github \
                //     --repo https://github.com/NandaNara/test-MEL > ${trufflehog_dir}/trufflehog.json
                //     if [ ! -s ${trufflehog_dir}/trufflehog.json ]; then
                //         echo 'TruffleHog found no secrets in the repository.'
                //     else
                //         echo 'TruffleHog found secrets in the repository.'
                //     fi
                // """
            }
        }
        stage('Dependency Scan (SCA) - Trivy') {
            steps {
                echo 'Scanning dependency using Trivy... '
                // sh """
                //     trivy fs --exit-code 0 --scanners vuln,config,secret,license \
                //     --severity CRITICAL,HIGH,MEDIUM . -f json > ${sca_dir}/trivy_sca.json
                //     if [ ! -s ${sca_dir}/trivy_sca.json ]; then
                //         echo 'Trivy found no issues in the dependencies.'
                //     else
                //         echo 'Trivy found issues in the dependencies.'
                //     fi
                // """
            }
        }
        stage('SAST - SonarQube'){
            steps {
                script {
                    echo 'Sonar Scanning... '
                    // def scannerHome = tool 'sonar';
                    // withSonarQubeEnv(installationName: 'sonar') {
                    //     sh """
                    //         ${scannerHome}/bin/sonar-scanner \
                    //         -Dsonar.exclusions="**/*.java" \
                    //         -Dsonar.projectName="test-MEL" > ${sast_dir}/sonar_sast.json 2>&1
                    //         if [ ! -s ${sast_dir}/sonar_sast.json ]; then
                    //             echo 'SonarQube found no issues in the code.'
                    //         else
                    //             echo 'SonarQube found issues in the code.'
                    //         fi
                    //     """
                    }
                }
            }
        }
        stage('Dockerfile Lint - Hadolint') {
            steps {
                script {
                    echo 'Linting Dockerfiles using Hadolint... '
                    // catchError (buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    //     sh '''
                    //     lint_dir="reports/code-stage/hadolint"
                    //     mkdir -p "$lint_dir"

                    //     # find all Dockerfiles then lint them
                    //     find . -name Dockerfile -exec sh -c '
                    //         lint_status=0
                    //         for dockerfile; do
                    //             filename=$(echo "$dockerfile" | sed "s|^\\./||" | tr "/" "_")
                    //             report="$lint_dir/${filename}_lint.json"
                    //             echo "Linting: $dockerfile"
                    //             if ! docker run --rm -i hadolint/hadolint:latest-debian < "$dockerfile" > "$report" 2>&1; then
                    //                 lint_status=$((lint_status + 1))
                    //             fi
                    //         done
                    //     ' sh {} +
                    // '''
                    // }
                }
            }
        }
        // stage('Quality Gate - SonarQube') {
        //     steps {
        //         timeout(time: 5, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }

        // ======= BUILD STAGE =======
        stage('Build Docker Image') {
            steps {
                echo 'Building Image...'
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script {
                        sh '''
                            build_errors=0
                            image_names=""

                            # find all Dockerfiles then build them
                            find . -name Dockerfile -exec sh -c '
                                for dockerfile; do
                                    dir_path=$(dirname "$dockerfile")
                                    component=$(basename "$dir_path")
                                    image_name="mel/${component}:${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
                                    echo "Building: $image_name"

                                    # building each image
                                    if (cd "$dir_path" && docker build -t "$image_name" .) then
                                        echo "Successfully built: $image_name"
                                        # save iamge name for next stage
                                        echo "$image_name" >> image_names.txt
                                    else
                                        echo "Failed to build: $image_name"
                                        build_errors=$((build_errors + 1))
                                    fi
                                done
                            ' sh {} +

                            # save images names which suscessfully built to env.properties
                            if [ -f image_names.txt ]; then
                            echo "BUILT_IMAGES=$(paste -sd, image_names.txt)" >> env.properties
                            fi
                            exit 0
                        '''
                    }
                }
            }
        }
        stage('Image Scan - Trivy') {
            steps {
                script {
                    echo 'Trivy scanning... '
                //     sh """
                //         trivy image --exit-code 0 --severity CRITICAL,HIGH \
                //         --security-checks config \
                //         --scanners vuln,config,secret,license ${image_name} \
                //         -f json > ${img_scan_dir}/trivy_img_scan.json
                //         if [ ! -s ${img_scan_dir}/trivy_img_scan.json ]; then
                //             echo 'Trivy found no issues in the image.'
                //         else
                //             echo 'Trivy found issues in the image.'
                //         fi
                //     """
                // }
            }
        }
        stage('Push Image to Registry') {
            steps {
                echo 'Pushing Image to Registry...'
                // Add your deployment steps here
            }
        }

        // ======= TEST STAGE =======
        stage('DAST - OWASP ZAProxy') {
            steps {
                echo 'Running DAST scan using ZAP...'
                // Add your DAST scan steps here
            }
        }

        // ======= ARCHIEVE ARTIFACTS =======
        stage('Archieve Artifacts') {
            steps {
                echo 'Archiving artifacts...'
                archiveArtifacts artifacts: 'reports/**/*.json',
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
    options {
        buildDiscarder(
            logRotator(
                artifactDaysToKeepStr: '30',        // Keep artifacts for 30 days
                artifactNumToKeepStr: '10',         // Keep the last 10 artifacts
                daysToKeepStr: '7',                 // Keep logs for 7 days
            )
        )
        timestamps()                    // Add timestamps to the console output
        disableConcurrentBuilds()       // Prevent concurrent builds of this pipeline
    }
}

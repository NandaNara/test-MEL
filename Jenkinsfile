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
        // build_log_dir = "${build_dir}/build-log"            // build log dir
        // DOCKERHUB_CREDENTIALS = credentials('test-MEL-dockerhub')
        // DOCKERHUB_CREDENTIALS_USR = "${DOCKERHUB_CREDENTIALS.username}"
    }
    tools {
        maven 'maven'
    }
    stages {
        stage('Clean Old Artifacts') {
            steps {
                echo 'Cleaning old artifacts... '
                sh "rm -rf ${reports_dir}/*"
            }
        }
        stage('Setup Report Directories') {
            steps {
                echo 'Preparing workspace... '
                sh """
                    mkdir -p ${reports_dir} ${code_dir} ${build_dir} ${test_dir}
                    mkdir -p ${trufflehog_dir} ${sca_dir} ${sast_dir} ${lint_dir}
                    mkdir -p ${img_scan_dir}
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
                    // }
                }
            }
        }
        stage('Dockerfile Lint - Hadolint') {
            steps {
                script {
                    echo 'Linting Dockerfiles using Hadolint... '
                    // catchError (buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
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
        // stage('Dockerhub Login') {
        //     steps {
        //         echo 'Logging in to Dockerhub...'
        //         sh 'echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin'
        //     }
        // }
        stage('Build Docker Image') {
            environment {
                DOCKER_BUILDKIT = "1"
            }
            steps {
                echo 'Building Image...'
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    script {
                        sh '''
                            build_errors=0
                            export DOCKER_BUILDKIT=1
                            image_name=""
                            rm -rf image_names.txt built_images.txt

                            # find all Dockerfiles then build them
                            find . -name Dockerfile -exec sh -c '
                                for dockerfile; do
                                    dir_path=$(dirname "$dockerfile")
                                    component=$(basename "$dir_path")
                                    image_name="mel/${component}:${BUILD_ID}"
                                    echo "Building: $image_name"

                                    # building each image
                                    if (cd "$dir_path" && docker build -t "$image_name") then
                                        echo "Successfully built: $image_name"

                                        # save image name for next stage
                                        echo "$image_name" > image_names.txt
                                    else
                                        echo "Failed to build: $image_name"
                                        build_errors=$((build_errors + 1))
                                    fi
                                done
                            ' sh {} +

                            # save images names which suscessfully built to env.properties
                            if [ -f image_names.txt ]; then
                                sort -u image_names.txt > built_images.txt
                            fi
                            exit 0
                        '''
                        // sh '''
                        //     if (cd "$dir_path" && docker build \
                        //                 --cache-from "$cache_image" \
                        //                 --build-arg BUILDKIT_INLINE_CACHE=1 \
                        //                 -t "$image_name" .) then
                        // # save cache image for next build
                        //                  docker tag "$image_name" "$cache_image"
                        //                  docker push "$cache_image" || echo "Cache push failed, but build succeeded"
                        // '''
                    }
                }
            }
            post {
                always {
                    script {
                        // save built image for next stage
                        if (fileExists('built_images.txt')) {
                            env.BUILT_IMAGES = readFile('built_images.txt').readLines().unique().join(',')
                            // .trim().replace('\n', ',')
                            echo "Successfully built images: ${env.BUILT_IMAGES}"
                        }
                    }
                }
            }
        }
        stage('Image Scan - Trivy') {
            steps {
                script {
                    echo 'Trivy scanning... '
                    def images = env.BUILT_IMAGES
                    def scanReports = [:]
                    sh 'mkdir -p "$img_scan_dir"'

                    // find all images then scan them
                    images.each { image ->
                        def safeImageName = image.replaceAll('[:/]', '_')
                        def reportFile = "${img_scan_dir}/trivy_${safeImageName}.json"

                        scanReports["scan_${safeImageName}"] = {
                            catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                                sh """
                                    echo "Scanning image: ${image}"
                                    trivy image --exit-code 0 --severity CRITICAL,HIGH \
                                    --security-checks config \
                                    --scanners vuln,config,secret,license "${image}" \
                                    -f json > "${reportFile}"
                                    if [ ! -s "${reportFile}" ]; then
                                        echo "✅ Trivy found no issues in: ${image}"
                                    else
                                        echo "Trivy found issues in: ${image}"
                                    fi
                                """
                            }
                        }
                        parallel scanReports
                    }
                }
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
        always {
            echo 'Cleaning up docker...'
            sh 'docker system prune -f || true'
            sh 'docker logout'
        }
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
    }
}

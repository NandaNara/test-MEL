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
                script {
                    def dockerfiles = sh(
                        script: 'find . -name Dockerfile',returnStdout: true
                        ).trim().split('\n')

                    def parallelBuilds = [:]
                    def components = []

                    dockerfiles.each { dockerfile ->
                        def dirPath = sh(
                            script: "dirname '${dockerfile}'", returnStdout: true
                        ).trim()
                        def component = sh(
                            script: "basename '${dirPath}'", returnStdout: true
                        ).trim()
                        components << component
                        parallelBuilds["build_${component}"] = {
                            catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                                dir(dirPath) {
                                    script {
                                        def image_name = "mel/${component}:${env.BUILD_ID}"
                                        sh """
                                            echo "Building: $image_name"
                                            docker build -t "$image_name" .

                                            # Simpan nama image ke file sementara
                                            echo "$image_name" >> "${env.WORKSPACE}/image_names.txt"
                                        """
                                    }
                                }
                            }
                        }
                    }
                    parallel parallelBuilds
                    if (fileExists('image_names.txt')) {
                        sh '''
                            sort -u image_names.txt > built_images.txt
                        '''
                    }
                }
            }
            post {
                always {
                    script {
                        sh 'rm -f image_names.txt || true'
                        // save built image for next stage
                        if (fileExists('built_images.txt')) {
                            env.BUILT_IMAGES = readFile('built_images.txt').trim().replace('\n', ',')
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
                    def images = env.BUILT_IMAGES.split(',')
                    def scanReports = [:]
                    sh 'mkdir -p "$img_scan_dir"'

                    // find all images then scan them
                    images.each { image ->
                        def safe_image_name = image.replaceAll('[:/]', '_')
                        def reportFile = "${img_scan_dir}/trivy_${safe_image_name}.json"

                        scanReports["scan_${safe_image_name}"] = {
                            catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                                sh """
                                    echo "Scanning image: ${image}"
                                    trivy image --exit-code 0 --severity CRITICAL,HIGH \
                                    --security-checks config \
                                    --scanners vuln,config,secret,license "${image}" \
                                    -f json > "${reportFile}"
                                    if [ ! -s "${reportFile}" ]; then
                                        echo "Trivy found no issues in: ${image}"
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
            environment {
                DOCKERHUB_CREDENTIALS = credentials('test-MEL-dockerhub')
            }
            steps {
                echo 'Pushing Image to Registry...'
                script {
                    if (env.BUILT_IMAGES) {
                        def images = env.BUILT_IMAGES.split(',')
                        sh '''
                            echo "Logging in to DockerHub..."
                            sh ' echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin'
                        '''
                        def parallelPushes = [:]
                        images.each { image ->
                            def reg_image_name = image.replaceAll('[:/]', '_')
                            parallelPushes["push_${reg_image_name}"] = {
                                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                                    sh """
                                        echo "Pushing image: ${reg_image_name}"
                                        docker push "nandanara/${reg_image_name}"
                                    """
                                }
                            }
                        }
                        parallel parallelPushes
                    }
                }
            }
            post{
                always {
                    sh 'docker logout'
                }
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

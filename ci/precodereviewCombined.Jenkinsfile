#!/usr/bin/env groovy

def bob = "./bob/bob"

def HOST_CLUSTER = "kroto012"

def SLAVE_NODE = null

node(label: 'docker') {
    stage('Nominating build node') {
        SLAVE_NODE = "${NODE_NAME}"
        echo "Executing build on ${SLAVE_NODE}"
    }
}

pipeline {
    agent {
        node {
            label "${SLAVE_NODE}"
        }
    }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '50', artifactNumToKeepStr: '50'))
    }

    environment {
        HOST_CLUSTER = "${HOST_CLUSTER}"
        K8S_NAMESPACE = "lcm-pypiserver-ci"
        TEAM_NAME = "${teamName}"
        DOCKER_CONFIG_FILE = "${WORKSPACE}"
        KUBECONFIG = "${WORKSPACE}/.kube/config"
        MAVEN_CLI_OPTS = "-Duser.home=${env.HOME} -B -s ${env.SETTINGS_CONFIG_FILE_NAME}"
        GIT_AUTHOR_NAME = "mxecifunc"
        GIT_AUTHOR_EMAIL = "PDLMMECIMM@pdl.internal.ericsson.com"
        GIT_COMMITTER_NAME = "${USER}"
        GIT_COMMITTER_EMAIL = "${GIT_AUTHOR_EMAIL}"
        GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o GSSAPIAuthentication=no -o PubKeyAuthentication=yes"
        GERRIT_CREDENTIALS_ID = 'gerrit-http-password-mxecifunc'
        DOCKER_CONFIG = "${WORKSPACE}"
        FOSSA_ENABLED = "true"
        HELM_UPGRADE="false"
        HELM_DR_CHECK="true"
        
        CREDENTIALS_SELI_ARTIFACTORY = credentials('SELI_ARTIFACTORY')   // exposes CREDENTIALS_SELI_ARTIFACTORY_USR and CREDENTIALS_SELI_ARTIFACTORY_PSW
        SELI_ARTIFACTORY_REPO_API_KEY = credentials('arm-api-token-mxecifunc')
        SERO_ARTIFACTORY_REPO_API_KEY = credentials ('SERO_ARM_TOKEN')
        HELM_REPO_CREDENTIALS=credentials('helm-credentials')
        SELI_ARTIFACTORY_REPO = credentials('SELI_ARTIFACTORY')  // exposes SELI_ARTIFACTORY_REPO_USR and SELI_ARTIFACTORY_REPO_PSW

        TLS_ENABLE = "true"
        SERVICEMESH_ENABLE = "true"
        LOGSHIPPER_ENABLED = "true"
        BRO_ENABLED = "false"
    }

    // Stage names (with descriptions) taken from ADP Microservice CI LibraryManager Step Naming Guideline: https://confluence.lmera.ericsson.se/pages/viewpage.action?pageId=122564754
    stages {
        stage('Commit Message Check') {
            steps {
                script {
                    def final commitMessage = new String(env.GERRIT_CHANGE_COMMIT_MESSAGE.decodeBase64())
                    if (commitMessage ==~ /(?ms)((Revert)|(\[MEE\-[0-9]+\])|(\[MXE\-[0-9]+\])|(\[MXESUP\-[0-9]+\])|(\[NoJira\]))+\s\S.*/) {
                        gerritReview labels: ['Commit-Message': 1]
                    } else {
                        def final message = 'Commit message check has failed'
                        def final link = 'https://confluence.lmera.ericsson.se/display/MXE/Code+review+WoW'
                        addWarningBadge text: message, link: link
                        addShortText text: 'malformed commit-msg', link: link, border: 0
                        gerritReview labels: ['Commit-Message': -1], message: message + ', see ' + link
                    }
                }
            }
        }

        stage('Submodule Init'){
            steps{
                sshagent(credentials: ['ssh-key-mxecifunc']) {
                    sh 'git clean -xdff'
                    sh 'git submodule sync'
                    sh "git submodule update --init bob mlops-utils"
                }
            }
        }

        stage('Clean') {
            steps {
                script{
                    sh "${bob} clean"
                }
            }
        }

        stage('Init') {
            steps {
                script {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'ruleset2.0.yaml, ci/precodereview.Jenkinsfile'
                    authorName = sh(returnStdout: true, script: 'git show -s --pretty=%an')
                    currentBuild.displayName = currentBuild.displayName + ' / ' + authorName
                    sh "./bob/bob init-precodereview"

                    withCredentials([file(credentialsId: 'ARM_DOCKER_CONFIG', variable: 'DOCKER_CONFIG_FILE')]) {
                        writeFile file: 'config.json', text: readFile(DOCKER_CONFIG_FILE)
                    }
                }
            }
        }

        stage('Lint') {
            steps {
                parallel(
                    // "lint markdown": {
                    //     sh "./bob/bob lint-markdown lint-vale"
                    // },
                    "lint helm": {
                        sh "./bob/bob lint-helm"
                    },
                    "lint code": {
                         sh "./bob/bob lint-license-check"
                     },
                )
            }
            post {
                success {
                    gerritReview labels: ['Code-Format': 1]
                }
                unsuccessful {
                    gerritReview labels: ['Code-Format': -1]
                }
            }
        }

        stage('Images') {
            environment{
                ARM_API_TOKEN = credentials('arm-api-token-mxecifunc')
                SERO_ARM_TOKEN = credentials ('SERO_ARM_TOKEN')
            }
            steps {
                script {
                    sh "${bob} image"
                }
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: '**/image-design-rule-check-report*'
                }
            }
        }

        stage('Package') {
            steps {
                sh "./bob/bob package"
            }
        }

        stage('Helm DR Check') {
            when {
                expression {  env.HELM_DR_CHECK == "true" }
            }
            steps {
                parallel(
                    "Main Chart": {
                        script {
                            sh "./bob/bob lint-helm-dr-check"
                        }
                    }
                )
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: '**/design-rule-check-report*'
                    archiveArtifacts allowEmptyArchive: true, artifacts: '**/emailable-report.html'
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'build/checker-reports/helm/yamllint/*.yaml'
                }
            }
        }

        stage('Cluster Setup') {
            environment {
                KUBECONFIG = credentials("kubeconfig-${HOST_CLUSTER}")
                INGRESSCLASS_SYNC = "false" // This needs to be set to true for model-lcm deployment where kserve is used
                K8S_VERSION = "1.27.7"
                VCLUSTER_VERSION = "0.16.4"
            }
            steps {
                    script {
                        sh "git submodule update --remote mlops-utils" // Update mlops-utils to latest version
                        sh './bob/bob infra.cluster-create'
                        sh './bob/bob infra.create-cert'
                    }
                }
        }
        
        stage('Deploy and Validate') {
            environment {
                KUBECONFIG= sh (returnStdout: true, script: 'realpath vcluster*').trim()
                INGRESS_HOST_NAME= sh (returnStdout: true, script: 'grep -w lcm-package-repository-py-tls .clusterinfo|cut -d":" -f2').trim()
                INGRESS_HOST_TLS_SECRET_MANIFEST = sh (returnStdout: true, script: 'realpath lcm-package-repository-py-tls.yaml').trim()
            }
            stages {
                stage('Helm Install') {
                    steps {
                        echo "The namespace (${env.K8S_NAMESPACE}) is reserved and locked based on the Lockable Resource name: ${env.RESOURCE_NAME}"
                        script {
                                if (env.HELM_UPGRADE == "true") {
                                    echo "HELM_UPGRADE is set to true"
                                    sh "./bob/bob helm-upgrade"
                                } else {
                                    echo "HELM_UPGRADE is NOT set to true"
                                    sh "./bob/bob helm-install"
                                }
                        }
                    }
                    post {
                        always {
                            sh "./bob/bob kaas-info || true"
                            archiveArtifacts allowEmptyArchive: true, artifacts: 'build/kaas-info.log'
                        }
                        unsuccessful {
                            gerritReview labels: ['System-Test': -1]
                            sh "./bob/bob collect-k8s-logs || true"
                            archiveArtifacts allowEmptyArchive: true, artifacts: "k8s-logs/*"
                            sh "./bob/bob test-cleanup"
                        }
                    }
                }
                stage('K8S Test') {
                    steps {
                        echo "HELM test"
                        sh "./bob/bob helm-test"
                    }
                    post{
                        success {
                            gerritReview labels: ['System-Test': 1]
                        }
                        unsuccessful {
                            gerritReview labels: ['System-Test': -1]
                            sh "./bob/bob collect-k8s-logs || true"
                            archiveArtifacts allowEmptyArchive: true, artifacts: "k8s-logs/*"
                        }
                        always {
                            archiveArtifacts artifacts: 'test-reports/**/*.*', allowEmptyArchive: true
                            robot outputPath: '.', logFileName: '**/log.html', outputFileName: '**/output.xml', reportFileName: '**/report.html', otherFiles:'**/*screenshot*', passThreshold: 100, unstableThreshold: 75.0
                        }
                        cleanup {
                            echo "HELM test clean up"
                            sh "./bob/bob test-cleanup"
                        }
                    }
                }
            }
        }

        stage('Publish Chart Internal') {
            steps {
                sh "./bob/bob publish-chart-local"
            }
        }
        
        stage('FOSSA Scan'){
            when {
                expression {  env.FOSSA_ENABLED == "true" }
            }
            environment{
                FOSSA_API_KEY = credentials('FOSSA_API_KEY_PROD')
            }
            stages{                    
                stage('FOSSA Server Status Check') {
                    steps {
                        sh "${bob} fossa-server-check"
                    }
                }

                stage('FOSSA Analyze') {
                    when {
                        expression { readFile('.bob/var.fossa-available').trim() == "true" }
                    }
                    steps {
                        script {
                            sh "${bob} fossa-pypiserver-analyze"
                        }
                    }
                }
                stage('Fossa Scan Status Check'){
                    when {
                        expression { readFile('.bob/var.fossa-available').trim() == "true" }
                    }
                    steps {
                        script {
                            sh "${bob} fossa-pypiserver-scan-status-check"
                        }
                    }
                }
                stage('FOSSA Fetch Report') {
                    when {
                        expression {  readFile('.bob/var.fossa-available').trim() == "true" }
                    }
                    steps {
                        retry(5) {
                                sh "${bob} fetch-pypiserver-fossa-report-attribution"
                                archiveArtifacts allowEmptyArchive: true, artifacts: 'build/fossa/*.json'
                            }
                    }
                }
            }
        }

        stage('FOSSA Dependency Validate') {
            steps {
                sh "${bob} dependency-validate-pypiserver"
            }
        }

        stage('Generate Input Files') {
            environment{
                MUNIN_TOKEN = credentials('MUNIN_TOKEN')
            }
            steps {
                parallel(
                    "pypiserver Dependency File for Registration": {
                        script {
                          sh "${bob} check-foss-in-mimer-pypiserver"
                        }
                    },
                )
            }
            post {
                always {
                   archiveArtifacts allowEmptyArchive: true, artifacts: 'config/fossa/dependencies.pypiserver.yaml'
                }
            }
        }
    }
    post {
        success {
            script {
                modifyBuildDescription()
                cleanWs()
            }
        }
        always {
            withCredentials([file(credentialsId: "kubeconfig-${HOST_CLUSTER}", variable: 'kubeconfig_file')]) {
                withEnv(["KUBECONFIG=${kubeconfig_file}"]) {
                    sh """
                        ./bob/bob infra.cluster-delete
                        ./bob/bob infra.delete-cert
                   """
                }
            }
        }
    }
}

def modifyBuildDescription() {

    def DOCKER_IMAGE_PREFIX="eric-lcm-package-repository-py"
    def IMAGE_SUFFIXES=["pypiserver"]
    def VERSION = readFile('.bob/var.version').trim()

    def desc = "Docker Images: <br>"
    for (suffix in IMAGE_SUFFIXES) {
       def DOCKER_IMAGE_NAME="${DOCKER_IMAGE_PREFIX}-${suffix}"
       def DOCKER_IMAGE_DOWNLOAD_LINK = "https://armdocker.rnd.ericsson.se/artifactory/proj-mlops-ci-internal-docker-global/proj-mlops-ci-internal/${DOCKER_IMAGE_NAME}/${VERSION}/"
       desc+= "<a href='${DOCKER_IMAGE_DOWNLOAD_LINK}'>${DOCKER_IMAGE_NAME}:${VERSION}</a><br>"
    }
    desc+="Gerrit: <a href=${env.GERRIT_CHANGE_URL}>${env.GERRIT_CHANGE_URL}</a> <br>"
    currentBuild.description = desc
}


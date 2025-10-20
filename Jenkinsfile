pipeline {
  agent any
  environment {
    REGISTRY = 'registry.example.com'
    IMAGE = "${env.REGISTRY}/myorg/myservice"
    GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    BUILD_TAG = "${GIT_COMMIT_SHORT}-${env.BUILD_NUMBER}"
    DOCKER_CREDENTIALS = credentials('docker-registry-creds')
    DEPLOY_REPO_URL = 'git@github.com:myorg/myservice-deploy.git' // GitOps repo
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Pre-commit & Tests') {
      steps {
        sh 'python -V || true'
        sh 'pip install -r requirements.txt'
        sh 'pre-commit install && pre-commit run --all-files'
        sh 'pytest -q'
      }
    }
    stage('Build Image') {
      steps {
        sh "docker login ${REGISTRY} -u ${DOCKER_CREDENTIALS_USR} -p ${DOCKER_CREDENTIALS_PSW}"
        sh "docker build -t ${IMAGE}:${BUILD_TAG} ."
        sh "docker push ${IMAGE}:${BUILD_TAG}"
        sh "docker tag ${IMAGE}:${BUILD_TAG} ${IMAGE}:latest"
        sh "docker push ${IMAGE}:latest"
      }
    }
    stage('Update Helm values (GitOps)') {
      steps {
        sshagent (credentials: ['git-ssh-deploy-key']) {
          sh '''
          rm -rf deploy && git clone ${DEPLOY_REPO_URL} deploy
          cd deploy/helm/myservice
          yq -i '.image.tag = "'${BUILD_TAG}'"' values.yaml
          git config user.email "ci@myorg.local"
          git config user.name "jenkins-ci"
          git add values.yaml
          git commit -m "ci: bump myservice to ${BUILD_TAG}"
          git push origin main
          '''
        }
      }
    }
  }
}

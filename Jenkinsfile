pipeline {
    agent {
      docker {
        image: 'node:6-alpine',
        args: '-p 3000:3000'
      }
    }
    stages {
        stage('Install') {
            steps {
                sh 'npm i'
            }
        }
        stage('Generate') {
            steps {
                sh 'hexo g'
            }
        }
        stage('Deploy') {
            steps {
                sh './deploy.sh'
            }
        }
        stage('Clean') {
            steps {
                sh 'rm -rf /tmp/github/*'
            }
        }
    }
    post {
      success {
        echo 'success!'
      }
      failure {
        echo 'failed!'
      }
    }
}
pipeline {
    agent any
    stages {
        stage('Install') {
            steps {
                sh 'npm i'
                sh '''
                    hexo g

                '''
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
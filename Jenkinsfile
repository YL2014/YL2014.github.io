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
        stage('Copy') {
            steps {
                sh './deploy.sh'
            }
        }
    }
    post {
      
    }
}
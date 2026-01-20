
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                // 这里的 URL 换成你自己的 GitHub 仓库地址
                git branch: 'main', url: 'https://github.com/flybirdhere/k8s-gitops-demo.git'
            }
        }
        stage('List Files') {
            steps {
                sh 'ls -la app/'
            }
        }
    }
}

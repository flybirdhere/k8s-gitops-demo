
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["/busybox/cat"]
    tty: true
    volumeMounts:
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  - name: git-tools
    image: bitnami/git:latest
    command: ["/bin/sh", "-c", "sleep 3600"]
  volumes:
  - name: kaniko-secret
    secret:
      secretName: dockercred
      items:
      - key: .dockerconfigjson
        path: config.json
'''
        }
    }

    environment {
        // 👇 修改这里
        DOCKER_USER = "flybirdhere" 
        IMAGE_NAME = "my-k8s-app"
        REPO_URL = "github.com/flybirdhere/k8s-gitops-demo.git" 
        YAML_FILE = "my-app.yaml"
    }

    stages {
        stage('👀 检出代码') {
            steps {
                checkout scm
            }
        }
        
        stage('🐳 CI: 构建镜像') {
            steps {
                container('kaniko') {
                    script {
                        def image = "${DOCKER_USER}/${IMAGE_NAME}"
                        sh "/kaniko/executor --context `pwd`/app --dockerfile `pwd`/app/Dockerfile --destination ${image}:${BUILD_NUMBER}"
                    }
                }
            }
        }

        stage('📝 CD: 更新 Git 版本') {
            steps {
                container('git-tools') {
                    script {
                        // 使用我们在 Jenkins 界面配置的凭证
                        withCredentials([usernamePassword(credentialsId: 'github-login', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                            
                            // 1. 设置 Git 身份
                            sh 'git config --global user.email "jenkins-bot@example.com"'
                            sh 'git config --global user.name "Jenkins Bot"'
                            
                            // 2. 重新配置远程仓库 URL (带上 Token 才能 push)
                            sh "git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@${REPO_URL}"
                            
                            // 3. 确保我们在最新分支上
                            sh "git checkout main"
                            sh "git pull origin main"

                            // 4. 修改 YAML (核心魔法)
                            // 将 'image: ...:任意数字' 替换为 'image: ...:本次构建号'
                            sh """
                            sed -i 's|image: ${DOCKER_USER}/${IMAGE_NAME}:[0-9]*|image: ${DOCKER_USER}/${IMAGE_NAME}:${BUILD_NUMBER}|g' ${YAML_FILE}
                            """
                            
                            // 5. 打印看看改没改对
                            echo "=== 修改后的 YAML ==="
                            sh "grep 'image:' ${YAML_FILE}"

                            // 6. 提交并推送
                            // 注意：[skip ci] 是为了防止 Jenkins 看到新提交又自动构建，造成死循环
                            sh """
                            git add ${YAML_FILE}
                            git commit -m "Update image to version ${BUILD_NUMBER} [skip ci]"
                            git push origin main
                            """
                        }
                    }
                }
            }
        }
    }
}

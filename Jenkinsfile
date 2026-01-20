
pipeline {
    // 定义流水线在 Kubernetes 的 Pod 中运行
    agent {
        kubernetes {
            // 这里直接定义了临时 Pod 的模样
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    # 保持容器运行，等待 Jenkins 发送命令
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  volumes:
  # 把刚才创建的 Secret 挂载进来，伪装成 docker config
  - name: kaniko-secret
    secret:
      secretName: dockercred
      items:
      - key: .dockerconfigjson
        path: config.json
'''
        }
    }

    stages {
        stage('👀 检出代码') {
            steps {
                checkout scm
                echo "代码已检出"
            }
        }
        
        stage('🐳 Kaniko 构建与推送') {
            steps {
                // 指定在上面定义的 'kaniko' 容器里执行命令
                container('kaniko') {
                    script {
                        // 替换这里：你的 Docker Hub 用户名/仓库名
                        def image = "flybirdhere/my-k8s-app"
                        
                        // 使用当前 Build ID 作为 tag，方便区分
                        def tag = "${BUILD_NUMBER}"
                        
                        echo "正在构建并推送到: ${image}:${tag}"
                        
                        // Kaniko 魔法指令
                        // --context: 代码在哪 (当前目录下的 app 文件夹)
                        // --dockerfile: Dockerfile 在哪
                        // --destination: 推送到哪里
                        sh "/kaniko/executor --context `pwd`/app --dockerfile `pwd`/app/Dockerfile --destination ${image}:${tag} --destination ${image}:latest"
                    }
                }
            }
        }
    }
}

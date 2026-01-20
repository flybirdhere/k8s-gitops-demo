
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
                        // === 🕵️ 侦探模式开启 ===
                        echo "🔍 正在检查当前目录结构..."
                        sh 'pwd'          // 告诉我我在哪
                        sh 'ls -R'        // 把所有文件和子文件夹都列出来！
                        // ======================

                        // 定义变量
                        def image = "flybirdhere/my-k8s-app"  // 你的镜像名
                        def tag = "${BUILD_NUMBER}"
                        
                        // 真正的构建命令 (暂时保持不变，等侦探报告出来再调整)
                        sh "/kaniko/executor --context `pwd`/app --dockerfile `pwd`/app/Dockerfile --destination ${image}:${tag} --destination ${image}:latest"
                    }
                }
            }
        }
    }
}

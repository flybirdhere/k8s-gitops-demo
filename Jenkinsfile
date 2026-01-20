
pipeline {
    agent any
    
    stages {
        stage('👀 检出代码') {
            steps {
                // 当你配置为 "Pipeline from SCM" 时，Jenkins 会自动在这里执行 git clone
                // 所以我们只需要确认一下
                echo '正在拉取代码...'
            }
        }
        
        stage('📂 验证文件') {
            steps {
                // 列出当前目录下的所有文件，证明代码真的拉下来了
                sh 'ls -la'
                sh 'ls -la app/' // 看看 app 目录在不在
            }
        }
        
        stage('🎉 模拟构建') {
            steps {
                echo '假装正在构建 Docker 镜像...'
                // 这里以后会替换成真正的 Docker 命令
            }
        }
    }
}

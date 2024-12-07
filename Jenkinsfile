def utils 

pipeline {
    agent any
    environment{
        registryCredential = "drop-ocean-registry-cred"
        registryUrl = "registry.digitalocean.com"
        DOCKER_REGISTRY="registry.digitalocean.com/microservices-registry-uit"
        FILE_PATH = ".src/switchEnv.groovy"
        KUBECONFIG="/home/jenkins/k8s-natngoc-27-04-2003-kubeconfig.yaml"
    }
    stages { 
        stage("login to docker registry") {
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'drop-ocean-registry-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin ${registryUrl}"
                    }
                }
            }
            post {
                success {
                    echo "login DOCKER_REGISTRY successfully"
                }
            }
        }
        stage("Build docker image"){
            steps{
                script{
                    withEnv(["DOCKER_REGISTRY=${DOCKER_REGISTRY}"]){
                        sh '''
                            cd ./src
                            echo $DOCKER_REGISTRY
                            DOCKER_REGISTRY=${DOCKER_REGISTRY} docker-compose down
                            DOCKER_REGISTRY=${DOCKER_REGISTRY} docker-compose build
                            docker images
                        '''
                    }
                }
            }
            post {
                success {
                    echo "Build docker image successfully"
                }
            }
        }
        stage("Push docker image"){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'drop-ocean-registry-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin ${registryUrl}
                        cd ./src
                        DOCKER_REGISTRY=${DOCKER_REGISTRY} docker-compose push
                        '''
                    }
                }
            }
            post {
                success {
                    echo "Push docker image successfully"
                }
            }
        }
        stage("Deploy to K8s"){
            input {
                message "Choose the environment to deploy"
                parameters {
                    choice(name: 'DEPLOY_ENV', choices: ['blue', 'green'], description: 'Who should I say hello to?')
                }
            }
            steps {
                script {
                    withEnv(["KUBECONFIG=${KUBECONFIG}"]){
                        def imageName = ["basket", "catalog", "discount", "ordering", "user"]
                        def tail_prefix = "-depl"
                        def label_prefix = "-label"
                        imageName.each { name ->
                            def tmp = name + tail_prefix
                            def tmpWithLabel = name + label_prefix
                            sh "KUBECONFIG=${KUBECONFIG} kubectl delete pods -n ${DEPLOY_ENV} -l app=${tmpWithLabel}"
                            sh "kubectl rollout restart deployment/${tmp} -n ${DEPLOY_ENV}"
                        }
                    }
                }
            }
            post {
                success {
                    echo "Deploy docker image successfully"
                }
            }
        }
    }
}
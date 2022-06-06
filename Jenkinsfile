pipeline {

    agent agent1

    environment {
        CI = true
        ARTIFACTORY_ACCESS_TOKEN = credentials('artifactory-access-token')
    }

    stages {
        
        stage("build") {
            steps {
                sh 'make build'
            }
        }
        
        stage("test") {
            steps {
                sh 'make test'
            }
        }
        
        stage("dslib") {
            steps {
                sh 'make dslib'
            }
        }
        
        stage("clean") {
            steps {
                sh 'make clean'
            }
        }     

        stage("archive_artifact") {
            steps {
                archiveArtifacts(artifacts: '**/dslib.a', followSymlinks: false)
            }
        }

        stage("upload_artifact_to_artifactory") {
            steps {
                script {
                    latestTag = sh(returnStdout:  true, script: "git tag --sort=-creatordate | head -n 1").trim()
                    echo "${latestTag}"
                    }
                //sh "jfrog rt uplaod --url http://10.1.0.106:8082/artifactory/ --access-token ${ARTIFACTORY_ACCESS_TOKEN} 1.3.2/dslib.a stack/"
                sh "curl -u admin:x9VAs4GF7AJCPX4 -XPUT http://10.1.0.106:8082/artifactory/stack/${latestTag}.${env.BUILD_ID}/dslib.a -T dslib.a"
            }
        }

        stage("send email") {
            steps {
                emailext attachLog: true, body: '''$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:
                Check console output at $BUILD_URL to view the results.''', subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: 'yuvalmaimon3@gmail.com'
            }
        }
    }
}

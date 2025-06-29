pipeline {
    agent any
    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "13.222.147.15:8081"
        NEXUS_REPOSITORY = "maven-releases"
        NEXUS_CREDENTIAL_ID = "nexus-creds"
    }
    stages {
        stage("CheckOut") {
            steps {
                checkout scmGit(branches: [[name: '*/main']], 
                                extensions: [], 
                                userRemoteConfigs: [[url: 'https://github.com/Naresh240/springboot-with-jenkins-shared-library.git']])
            }
        }
        stage("Build") {
            steps {
                sh "mvn clean package"
            }
        }
        stage("Code-Coverage") {
            steps {
                withSonarQubeEnv(installationName: 'sonarqube-server', credentialsId: 'sonar-token') {
                    sh "${ tool ("sonar-scanner")}/sonar-scanner -Dsonar.projectKey=hellospringboot -Dsonar.projectName=hellospringboot -Dsonar.sourceEncoding=UTF-8 -Dsonar.sources=src"
                }
            }
        }
        stage("Publish to Nexus Repository Manager") {
            steps {
                script{
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "* File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                    } else {
                        error "* File: ${artifactPath}, could not be found";
                    }
                }
            }
        }
        stage("Docker_Image_Build") {
            steps {
                sh "docker build -t springboothello:v1 ."
            }
        }
        stage("Scan_Docker_Image") {
            steps {
                sh "trivy -d image springboothello:v1"
            }
        }
        stage("Push_Docker_Registry") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh '''
                        docker tag springboothello:v1 naresh240/springboothello:v1
                        docker login -u ${username} -p ${password}
                        docker push naresh240/springboothello:v1
                    '''
                }
            }
        }
    }
}

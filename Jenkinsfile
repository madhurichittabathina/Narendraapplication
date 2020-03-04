def private_ip = ''
 pipeline {
 
   agent {
                        label "master"
                                       }
    tools {
        maven 'Maven'
    }
stages {
 stage('Preparation') {
     steps {
// for display purposes
//test only
      // Get some code from a GitHub repository
      git 'https://github.com/RamachandraAnnadi/WhatsupDOC.git'
      // Get the Maven tool.
 // ** NOTE: This 'M3' Maven tool must be configured
     // **       in the global configuration.
     }
   }
   stage('Build') {
       steps {
       // Run the maven build
      //if (isUnix()) {
         sh 'mvn -Dmaven.test.failure.ignore=true install'
      //}
      //else {
      //   bat(/"${mvnHome}\bin\mvn" -Dmaven.test.failure.ignore clean compile/)
       }
//}
   }
  stage('Unit Test Results') {
      steps {
      junit '**/target/surefire-reports/TEST-*.xml'
      }
 }
 stage('Sonarqube') {
    environment {
        scannerHome = tool 'sonarqube'
    }
    steps {
        withSonarQubeEnv('sonarqube') {
            sh "${scannerHome}/bin/sonar-scanner"
        }
        timeout(time: 10, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
     stage('jfrog artifactory') {
  steps { 
   rtUpload (
    serverId: 'jfrog-artifactory-servers',
    spec: '''{
          "files": [
            {
              "pattern": "/var/lib/jenkins/workspace/whatsupDOC/target/cangkitsolutions.war",
              "target": "whatsupdoc-repo-crm-files"
            }
         ]
    }''',
 
    buildName: 'whatsupdoc',
      )
     }
    }
    stage('Build and Push Docker Image') {
      steps {
        sh label: '', script: '''docker build -t whatsupdoc-image:$BUILD_NUMBER .
                                 docker tag whatsupdoc-image:$BUILD_NUMBER docker.io/ramachandraannadi/whatsupdoc-image:$BUILD_NUMBER
                                 sudo docker push docker.io/ramachandraannadi/whatsupdoc-image:$BUILD_NUMBER'''
      }
 }
stage('install_deps') {
steps {
sh label: '', script: 'sudo yum install wget zip python-pip -y'
sh "cd /tmp"
sh "curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.17/terraform_0.12.17_linux_amd64.zip"
sh "unzip terraform.zip"
sh "sudo mv terraform /usr/bin"
}
}
stage('init_and_plan') {
steps {
sh "sudo terraform init /var/lib/jenkins/workspace"
sh "sudo terraform plan /var/lib/jenkins/workspace"
}
}
stage('apply_changes') {
steps {
sh "sudo terraform apply -auto-approve /var/lib/jenkins/workspace"
sh "terraform output > private_ip"
}
}
stage ('login to aws') {
steps {
script { 
 //   private_ip = sh(script: "cat /var/lib/jenkins/workspace/WhatsupDOC-production/private_ip | head -2 |tail -1|tr -d {' '}|tr -d {','}",
  //returnStdout: true,
  //)
   //private_ip = sh(script: "cat /var/lib/jenkins/workspace/WhatsupDOC-production/private_ip | head -2 |tail -1|tr -d {' '}|tr -d {','}|tr -d {'\"'}|tr -d '\r'")
   private_ip = sh(script: "cat /var/lib/jenkins/workspace/WhatsupDOC-production/private_ip | head -2 |tail -1|tr -d {' '}|tr -d {','}|tr -d {'\"'}|tr -d '\r'", returnStdout: true,).trim()
   //private_ip = sh(script: "echo ${private_ip}", returnStdout: true,).trim()
     }

//sh 'ssh 'cat private_ip | awk {'NR==2'} | tr -d {' '} | tr -d {'"'} |tr -d ',' ''
sh "cp /var/lib/jenkins/docker-deploy.sh ."
sh "ls"
//sh "ssh jenkins@'cat private_ip | awk {'NR==2'} | tr -d {' '} | tr -d {'"'} |tr -d ',' 'bash -s' < docker-deploy.sh $BUILD_NUMBER"
sh "ssh -T jenkins@${private_ip} 'bash -s' < docker-deploy.sh $BUILD_NUMBER"

    }
}
}
post {
        success {
            archiveArtifacts 'WhatsupDOC-web/target/*.war'
        }
        //failure {
          //  mail to:"ramachandra.annadi@qentelli.com", subject:"FAILURE: ${currentBuild.fullDisplayName}", body: "Build failed"
        //}
}
}

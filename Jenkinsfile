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
               sh 'mvn -Dmaven.test.failure.ignore=true install'
      }
    
     stage('sonar and unit test parallel running') {	
     parallel {
   stage('Unit Tests') {
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
     sh "echo ${scannerhome}"
            sh "${scannerHome}/bin/sonar-scanner"
          }
            timeout(time: 30, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
           }
    
    }
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
              "pattern": "/var/lib/jenkins/workspace/WhatsupDOC/build/libs/WhatsupDOC.jar",
              "target": "WhatsupDOC-repo-crm-files"
            }
         ]
    }''',
 
    // Optional - Associate the uploaded files with the following custom build name and build number,
    // as build artifacts.
    // If not set, the files will be associated with the default build name and build number (i.e the
    // the Jenkins job name and number).
    buildName: 'WhatsupDOC',
      )
     }
    }
        stage('Build and Push Docker Image') {
        steps {
          sh label: '', script: '''docker build -t WhatsupDOC-image:$BUILD_NUMBER .
                                 docker tag WhatsupDOC-image:$BUILD_NUMBER docker.io/ramachandraannadi/WhatsupDOC-image:$BUILD_NUMBER
                                 sudo docker push docker.io/ramachandraannadi/WhatsupDOC-image:$BUILD_NUMBER'''
            }
       }
       
    //stage('install_deps') {
        //steps {
         //sh label: '', script: 'sudo yum install wget zip python-pip -y'
         //sh "cd /tmp"
         //sh "curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.17/terraform_0.12.17_linux_amd64.zip"
         //sh "unzip terraform.zip"
         //sh "sudo mv terraform /usr/bin"
            //}
            //}
       stage('Terraform_init_and_plan') {
        steps {
         sh "sudo terraform init /var/lib/jenkins/workspace"
         sh "sudo terraform plan /var/lib/jenkins/workspace"
            }
            }
       stage('Terraform_apply_changes') {
        steps {
         sh "sudo terraform apply -auto-approve /var/lib/jenkins/workspace"
         sh "terraform output > /tmp/private_ip"
            }
            }
      stage ("preparing for EC2 creation") {
       steps { 
        //sh "def time = params.SLEEP_TIME_IN_SECONDS"
        //sh "echo "Waiting ${SLEEP_TIME_IN_SECONDS} seconds for deployment to complete prior starting smoke testing""
            sleep(time:90,unit:"SECONDS")
}
    }
      stage ('login to aws') {
        steps {
         script { 
 
          private_ip = sh(script: "cat /tmp/private_ip | head -2 |tail -1|tr -d {' '}|tr -d {','}|tr -d {'\"'}|tr -d '\r'", returnStdout: true,).trim()
   
     }


         sh "cp /var/lib/jenkins/docker-deploy.sh ."
         sh "ls"

         sh "ssh -o StrictHostKeyChecking=no jenkins@${private_ip} 'bash -s' < docker-deploy.sh $BUILD_NUMBER"

    }
}
}   
} 
}

FROM jenkins/jenkins:2.299
RUN jenkins-plugin-cli --plugins git forticwp-cicd:0.9.6



def label = 'ci-runner'
def npmToken = <PROJECT_NPM_TOKEN>

podTemplate(
    label: label,
    containers: [
        containerTemplate(
            name: 'jnlp',
            image: <YOUR_IMAGE>,
            workingDir: '/home/jenkins',
            resourceRequestCpu: '500m',
            resourceLimitCpu: '4000m',
            resourceRequestMemory: '4Gi',
            resourceLimitMemory: '8Gi',
            envVars: [
                envVar(key: 'NPM_TOKEN', value: npmToken)
            ]
        )
    ],
    volumes: [
        hostPathVolume(hostPath: '/usr/bin/docker', mountPath: '/usr/bin/docker'),
        hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
    ]
) {
    node(label) {

        def myRepo = checkout scm

        sh('git config user.name <YOUR_USERNAME>)
        sh('git config user.email <YOUR_EMAIL>)

        stage('merge with develop) {
            sh('git merge origin/master --no-commit')
        }

        stage('install') {
            sh('yarn install --non-interactive --pure-lockfile')
        }

         stage('test') {
            sh('yarn test')
            sh('yarn build')
        }
    }
}

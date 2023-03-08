pipeline
{
    agent
    {
        label 'docker-node'
    }
    stages
    {
        stage('Clone the project') 
        {
            steps 
            {
                sh '''
                    sudo mkdir /projects || true
                    sudo chown -R jenkins:jenkins /projects
                    cd /projects
                    if [ -d /projects/gitea-bgapp ]; then 
                      cd /projects/gitea-bgapp
                      git pull http://192.168.11.102:3000/vagrant/gitea-bgapp.git
                    else
                      git clone http://192.168.11.102:3000/vagrant/gitea-bgapp.git
                    fi
                    '''
            }
        }
        stage('Start docker compose')
        {
            steps
            {
                sh '''
                    docker compose -f /projects/gitea-bgapp/docker-deploy-compose.yaml down
                    docker compose -f /projects/gitea-bgapp/docker-deploy-compose.yaml up -d
                '''
            }
        }
        stage('Wait Web server start')
        {
            steps
            {
                sh '''
                    sleep 10
                '''
            }
        }
        stage('Test')
        {
            steps
            {
                script
                {
                    sh'''
                        echo 'Test #1 - Reachability'
                        echo $(curl --write-out "%{http_code}" --silent --output /dev/null http://192.168.11.102) | grep 200
                    
                        echo 'Test #2 - Sofia Population Appears'
                        curl --silent http://192.168.11.102 | grep 1248452
                    
                        echo 'Test #3 - Looking for city Русе'
                        curl --silent http://192.168.11.102 | grep 'Русе'
                    '''
                }
            }
        }
    }
}
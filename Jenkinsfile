import groovy.transform.Field
@Field def g_repo_list = [[],[],[]]
@Field def git_path = "git@github.com:leopowerxp/"

def refileline(String job)
{
    def list = [[],[],[]]
    // File file = new File("${WORKSPACE}/${job}")
    def file = readFile "${WORKSPACE}/${job}"
    def lines = file.readLines()
    def count = 0
    lines.each { String line ->
        list[count%3].add(line)
        count++
    }
    return list
}

def readRepositories(){
    g_repo_list=refileline("build_list.txt")
    echo "g_repo_list"
    print g_repo_list
}

def chechout(String job)
{
    def branch = "origin/develop"
    checkout([$class: 'GitSCM',
        // branches: [[name: '*/develop']],
        branches: [[name: "${branch}"]],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'RelativeTargetDirectory',
        relativeTargetDir: "${job}"]],
        submoduleCfg: [],
        userRemoteConfigs: [[url: git_path + "${job}.git"]]])

}

def deployAllJobs(JobList)
{
    def length = JobList.size()
    def branch = "origin/develop"
    print length
    echo "WORKSPACE is ${WORKSPACE}"
    sh "pwd"
    // sh "sh ${WORKSPACE}/root.sh"
    for (i = 0; i <length; i++) {
        chechout(JobList[i])
        // sh "cd ${JobList[i]} ; npm install serverless-python-requirements ;  sls deploy"
        // sh "cd ${WORKSPACE}/${JobList[i]} && ls"
        sh "PARENT_WORKSPACE=${WORKSPACE}/${JobList[i]}"
        sh "PARENT_JOB_NAME=${JobList[i]}"
        sh "sh build.sh ${WORKSPACE} ${JobList[i]} ${branch}"
    }
}

//this function can't use. waiting for fix.
def getTasks(all_repo_list)
{
    def tasks = []
    all_repo_list.each { repo_list, index ->
        if (reoplist.size() > 0){
            tasks["Task $index"] = {
                stage ("Task $index"){
                    steps{
                        echo "Task $index"
                        echo "$repo_list"
                        deployAllJobs($repo_list)
                    }
                }
            }
        }
    }
    return tasks
}

pipeline {
    agent {label "master"}
    stages {
        stage("read buil job list") {
            steps {
                readRepositories()
            }
        }
        stage("deploy") {
            parallel{
                stage('Branch A') {
                    steps {
                        echo "On Branch A"
                        deployAllJobs(g_repo_list[0])
                    }
                }
                stage('Branch B') {
                    steps {
                        echo "On Branch B"
                        deployAllJobs(g_repo_list[1])
                    }
                }
                stage('Branch C') {
                    steps {
                        echo "On Branch C"
                        deployAllJobs(g_repo_list[2])
                    }
                }
            }
        }
    }
}

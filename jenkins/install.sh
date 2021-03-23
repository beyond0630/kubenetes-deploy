function conf() {
    # sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    sudo rpm --import jenkins.io.key
}

function install() {
    sudo yum install jenkins -y
    systemctl daemon-reload
}

function firewalld_conf() {
    firewall-cmd --zone=public --add-service=http --permanent
    firewall-cmd --reload
}

function start() {
    sudo systemctl start jenkins
    sudo systemctl status jenkins
}

function echo_pw() {
    cat /var/lib/jenkins/secrets/initialAdminPassword
}


conf
install
firewalld_conf
start
echo_pw
function mkdir() {
    mkdir -p /data/coredns/
}

function conf() {
    cat >>/data/coredns/Corefile <<EOF
.:53 {
    hosts {
        fallthrough
    }
    forward . 202.96.134.133 202.96.128.86
    errors
    cache
}
EOF
}

function hosts() {
    cat >>/data/coredns/hosts <<EOF
    192.168.110.187 jenkins.lucifer.io
EOF
}

function run() {
    docker run -d \
        --restart always \
        --name coredns \
        -p 53:53/tcp \
        -p 53:53/udp \
        -v /etc/timezone:/etc/timezone:ro \
        -v /etc/localtime:/etc/localtime:ro \
        -v /data/coredns/hosts:/etc/hosts:ro \
        -v /data/coredns/Corefile:/Corefile:ro \
        coredns/coredns
}

mkdir
conf
hosts
run

shopt -s globstar promptvars

export PS1='$(printf "%$((COLUMNS-1))s\r")\[\033[36m\][\D{%F %T}] \[\033[32m\][\u@\h \W]\n\[\033[m\]\$ '


export EDITOR=emacsclient
export PATH='/usr/local/bin:/usr/local/sbin:'$PATH
export TERM=xterm-256color

################################################################################

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

if [ -f /usr/local/share/bash-completion/bash_completion ]; then
    . /usr/local/share/bash-completion/bash_completion
fi

################################################################################

archey --color --offline --packager

eval `keychain --eval --agents ssh --inherit any id_rsa`

alias sprunge="curl -F 'sprunge=<-' http://sprunge.us"

################################################################################

export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_TOOLS_JAR=$(/usr/libexec/java_home)'/lib/tools.jar'

# Because all Flight Recorder profiles need to live inside JAVA_HOME. Apparently.
if [ ! -f $JAVA_HOME'/jre/lib/jfr/jfr.jfc' ] && [ -f ~/.lein/jfr.jfc ]; then
    echo "Copying custom flight recorder profile to $JAVA_HOME..."
    sudo cp -f ~/.lein/jfr.jfc $JAVA_HOME'/jre/lib/jfr/'
fi

################################################################################

export SSH_USER=michael

ov() {
    cd ~/clojure/social-superstore/infrastructure/
    ENV=$1 ./deploy/overview
}

wov() {
    cd ~/clojure/social-superstore/infrastructure/
    watch ENV=$1 ./deploy/overview
}

neo() {
    cd ~/clojure/social-superstore/infrastructure/
    ./k8s/cluster/create-tunnel-all
}

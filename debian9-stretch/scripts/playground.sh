# Adjust root filesystem

export DEBIAN_FRONTEND=noninteractive

# GOLANG

GOLANG_VERSION="1.10.3"

PKG_FILE="go${GOLANG_VERSION}.linux-amd64.tar.gz"
INSTALL_PATH="/usr/local/go"

if [ ! -d "$INSTALL_PATH" ]; then

	echo "Downloading $PKG_FILE ..."

	curl -s https://storage.googleapis.com/golang/$PKG_FILE -o /tmp/go.tar.gz
		
	if [ $? -ne 0 ]; then
			echo "Download failed! Exiting."
			#~ exit 1
	else
		
		echo "Installing Golang $GOLANG_VERSION ..."

		sudo tar -C "/tmp" -xzf /tmp/go.tar.gz
		sudo mv "/tmp/go" "$INSTALL_PATH"

		touch "/etc/bash.bashrc"
		{
				echo '# GoLang'
				echo "export GOROOT=$INSTALL_PATH"
				echo 'export PATH=$PATH:$GOROOT/bin'
		} >> "/etc/bash.bashrc"

		rm -f /tmp/go.tar.gz
	fi
	
	export GOROOT=$INSTALL_PATH
	export PATH=$PATH:$GOROOT/bin
	
fi

# CONSUL
which consul &>/dev/null || {
    echo "Determining Consul version to install ..."

    CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
    if [ -z "$CONSUL_VERSION" ]; then
        CONSUL_VERSION=$(curl -s "${CHECKPOINT_URL}"/consul | jq .current_version | tr -d '"')
    fi
	
	pushd /tmp/
		
	curl -s https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip
		
	if [ $? -ne 0 ]; then
		echo "Download failed! Exiting."
		#~ exit 1
	else
		    
    echo "Installing Consul version ${CONSUL_VERSION} ..."
    unzip consul.zip
    sudo chmod +x consul
    sudo mv consul /usr/local/bin/consul

    # https://www.consul.io/intro/getting-started/services.html
    sudo mkdir /etc/consul.d
    sudo chmod a+w /etc/consul.d

    echo "Recovering some space ..."
    sudo rm -rf /tmp/consul.zip
	fi
		
}

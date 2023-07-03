# The purpose of this script is to be the main extrypoint for the docker image setup
# It includes any arguments or commands required for using `docker`, `docker build`, `docker run`, etc.

# Install vscode-insiders
# Check if vscode-insiders is installed
if ! command -v code-insiders &> /dev/null
then
    echo "VSCode Insiders not found. Installing..."
    # Download the package
    curl -L --output vscode-insiders.deb "https://code.visualstudio.com/sha/download?build=insider&os=linux-deb-x64"
    # Install the package
    apt install ./vscode-insiders.deb -y
    # Remove the package file
    rm ./vscode-insiders.deb
else
    echo "VSCode Insiders is already installed"
fi


# Set sensitive information from user as environment variables
echo "Enter OpenAI key (or leave blank): "
read OPENAI_KEY

DATETIME_KEY=$(date +%y-%m-%d_%H.%M)
echo 'Setting dev_container image tag to datetime key: '
echo $DATETIME_KEY
docker-compose build


if [ "$(docker ps -a -q -f name=dev_container)" ]; then
    echo -e "Container \"dev_container\" exists. Removing..."
    docker container rm dev_container
else
    echo -e "Container \"dev_container\" does not exist."
fi
docker-compose up
docker run -it --name dev_container --volume $HOME/Documents:/root/documents/mount butterlyn/dev_container:$DATETIME_KEY


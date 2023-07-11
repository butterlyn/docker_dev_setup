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

# build dev container
docker-compose build --build-arg OPENAI_KEY=$OPENAI_KEY --progress=plain .

# run dev container
docker-compose up


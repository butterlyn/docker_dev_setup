# The purpose of this script is to be the main extrypoint for the docker image setup
# It includes any arguments or commands required for using `docker`, `docker build`, `docker run`, etc.

# Set sensitive information from user as environment variables
echo "Enter OpenAI key (or leave blank): "
read OPENAI_KEY

DATETIME_KEY=$(date +%y-%m-%d_%H.%M)
echo 'Setting dev_container image tag to datetime key: '
echo $DATETIME_KEY

# build dev container
sudo docker build --tag dev_container:$DATETIME_KEY --pull --build-arg OPENAI_KEY=$OPENAI_KEY --progress=plain .

# run dev container
docker run -it --name dev_container --volume $HOME/Documents:/root/documents/mount dev_container:$DATETIME_KEY

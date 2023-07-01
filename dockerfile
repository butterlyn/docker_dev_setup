# SET BASE IMAGE ~~~~~~~~~~~~~~~
FROM	continuumio/miniconda3

# DEFINE TEMPORARY ARGUMENTS FOR FOLDER PATHS ~~~~~~~~~~~~~~~~~
ENV	DATA_PATH=/root/temp/data/
ENV	SCRIPT_PATH=/root/temp/scripts/

# PERMANENT ENV VARIABLES ~~~~~~~~~~~~~~~~~
# pass in arguments from local machine using `docker build --build-arg <VAR1>=<value1> --build-arg <VAR2>=<value2>` for sensitive information
ARG	OPENAI_KEY
ENV	OPENAI_KEY=$OPENAI_KEY

ENV	GITHUB_USERNAME=butterlyn

# SET WORKING DIRECTORY ~~~~~~~~~~~~~~~~~
WORKDIR /root

# CREATE DIRECTORIES ~~~~~~~~~~~~~~~~~
RUN     mkdir -p ${DATA_PATH} ${SCRIPT_PATH}

# COPY DATA FILES ~~~~~~~~~~~~~~~~~
COPY    data/ ${DATA_PATH}
COPY    scripts/ ${SCRIPT_PATH}

# change permission to set all scripts as executables
RUN     chmod +x ${SCRIPT_PATH}/*

# INSTALL APT PACKAGES ~~~~~~~~~~~~~~~~~
RUN	apt-get update && apt-get upgrade -y && \
	xargs -a ${DATA_PATH}/apt-packages.txt apt-get install -y && \
	rm -rf /var/lib/apt/lists/* apt-packages.txt

# ADD CARGO TO PATH VARIABLES ~~~~~~~~~~~~~~~~~
# cargo for Rust packages
ENV	PATH="/root/.cargo/bin:$PATH"

# MAKE DIRECTORIES ~~~~~~~~~~~~~~~~~
RUN	mkdir /root/documents && \
	mkdir /root/documents/repos && \
	mkdir /root/documents/mount && \
	mkdir /root/downloads

# MOUNT POINTS ~~~~~~~~~~~~~~~~~
# declaring mount point does nothing. Reminder to use -v flag when running container
VOLUME	/root/documents/mount

# RUN SCRIPTS ~~~~~~~~~~~~~~~~~
#WORKDIR	/root/documents
#RUN	${SCRIPT_PATH}/run_all_scripts.sh
#WORKDIR	/root

WORKDIR	/root/documents
RUN	${SCRIPT_PATH}/install_gh_cli.sh
#RUN	${SCRIPT_PATH}/clone_all_repos.sh
WORKDIR	/root

# # VSCODE INSIDERS SETUP ~~~~~~~~~~~~~~~~~

# # install vscode insiders

# WORKDIR /root

# RUN curl -L https://code.visualstudio.com/sha/download?build=insider&os=linux-deb-×64 -o vscode.deb
# RUN apt install ./vscode.deb -y
# RUN rm vscode.deb

# CONDA SETUP ~~~~~~~~~~~~~~~~~

# configure conda channels
#RUN	conda config --add channels conda-forge

# update conda base using .yml file on local machine
#RUN	conda env update --file /root/temp/data/environment_base.yml -n base --prune && \
#	conda clean -afy

RUN	conda install conda -y && \
	conda env create --file ${DATA_PATH}/environment_NB_base.yml --name NB_base && \
	conda clean -afy

# # create new coda environment using environment.yml on local machine
# COPY data/environment.yml
# RUN conda env create -f environment.yml
# # set conda base as default environment in bash
# # https://pythonspeed.com/articles/activate-conda-dockerfile/

# run subsequent commands in conda base environment
# SHELL ["conda", "run", "-n", "base", "/bin/bash", "-c"]
# RUN conda install <package> -y
# RUN conda clean -afy

# END SETUP ~~~~~~~~~~~~~~~~~
RUN	rm -r /root/temp
# unset temporary ENV variables (which were set so setup .sh files could access them)
ENV	DATA_PATH=
ENV	SCRIPT_PATH=
WORKDIR /root/documents

# open as a dev remote in vscode-insiders
# CMD ["code-insiders", "."]

# open as bach terminal
# CMD ["bash"]

# Script that is run every time a (alread built) container is run
# ENTRYPOINT ["conda activate"]
# Conda environment can be overridded when running running container `docker run -ir <image_name> <conda environment name>
# CMD ["base"]

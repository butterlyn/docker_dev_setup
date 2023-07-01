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

# VSCODE INSIDERS SETUP ~~~~~~~~~~~~~~~~~

# install vscode insiders

#RUN	curl -L --output vscode-insiders.deb "https://code.visualstudio.com/sha/download?build=insider&os=linux-deb-x64" && \
#	apt install ./vscode-insiders.deb -y && \
#	rm ./vscode-insiders.deb

# CONDA SETUP ~~~~~~~~~~~~~~~~~

RUN	conda install conda -y && \
	conda env create --file ${DATA_PATH}/environment_NB_base.yml --name NB_base && \
	conda clean -afy

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
#ENTRYPOINT ["code-insiders", "--no-sandbox", "."]

# open as bach terminal
CMD ["bash"]

# Acitvate conda environment
#ENTRYPOINT	["conda activate NB_base"]

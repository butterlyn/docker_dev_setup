# SET BASE IMAGE ~~~~~~~~~~~~~~~
FROM	condaforge/mambaforge:4.10.1-5

# DEFINE TEMPORARY ARGUMENTS FOR FOLDER PATHS ~~~~~~~~~~~~~~~~~
ENV	DATA_PATH=/root/temp/data/
ENV	SCRIPT_PATH=/root/temp/scripts/

# PERMANENT ENV VARIABLES ~~~~~~~~~~~~~~~~~
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
ENV	PATH="/root/.cargo/bin:$PATH"

# MAKE DIRECTORIES ~~~~~~~~~~~~~~~~~
RUN	mkdir /root/documents && \
	mkdir /root/documents/repos && \
	mkdir /root/documents/mount && \
	mkdir /root/downloads

# MOUNT POINTS ~~~~~~~~~~~~~~~~~
VOLUME	/root/documents/mount

# RUN SCRIPTS ~~~~~~~~~~~~~~~~~
WORKDIR	/root/documents
RUN	${SCRIPT_PATH}/install_gh_cli.sh
WORKDIR	/root

# CONDA SETUP ~~~~~~~~~~~~~~~~~
RUN	conda install conda -y && \
	conda env create --file ${DATA_PATH}/environment_NB_base.yml --name NB_base && \
	conda clean -afy

# END SETUP ~~~~~~~~~~~~~~~~~
RUN	rm -r /root/temp
ENV	DATA_PATH=
ENV	SCRIPT_PATH=
WORKDIR /root/documents

# open as bach terminal
CMD ["bash"]

# Acitvate conda environment
ENTRYPOINT	["conda", "run", "-n", "NB_base", "/bin/bash", "-c"]


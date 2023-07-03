FROM	mambaorg/micromamba:0.15.3

ENV	DATA_PATH=/root/temp/data/
ENV	SCRIPT_PATH=/root/temp/scripts/

ARG	OPENAI_KEY
ENV	OPENAI_KEY=$OPENAI_KEY

ENV	GITHUB_USERNAME=butterlyn

WORKDIR /root

RUN     mkdir -p ${DATA_PATH} ${SCRIPT_PATH}

COPY    data/ ${DATA_PATH}
COPY    scripts/ ${SCRIPT_PATH}

RUN     chmod +x ${SCRIPT_PATH}/*

RUN	apt-get update && apt-get upgrade -y && \
	xargs -a ${DATA_PATH}/apt-packages.txt apt-get install -y && \
	rm -rf /var/lib/apt/lists/* apt-packages.txt

ENV	PATH="/root/.cargo/bin:$PATH"

RUN	mkdir /root/documents && \
	mkdir /root/documents/repos && \
	mkdir /root/documents/mount && \
	mkdir /root/downloads

VOLUME	/root/documents/mount

WORKDIR	/root/documents
RUN	${SCRIPT_PATH}/install_gh_cli.sh
WORKDIR	/root

RUN	conda install conda -y && \
	conda env create --file ${DATA_PATH}/environment_NB_base.yml --name NB_base && \
	conda clean -afy

RUN	rm -r /root/temp
ENV	DATA_PATH=
ENV	SCRIPT_PATH=
WORKDIR /root/documents

ENTRYPOINT ["conda", "run", "-n", "NB_base", "/bin/bash", "-c"]
#ENTRYPOINT	["conda activate NB_base"]


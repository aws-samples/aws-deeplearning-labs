FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y

RUN apt-get update && apt-get install -y \
    python3-pip \
    awscli	

RUN pip install --no-cache-dir -U  "awscli>1.27,<2" 
RUN pip install torch-model-archiver

WORKDIR /app

COPY model.py model.py
COPY model_handler.py model_handler.py
COPY config.properties config.properties
COPY submit.sh submit.sh

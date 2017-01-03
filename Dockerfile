FROM debian:jessie

RUN apt-get update && \
    apt-get install -y pandoc pandoc-citeproc nginx make

COPY . /srv/bheesham.com/
WORKDIR /srv/bheesham.com

RUN make

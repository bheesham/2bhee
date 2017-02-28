FROM debian:jessie

COPY . /srv/bheesham.com/
WORKDIR /srv/bheesham.com

RUN apt-get update && \
    apt-get install -y pandoc pandoc-citeproc nginx make

RUN make

EXPOSE 80

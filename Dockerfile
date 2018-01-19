FROM debian:jessie

RUN apt update && \
    apt install -y make pandoc pandoc-citeproc texlive

WORKDIR /usr/local/src/bheesham.com

ADD . .

RUN make

EXPOSE 80

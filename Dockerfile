FROM ubuntu:20.04




RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential wget git

#nim
RUN mkdir /nim_bild
WORKDIR /nim_bild
RUN wget https://nim-lang.org/download/nim-1.4.2.tar.xz
RUN tar -Jxvf nim-1.4.2.tar.xz
WORKDIR /nim_bild/nim-1.4.2
RUN sh build.sh && \
  bin/nim c koch && \
  ./koch boot -d:release && \
  ./koch tools

ENV PATH  /nim_bild/nim-1.4.2/bin:$PATH

RUN nimble install jester -y

RUN mkdir /prj && mkdir -p /prj/ImagCat

WORKDIR /prj/ImagCat
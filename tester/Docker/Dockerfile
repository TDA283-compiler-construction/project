FROM ubuntu:bionic

RUN apt-get update && apt-get install -y \
    build-essential \
    default-jdk \
    bnfc \
    nasm \
    llvm \
    clang \
    emacs \
    vim \
    tmux \
    curl \
    git \
    python3
RUN curl -sSL https://get.haskellstack.org/ | sh

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user

RUN git clone https://github.com/myreen/tda283

RUN mkdir -p classpath/JLex/JLex
RUN cd classpath/JLex/JLex && \
    curl -O https://www.cs.princeton.edu/~appel/modern/java/JLex/current/Main.java && \
    javac Main.java

RUN mkdir -p classpath/CUP
RUN cd classpath/CUP && \
    curl -O http://www2.cs.tum.edu/projects/cup/releases/java-cup-11a-runtime.jar && \
    curl -O http://www2.cs.tum.edu/projects/cup/releases/java-cup-11a.jar

RUN mkdir -p subm

WORKDIR /home/user/tda283/tester

ENV PATH="/home/user/.local/bin:${PATH}"
ENV CLASSPATH="/home/user/classpath/JLex:${CLASSPATH}"
ENV CLASSPATH="/home/user/classpath/CUP/java-cup-11a-runtime.jar:${CLASSPATH}"
ENV CLASSPATH="/home/user/classpath/CUP/java-cup-11a.jar:${CLASSPATH}"

RUN stack install \
    array \
    base \
    containers \
    filepath \
    microlens-platform \
    mtl \
    process

CMD /bin/bash

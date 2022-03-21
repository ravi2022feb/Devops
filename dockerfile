IMAGE ubuntu
MAINTAINER odharmapuri
RUN apt-get update
RUN apt-get install git -y
RUN apt-get install default-jdk -y
CMD "date"

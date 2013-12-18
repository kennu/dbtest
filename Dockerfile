FROM ubuntu
ENV HOME /root
EXPOSE 9000
RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get update -q
RUN apt-get install -q -y python-software-properties python g++ make nginx git build-essential
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update -q
RUN apt-get install -q -y nodejs
RUN apt-get install -q -y libpq-dev libmysqlclient-dev
# Install global copies for faster install
RUN npm install -g express mysql pg mongodb nodemon microtime
ADD . /app
RUN rm -rf /app/node_modules
RUN cd /app; npm install
CMD cd /app; npm install; npm start

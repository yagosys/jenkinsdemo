FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \ 
    apt-get install -y --no-install-recommends tzdata
RUN apt-get update && \
  apt-get -y install apache2 
RUN apt-get update && \
  apt-get -y install python3-sklearn 

RUN echo 'Hello  world' > /var/www/html/index.html

RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh && \
    echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
    echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh && \
    chmod 755 /root/run_apache.sh


EXPOSE 80

CMD /root/run_apache.sh

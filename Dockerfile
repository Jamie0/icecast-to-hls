FROM ubuntu:20.04

# Based on the Dockerfile for moul/icecast by Manfred Touron <m@42.am>, and Stéphane Lepin <stephane.lepin@gmail.com>
MAINTAINER Jamie Woods <jamie.woods@insanityradio.com>

ENV DEBIAN_FRONTEND noninteractive
ENV IC_VERSION "2.4.0-kh15"

RUN apt-get -qq -y update && \
	apt-get -qq -y install build-essential \
		wget curl libxml2-dev libxslt1-dev \
		libogg-dev libvorbis-dev libtheora-dev libflac-dev \
		libspeex-dev python-setuptools libcurl4-openssl-dev

RUN wget "https://github.com/karlheyes/icecast-kh/archive/icecast-$IC_VERSION.tar.gz" -O- | tar zxvf - && \
	cd "icecast-kh-icecast-$IC_VERSION" && \
	./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
	make && make install && useradd icecast && \
	chown -R icecast /etc/icecast.xml && \
	sed -i "s/<sources>[^<]*<\/sources>/<sources>999<\/sources>/g" /etc/icecast.xml

RUN apt-get install -y ffmpeg 
RUN wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - && echo "deb http://openresty.org/package/ubuntu focal main" \
    | tee /etc/apt/sources.list.d/openresty.list && apt-get update && apt-get -y install openresty


ADD ./start.sh /start.sh
ADD ./etc /etc
COPY ./connect.sh ./disconnect.sh /
COPY ./packager /bin/packager

RUN chmod +x /start.sh /bin/packager /connect.sh /disconnect.sh

RUN mkdir /usr/share/icecast/web/stream
RUN chown icecast: /usr/share/icecast/web/stream

CMD ["/start.sh"]
EXPOSE 8000
VOLUME ["/config", "/var/log/icecast", "/usr/share/icecast/web/stream"]

FROM alpine:3.14

WORKDIR /

RUN apk --no-cache add ffmpeg tzdata bash \
&& apk --no-cache add --virtual=builddeps autoconf automake libtool git ffmpeg-dev wget tar build-base \
&& wget http://prdownloads.sourceforge.net/argtable/argtable2-13.tar.gz \
&& tar xzf argtable2-13.tar.gz \
&& cd argtable2-13/ && ./configure && make && make install \
&& git clone git://github.com/erikkaashoek/Comskip.git /tmp/comskip \
&& cd /tmp/comskip && ./autogen.sh && ./configure && make && make install \
&& mkdir -p /config && touch /config/comskip.ini \
&& apk del builddeps \
&& cd ~ \
&& rm -rf /var/cache/apk/* /tmp/* /tmp/.[!.]* 

COPY /comchap /usr/local/bin/comchap
COPY /comcut /usr/local/bin/comcut


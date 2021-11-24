FROM alpine:3.14

RUN apk --no-cache add ffmpeg tzdata bash \
&& apk --no-cache add --virtual=builddeps autoconf automake libtool git ffmpeg-dev wget tar build-base \
&& wget http://prdownloads.sourceforge.net/argtable/argtable2-13.tar.gz \
&& tar xzf argtable2-13.tar.gz \
&& cd argtable2-13/ && ./configure && make && make install \
&& git clone git://github.com/erikkaashoek/Comskip.git /tmp/comskip \
&& mkdir -p /config && touch /config/comskip.ini \
&& cd /tmp/comskip && ./autogen.sh && ./configure && make && make install \
&& git clone https://github.com/BrettSheleski/comchap.git /tmp/comchap \
&& cd /tmp/comchap && make && make install \
&& apk del builddeps \
&& cd ~ \
&& rm -rf /var/cache/apk/* /tmp/* /tmp/.[!.]* 

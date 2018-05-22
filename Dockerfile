FROM node:8
MAINTAINER Yeung Yiu Hung <hkclex@gmail.com>

# Install ClamAV and supervisord
# Debian Base to use
ENV DEBIAN_VERSION jessie

# Install ClamAV and supervisor
RUN echo "deb http://http.debian.net/debian/ $DEBIAN_VERSION main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://http.debian.net/debian/ $DEBIAN_VERSION-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ $DEBIAN_VERSION/updates main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -qq \
        clamav-daemon \
        clamav-freshclam \
        libclamunrar7 \
        supervisor \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Initial update of av databases 
RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd

# Update Permission
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

# Configuration update
RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf

# Volume provision
VOLUME ["/var/lib/clamav"]

WORKDIR /server

COPY . /server
RUN npm install && npm run postinstall

# Copy supervisor config
COPY ./configs/supervisord.conf /etc/supervisor/conf.d/supervisord-nodejs.conf

EXPOSE 3000
CMD ["/usr/bin/supervisord", "-n"]
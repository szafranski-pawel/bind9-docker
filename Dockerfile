FROM ubuntu:jammy

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8

# Install git and other useful scripts
RUN apt-get -y update && apt-get -y dist-upgrade && apt-get -y install apt-utils iproute2 net-tools git nano htop make autoconf pkg-config libtool libuv1-dev libnghttp2-dev libssl-dev libcap-dev libjemalloc-dev && apt-get autoremove

# Add the BIND 9 Custom Repository
RUN git clone https://github.com/szafranski-pawel/bind9.git -b IoT

# Create all necessary dir
RUN adduser --disabled-password --gecos "" bind
RUN mkdir -p /etc/bind/ && chown root:bind /etc/bind/ && chmod 755 /etc/bind/
RUN mkdir -p /run/named/ && chown bind:bind /run/named/ && chmod 755 /run/named/

# Install BIND 9
WORKDIR /bind9
RUN autoreconf -fi && ./configure --prefix '/usr/local/bind' --sysconfdir '/etc/bind' --localstatedir '/' && make install
RUN ln -s /usr/local/bind/sbin/* /usr/sbin/
RUN rm -rf /bind9

# Set workdir for named script
WORKDIR /home/bind

VOLUME ["/etc/bind"]

EXPOSE 53/udp 53/tcp 953/tcp

CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind", "-4"]
# CMD ["tail", "-f", "/dev/null"]

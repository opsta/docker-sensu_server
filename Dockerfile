# Sensu Server
#
# Monitor servers, services, application health, and business KPIs
# This is Sensu Server Docker Image

FROM opsta/sensu-base:1.0-xenial-20160923.1
MAINTAINER Jirayut Nimsaeng <jirayut [at] opsta.io>

# 1) Install some Sensu Handler plugins
# 2) Install essential gems for Sensu Plugins
# 3) Clean to reduce Docker image size
ENV PATH=/opt/sensu/embedded/bin:$PATH \
    GEM_PATH=/opt/sensu/embedded/lib/ruby/gems/2.0.0:$GEM_PATH
ARG APT_CACHER_NG
RUN [ -n "$APT_CACHER_NG" ] && \
      echo "Acquire::http::Proxy \"$APT_CACHER_NG\";" \
      > /etc/apt/apt.conf.d/11proxy || true; \
    apt-get update && \
    apt-get install -y build-essential libcurl4-gnutls-dev && \
    sensu-install -P gelf,pagerduty,slack,mailer && \
    apt-get remove --purge --auto-remove -y \
      build-essential ifupdown iproute2 isc-dhcp-client isc-dhcp-common \
      libatm1 libisc-export160 libmnl0 libxtables11 manpages netbase \
      libcurl4-gnutls-dev && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /usr/lib/x86_64-linux-gnu/libfakeroot /build-files \
      /var/lib/apt/lists/* /etc/apt/apt.conf.d/11proxy \
      /opt/sensu/embedded/lib/ruby/gems/2.2.0/cache/*

CMD ["/opt/sensu/embedded/bin/ruby", "/opt/sensu/bin/sensu-server", \
     "-c", "/etc/sensu/config.json", "-d", "/etc/sensu/conf.d", \
     "-e", "/etc/sensu/extensions"]

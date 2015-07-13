FROM alpine:latest
MAINTAINER Daniel Kühne <dkhmailto@googlemail.com>

ENV KIBANA_VERSION 4.1.1-linux-x64

RUN apk --update add curl tar && \
    mkdir -p /opt/kibana && \
    curl -sS -L https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VERSION}.tar.gz | \
    tar xz --strip-components=1 -C /opt/kibana && \
    apk add nodejs && \
    rm -rf /opt/kibana-${KIBANA_VERSION}/node && \
    mkdir -p /opt/kibana-${KIBANA_VERSION}/node/bin && \
    ln -sf /usr/bin/node /opt/kibana-${KIBANA_VERSION}/node/bin/node && \
    apk del curl

ADD ./docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 5601

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["kibana"]

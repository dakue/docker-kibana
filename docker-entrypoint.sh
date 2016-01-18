#!/bin/sh
set -e

KIBANA_DIR="/opt/kibana"
KIBANA_CONFIG_FILE="${KIBANA_DIR}/config/kibana.yml"

if [ "$1" = 'kibana' ]
then
    if [ -n "$ELASTICSEARCH_PORT_9200_TCP" ]
    then
        if [ -z "$ELASTICSEARCH_URL" ]
        then
            export ELASTICSEARCH_URL='http://elasticsearch:9200'
            echo "INFO: setting ELASTICSEARCH_URL to $ELASTICSEARCH_URL"
        else
            echo >&2 'WARNING: both ELASTICSEARCH and ELASTICSEARCH_PORT_9200_TCP found'
            echo >&2 "  Connecting to ELASTICSEARCH_URL ($ELASTICSEARCH_URL)"
            echo >&2 '  instead of the linked elasticsearch container'
        fi
    fi
    
    if [ -z "$ELASTICSEARCH_URL" ]
    then
        echo >&2 'ERROR: missing ELASTICSEARCH and ELASTICSEARCH_PORT_9200_TCP environment variables'
        echo >&2 '  Did you forget to --link some_elasticsearch_container:elasticsearch or set an external host'
        echo >&2 '  with -e ELASTICSEARCH_URL=http://<hostname> ?'
        exit 1
    fi

    sed -i "s;^elasticsearch_url:.*;elasticsearch_url: ${ELASTICSEARCH_URL};" "${KIBANA_CONFIG_FILE}"
    # since version 4.2
    sed -i "s;# elasticsearch.url:.*;elasticsearch.url: ${ELASTICSEARCH_URL};" "${KIBANA_CONFIG_FILE}"

    if [ -n "${KIBANA_INDEX}" ]
    then
        echo "INFO: setting Kibana index to ${KIBANA_INDEX}"
        sed -i "s;^kibana_index:.*;kibana_index: ${KIBANA_INDEX};" "${KIBANA_CONF_FILE}"
    fi

    # mesos-friendly change
    unset HOST
    unset PORT

    exec ${KIBANA_DIR}/bin/kibana
fi

exec "$@"


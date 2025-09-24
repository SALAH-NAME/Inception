FROM alpine:3.21

ARG GRAFANA_VERSION=12.0.3

RUN apk update && apk add --no-cache \
    ca-certificates \
    curl \
    wget \
    tzdata \
    && rm -rf /var/cache/apk/*

RUN addgroup -g 472 -S grafana && \
    adduser -u 472 -S grafana -G grafana

RUN mkdir -p /usr/share/grafana && \
    wget -q "https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz" -O - | \
    tar -xz --strip-components=1 -C /usr/share/grafana

RUN mkdir -p /var/lib/grafana \
    /var/log/grafana \
    /etc/grafana/provisioning/dashboards \
    /etc/grafana/provisioning/datasources \
    /etc/grafana/dashboards

COPY conf/grafana.ini /etc/grafana/grafana.ini
COPY conf/datasources.yaml /etc/grafana/provisioning/datasources/datasources.yaml
COPY conf/dashboard-providers.yaml /etc/grafana/provisioning/dashboards/dashboard-providers.yaml
COPY conf/dashboards/ /etc/grafana/dashboards/
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chown -R grafana:grafana /var/lib/grafana \
    /var/log/grafana \
    /etc/grafana \
    /usr/share/grafana \
    /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

ENV PATH="/usr/share/grafana/bin:$PATH" \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

EXPOSE 3000

USER grafana

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["grafana", "server", "--homepath=/usr/share/grafana"]
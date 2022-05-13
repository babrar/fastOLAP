FROM redash/redash:7.0.0.b18042

COPY certs/ /opt/certs
# Pythonic way of declaring trusted certs
ENV REQUESTS_CA_BUNDLE=/opt/certs/presto-key.pem

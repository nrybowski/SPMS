FROM seahorn/seahorn-llvm10:nightly

USER root
RUN apt-get update && \
    apt-get -y install libjson-c-dev

WORKDIR /opt
COPY seahorn.sh .

ENTRYPOINT ["/opt/seahorn.sh"]

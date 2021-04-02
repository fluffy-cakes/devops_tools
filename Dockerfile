FROM ubuntu:20.04

USER root

COPY ./apps.sh /tmp/apps.sh

RUN ./tmp/apps.sh

CMD ["/bin/bash"]
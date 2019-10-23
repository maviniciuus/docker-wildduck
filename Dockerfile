FROM alpine:latest as builder
LABEL org.label-schema.vendor = "Astzweig UG(haftungsbeschränkt) & Co. KG"
LABEL org.label-schema.version = "1.2.3"
LABEL org.label-schema.description = "A docker container to run nodemailer/wildduck mailserver."
LABEL org.label-schema.vcs-url = "https://github.com/astzweig/docker-wildduck"
LABEL org.label-schema.schema-version = "1.0"
RUN apk add --no-cache dumb-init;

# Info: If changed, please also change the variables in the next stage
ARG INSTALL_DIR=/var/nodemailer
ARG SCRIPTS_DIR=/root/scripts
ENV INSTALL_DIR ${INSTALL_DIR}
ENV SCRIPTS_DIR ${SCRIPTS_DIR}

ARG WILDDUCK_GIT_REPO=https://github.com/nodemail/wildduck.git
ARG WILDDUCK_GIT_CID=4c1cd4210aca615e676eef766429c2bece5e18e3

ARG HARAKA_VERSION=2.8.25
ARG HARAKA_WD_PLUGIN_GIT_REPO=https://github.com/nodemailer/haraka-plugin-wildduck.git
ARG HARAKA_WD_PLUGIN_GIT_CID=fc85b92f06764b1fbc872032c1dc6193d2d7f068

ARG ZONEMTA_GIT_REPO=https://github.com/zone-eu/zone-mta-template.git
ARG ZONEMTA_GIT_CID=f5e752e5a9f1ba22699c612cade133be58162ad6
ARG ZONEMTA_WD_PLUGIN_GIT_REPO=https://github.com/nodemailer/zonemta-wildduck.git
ARG ZONEMTA_WD_PLUGIN_GIT_CID=695ca8a19a3c3e8212de1136a73beb58db6453c4

COPY ./scripts/[0-9][0-9]-*.sh ${SCRIPTS_DIR}/
# Scripts are named like: {ORDER PREFIX}-{NAME}.sh.
# Run files in sequence as induced by their order prefix (00-99).
RUN for file in ${SCRIPTS_DIR}/[0-9][0-9]-*.sh; do \
        chmod u+x "${file}"; \
        source "${file}"; \
    done

COPY ./scripts/[^0-9]*.sh ${SCRIPTS_DIR}/
COPY ./scripts/bin /usr/local/bin
RUN chmod +x ${SCRIPTS_DIR}/entrypoint.sh; \
    chmod +x /usr/local/bin/*;

VOLUME ["/etc/nodemailer"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ${SCRIPTS_DIR}/entrypoint.sh

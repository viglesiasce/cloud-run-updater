FROM gcr.io/google.com/cloudsdktool/cloud-sdk
ENV VERSION v4.2.0
RUN curl -sL -o /usr/bin/yq https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_amd64  && \
    chmod +x /usr/bin/yq
COPY util/update-service.sh .

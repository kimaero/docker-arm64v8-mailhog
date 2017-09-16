#
# MailHog Dockerfile
#

FROM arm64v8/alpine:3.6

# Install ca-certificates, required for the "release message" feature:
RUN apk --no-cache add \
    ca-certificates


# Install MailHog:
RUN apk add --update alpine-sdk
RUN apk --no-cache add --virtual build-dependencies \
    go \
    git \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && go get -d github.com/mailhog/MailHog \
  && cd /root/gocode/src/github.com/mailhog/MailHog \
  && make \
  && mv /root/gocode/bin/MailHog /usr/local/bin \
  && rm -rf /root/gocode \
  && apk del --purge build-dependencies \
  && apk del --purge alpine-sdk

# Add mailhog user/group with uid/gid 1000.
# This is a workaround for boot2docker issue #581, see
# https://github.com/boot2docker/boot2docker/issues/581
RUN adduser -D -u 1000 mailhog

USER mailhog

WORKDIR /home/mailhog

ENTRYPOINT ["MailHog"]

# Expose the SMTP and HTTP ports:
EXPOSE 1025 8025

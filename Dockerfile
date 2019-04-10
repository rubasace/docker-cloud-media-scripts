FROM woahbase/alpine-s6

MAINTAINER rubasace <rubasodin18@gmail.com>

ENV GOPATH="/go" \
    REMOTE_PATH="mediaefs:" \
    MOUNT_ARGS="--allow-other --allow-non-empty" \
    UPLOAD_ARGS="--checkers 3 --fast-list -v --tpslimit 3 --transfers 3 --delete-empty-src-dirs --log-file /logs/upload.log" \
    UMMOUNT_ARGS="-u" \
    INITIAL_WARMUP="true"

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing  --update mergerfs
## Alpine with Go Git
RUN apk add --no-cache --update alpine-sdk ca-certificates go git fuse fuse-dev shadow make autoconf automake \
	&& go get -u -v github.com/ncw/rclone \
	&& cp /go/bin/rclone /usr/sbin/ \
	&& rm -rf /go \
	&& apk del alpine-sdk go git make autoconf automake \
	&& rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

#TODO cleanup everything not needed

####################
# SCRIPTS
####################
#TODO revisit need for this setup
#TODO rename /usr/bin/project_env.sh and probably just copy needed values
COPY setup/* /usr/bin/
COPY scripts/* /usr/bin/
COPY root /

RUN chmod a+x /usr/bin/*
#    && groupmod -g $PGID users  \
#	&& useradd -u $PUID -U -d / -s /bin/false abc  \
#	&& usermod -G users abc
#    apt-get clean autoclean && \
#    apt-get autoremove -y && \
#    rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}/


VOLUME ["/local-media","/merged-media", "/drive-media", "/config", "/logs", "/dir_cache"]

####################
# ENTRYPOINT
####################
ENTRYPOINT ["/init"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared

CMD crond -l 2 -f
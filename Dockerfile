FROM woahbase/alpine-s6

MAINTAINER rubasace <rubasodin18@gmail.com>

ENV GOPATH="/go" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="mediaefs" \
    ConfigDir="/config" \
    ConfigName="rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-uz"

## Alpine with Go Git
RUN apk add --no-cache --update alpine-sdk ca-certificates go git fuse fuse-dev shadow \
	&& go get -u -v github.com/ncw/rclone \
	&& cp /go/bin/rclone /usr/sbin/ \
	&& rm -rf /go \
	&& apk del alpine-sdk go git \
	&& rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

####################
# SCRIPTS
####################
COPY setup/* /usr/bin/
COPY scripts/* /usr/bin/
COPY root /

RUN chmod a+x /usr/bin/* && \
    groupmod -g 1000 users && \
	useradd -u 911 -U -d / -s /bin/false abc && \
	usermod -G users abc
#    apt-get clean autoclean && \
#    apt-get autoremove -y && \
#    rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}/

VOLUME ["/mnt","/local-media","/merged", "config"]

####################
# ENTRYPOINT
####################
ENTRYPOINT ["/init"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared

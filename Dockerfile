####################
# BASE IMAGE
####################
FROM ubuntu:16.04

MAINTAINER rubasace <rubasodin18@gmail.com>


####################
# INSTALLATIONS
####################
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
        curl \
        fuse \
        unionfs-fuse \
        bc \
        unzip \
        wget \
        git \
        golang-go  \
        unionfs-fuse \
        ca-certificates && \
    update-ca-certificates && \
    apt-get install -y openssl && \
    sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf


# S6 overlay
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1

RUN \
    OVERLAY_VERSION=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
    curl -o /tmp/s6-overlay.tar.gz -L "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" && \
    tar xfz  /tmp/s6-overlay.tar.gz -C /


####################
# ENVIRONMENT VARIABLES
####################
# Encryption
ENV ENCRYPT_MEDIA "1"
ENV READ_ONLY "1"

# Rclone
ENV BUFFER_SIZE "500M"
ENV MAX_READ_AHEAD "30G"
ENV CHECKERS "16"
ENV RCLONE_CLOUD_ENDPOINT "gd-crypt:"
ENV RCLONE_LOCAL_ENDPOINT "local-crypt:"

# Time format
ENV DATE_FORMAT "+%F@%T"

# Local files removal
ENV REMOVE_LOCAL_FILES_BASED_ON "space"
ENV REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB "100"
ENV FREEUP_ATLEAST_GB "80"
ENV REMOVE_LOCAL_FILES_AFTER_DAYS "30"

# Plex
ENV PLEX_URL ""
ENV PLEX_TOKEN ""


####################
# SCRIPTS
####################
COPY setup/* /usr/bin/
COPY setup-rclone.sh /
COPY build_rclone.sh /
COPY scripts/* /usr/bin/
COPY root /

RUN chmod a+x /setup-rclone.sh && \
    sh /setup-rclone.sh && \
    chmod a+x /build_rclone.sh && \
    sh /build_rclone.sh && \
    chmod a+x /usr/bin/* && \
    groupmod -g 1000 users && \
	useradd -u 911 -U -d / -s /bin/false abc && \
	usermod -G users abc && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}/

####################
# VOLUMES
####################
# Define mountable directories.
#VOLUME /data/db /config /cloud-encrypt /cloud-decrypt /local-decrypt /local-media /chunks /log
VOLUME /data/db /cloud-encrypt /cloud-decrypt /local-decrypt /local-media /chunks /log


RUN chmod -R 777 /data /log && \
    mkdir /config

####################
# WORKING DIRECTORY
####################
WORKDIR /data


####################
# ENTRYPOINT
####################
ENTRYPOINT ["/init"]

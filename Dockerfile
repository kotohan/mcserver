FROM alpine:3.11.6
LABEL maintainer="kohhi.net"
# ARGs
ARG glibc_ver="2.30-r0"
ARG jre_verf="8u252"
ARG jre_vere="b09"
# Environment variables
ENV PATH=$PATH:/usr/glibc-compat/bin:/usr/jre/bin
ENV MC_XMX="1024M" \
    MC_XMS="512M" \
    MC_JAR="minecraft.jar"
# Working Directory
WORKDIR /usr/src
# Install curl
RUN apk update && \
    apk add --no-cache curl
# Install glibc
RUN curl -fsSL -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub 2>&1 && \
    curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${glibc_ver}/glibc-${glibc_ver}.apk 2>&1 && \
    curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${glibc_ver}/glibc-bin-${glibc_ver}.apk 2>&1 && \
    curl -LO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${glibc_ver}/glibc-i18n-${glibc_ver}.apk 2>&1 && \
    apk --no-cache add glibc-${glibc_ver}.apk glibc-bin-${glibc_ver}.apk glibc-i18n-${glibc_ver}.apk 2>/dev/null && \
    mv /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /usr/glibc-compat/lib/ld-linux-x86-64.lib && \
    ln -s /usr/glibc-compat/lib/ld-linux-x86-64.lib /usr/glibc-compat/lib/ld-linux-x86-64.so.2 && \
    rm -rf glibc-${glibc_ver}.apk glibc-bin-${glibc_ver}.apk glibc-i18n-${glibc_ver}.apk && \
    rm -rf /etc/apk/keys/sgerrand.rsa.pub
# Download JRE
RUN curl -LO https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk${jre_verf}-${jre_vere}/OpenJDK8U-jre_x64_linux_hotspot_${jre_verf}${jre_vere}.tar.gz 2>&1 && \
    tar zxvf OpenJDK8U-jre_x64_linux_hotspot_${jre_verf}${jre_vere}.tar.gz && \
    mv jdk${jre_verf}-${jre_vere}-jre /usr/jre && \
    rm -rf OpenJDK8U-jre_x64_linux_hotspot_${jre_verf}${jre_vere}.tar.gz
# Make Script
RUN echo '#!/bin/sh' >> /usr/bin/minecraft && \
    echo 'exec java -Xmx${MC_XMX} -Xms${MC_XMS} -jar /usr/src/${MC_JAR} nogui' >> /usr/bin/minecraft && \
    chmod +x /usr/bin/minecraft
# Set ENTRYPOINT
ENTRYPOINT [ "minecraft" ]
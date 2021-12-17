FROM alpine:3.15.0
LABEL maintainer="kohhi.net"
# ARGs
ARG jdk_ver0="17"
ARG jdk_ver1="0.1"
ARG jdk_ver2="12"
# Environment variables
ENV PATH=$PATH:/usr/jdk/bin
ENV MC_XMX="1024M" \
    MC_XMS="512M" \
    MC_JAR="minecraft.jar"
# Working Directory
WORKDIR /usr/src
# Install curl
RUN apk update && \
    apk add --no-cache curl
# Download JRE
RUN curl -LO https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk${jre_verf}-${jre_vere}/OpenJDK8U-jre_x64_linux_hotspot_${jre_verf}${jre_vere}.tar.gz 2>&1 && \
    curl -LO https://github.com/adoptium/temurin${jdk_ver0}-binaries/releases/download/jdk-${jdk_ver0}.${jdk_ver1}%2B${jdk_ver2}/OpenJDK${jdk_ver0}U-jdk_x64_alpine-linux_hotspot_${jdk_ver0}.${jdk_ver1}_${jdk_ver2}.tar.gz 2>&1 && \
    tar -xvzf OpenJDK${jdk_ver0}U-jdk_x64_alpine-linux_hotspot_${jdk_ver0}.${jdk_ver1}_${jdk_ver2}.tar.gz && \
    mv jdk-${jdk_ver0}.${jdk_ver1}\+${jdk_ver2} /usr/jdk && \
    rm -rf OpenJDK${jdk_ver0}U-jdk_x64_alpine-linux_hotspot_${jdk_ver0}.${jdk_ver1}_${jdk_ver2}.tar.gz
# Make Script
RUN echo '#!/bin/sh' >> /usr/bin/minecraft && \
    echo 'echo "Starting Minecraft Server..."' >> /usr/bin/minecraft && \
    echo 'echo "Mem: ${MC_XMX}"' >> /usr/bin/minecraft && \
    echo 'echo "Bin: ${MC_JAR}"' >> /usr/bin/minecraft && \
    echo 'exec java -Xmx${MC_XMX} -Xms${MC_XMS} -Dlog4j2.formatMsgNoLookups=true -jar /usr/src/${MC_JAR} nogui' >> /usr/bin/minecraft && \
    chmod +x /usr/bin/minecraft
# Set ENTRYPOINT
ENTRYPOINT [ "minecraft" ]

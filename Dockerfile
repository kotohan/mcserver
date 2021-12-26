## BUILD ARGs
ARG alpine_ver="3.15.0"
ARG jdk_ver0="17"
ARG jdk_ver1="0.1"
ARG jdk_ver2="12"
ARG spigot_ver="1.18.1"
## BUILD STAGE
FROM alpine:${alpine_ver} as builder
LABEL maintainer="nakochi.me"
# ARGs
ARG jdk_ver0
ARG jdk_ver1
ARG jdk_ver2
ARG spigot_ver
# Environment variables
ENV PATH=$PATH:/usr/jdk/bin
# Working Directory
WORKDIR /usr/src
# Install curl
RUN apk update && \
    apk add --no-cache curl git
# Download JRE
RUN curl -LO https://github.com/adoptium/temurin${jdk_ver0}-binaries/releases/download/jdk-${jdk_ver0}.${jdk_ver1}%2B${jdk_ver2}/OpenJDK${jdk_ver0}U-jdk_x64_alpine-linux_hotspot_${jdk_ver0}.${jdk_ver1}_${jdk_ver2}.tar.gz 2>&1 && \
    tar -xvzf OpenJDK${jdk_ver0}U-jdk_x64_alpine-linux_hotspot_${jdk_ver0}.${jdk_ver1}_${jdk_ver2}.tar.gz && \
    mv jdk-${jdk_ver0}.${jdk_ver1}\+${jdk_ver2} /usr/jdk
# Download BuildTools.jar
RUN curl -LO https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar 2>&1 && \
    java -jar ./BuildTools.jar --rev ${spigot_ver} && \
    ls -la
## PROD STAGE
FROM alpine:${alpine_ver} as prod
LABEL maintainer="nakochi.me"
# ARGs
ARG spigot_ver
# Environment variables
ENV PATH=$PATH:/usr/jdk/bin
ENV MC_XMX="1024M" \
    MC_XMS="512M"
# Working Directory
WORKDIR /usr/src
## Copy from builder
COPY --from=builder /usr/jdk /usr/jdk
COPY --from=builder /usr/src/spigot-${spigot_ver}.jar /usr/minecraft.jar
# Make Script
RUN echo '#!/bin/sh' >> /usr/bin/minecraft && \
    echo 'echo "Starting Minecraft Server..."' >> /usr/bin/minecraft && \
    echo 'echo "Mem: ${MC_XMX}"' >> /usr/bin/minecraft && \
    echo 'echo "Bin: ${MC_JAR}"' >> /usr/bin/minecraft && \
    echo 'exec java -Xmx${MC_XMX} -Xms${MC_XMS} -Dlog4j2.formatMsgNoLookups=true -jar /usr/minecraft.jar nogui' >> /usr/bin/minecraft && \
    chmod +x /usr/bin/minecraft
# Set ENTRYPOINT
ENTRYPOINT [ "minecraft" ]

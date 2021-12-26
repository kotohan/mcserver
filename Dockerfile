## BUILD ARGs
ARG alpine_ver="3.15.0"
ARG jdk_major="17"
ARG jdk_minor="0.1"
ARG jdk_micro="12"
ARG spigot_ver="1.18.1"
## BUILD STAGE
FROM alpine:${alpine_ver} as builder
LABEL maintainer="nakochi.me"
# ARGs
ARG jdk_major
ARG jdk_minor
ARG jdk_micro
ARG spigot_ver
# Environment variables
ENV PATH=$PATH:/usr/jdk/bin
# Working Directory
WORKDIR /usr/src
# Install curl
RUN apk update && \
    apk add --no-cache curl git
# Download JRE
RUN curl -LO https://github.com/adoptium/temurin${jdk_major}-binaries/releases/download/jdk-${jdk_major}.${jdk_minor}%2B${jdk_micro}/OpenJDK${jdk_major}U-jdk_x64_alpine-linux_hotspot_${jdk_major}.${jdk_minor}_${jdk_micro}.tar.gz 2>&1 && \
    tar -xvzf OpenJDK${jdk_major}U-jdk_x64_alpine-linux_hotspot_${jdk_major}.${jdk_minor}_${jdk_micro}.tar.gz && \
    mv jdk-${jdk_major}.${jdk_minor}\+${jdk_micro} /usr/jdk
# Download BuildTools.jar
RUN curl -LO https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar 2>&1 && \
    java -jar ./BuildTools.jar --rev ${spigot_ver}
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

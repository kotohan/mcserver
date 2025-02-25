## BUILD ARGs
ARG alpine_ver="3.21.3"
ARG jdk_major="21"
ARG jdk_minor="0.6"
ARG jdk_micro="7"
ARG jdk_arch="x64"
#ARG jdk_arch="aarch64"
ARG spigot_ver="1.21.4"
## BUILD STAGE
FROM alpine:${alpine_ver} as builder
LABEL maintainer="nakochi.me"
# ARGs
ARG jdk_major
ARG jdk_minor
ARG jdk_micro
ARG jdk_arch
ARG spigot_ver
# Environment variables
ENV PATH=$PATH:/usr/jdk/bin
# Working Directory
WORKDIR /usr/src
# Install curl
RUN apk update && \
    apk add --no-cache curl git
# Download JDK
RUN curl -LO https://github.com/adoptium/temurin${jdk_major}-binaries/releases/download/jdk-${jdk_major}.${jdk_minor}%2B${jdk_micro}/OpenJDK${jdk_major}U-jdk_${jdk_arch}_alpine-linux_hotspot_${jdk_major}.${jdk_minor}_${jdk_micro}.tar.gz 2>&1 && \
    tar -xvzf OpenJDK${jdk_major}U-jdk_${jdk_arch}_alpine-linux_hotspot_${jdk_major}.${jdk_minor}_${jdk_micro}.tar.gz && \
    mv jdk-${jdk_major}.${jdk_minor}\+${jdk_micro} /usr/jdk
# Download JRE
RUN curl -LO https://github.com/adoptium/temurin${jdk_major}-binaries/releases/download/jdk-${jdk_major}.${jdk_minor}%2B${jdk_micro}/OpenJDK${jdk_major}U-jre_${jdk_arch}_alpine-linux_hotspot_${jdk_major}.${jdk_minor}_${jdk_micro}.tar.gz 2>&1 && \
    tar -xvzf OpenJDK${jdk_major}U-jre_${jdk_arch}_alpine-linux_hotspot_${jdk_major}.${jdk_minor}_${jdk_micro}.tar.gz && \
    mv jdk-${jdk_major}.${jdk_minor}\+${jdk_micro}-jre /usr/jre
# Download BuildTools.jar
RUN curl -LO https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar 2>&1 && \
    java -jar ./BuildTools.jar --rev ${spigot_ver}
## PROD STAGE
FROM alpine:${alpine_ver} as prod
LABEL maintainer="nakochi.me"
# ARGs
ARG spigot_ver
# Environment variables
ENV PATH=$PATH:/usr/jre/bin
ENV MC_XMX="1024M" \
    MC_XMS="512M"
# Working Directory
WORKDIR /usr/src
## Copy from builder
COPY --from=builder /usr/jre /usr/jre
COPY --from=builder /usr/src/spigot-${spigot_ver}.jar /usr/minecraft.jar
# Make Script
RUN echo '#!/bin/sh' >> /usr/bin/minecraft && \
    echo 'echo "Starting Minecraft Server..."' >> /usr/bin/minecraft && \
    echo 'echo "Mem: ${MC_XMX}"' >> /usr/bin/minecraft && \
    echo 'exec java -Xmx${MC_XMX} -Xms${MC_XMS} -Dlog4j2.formatMsgNoLookups=true -jar /usr/minecraft.jar nogui' >> /usr/bin/minecraft && \
    chmod +x /usr/bin/minecraft
# Set ENTRYPOINT
ENTRYPOINT [ "minecraft" ]

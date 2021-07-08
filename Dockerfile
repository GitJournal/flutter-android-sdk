FROM openjdk:8-slim

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  curl \
  git \
  lib32stdc++6 \
  libglu1-mesa \
  wget \
  ssh \
  unzip \
  ca-certificates \
  xz-utils \
  lcov \
  && rm -rf /var/lib/apt/lists/*

# RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Installing android base on what found at
# https://hub.docker.com/r/alvrme/alpine-android/~/dockerfile/

ENV SDK_TOOLS "3859397"
ENV BUILD_TOOLS "27.0.3"
ENV TARGET_SDK "27"
ENV ANDROID_HOME "/opt/sdk"

# Download and extract Android Tools
RUN curl -L http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS}.zip -o /tmp/tools.zip --progress-bar && \
  mkdir -p ${ANDROID_HOME} && \
  unzip /tmp/tools.zip -d ${ANDROID_HOME} && \
  rm -v /tmp/tools.zip

# Install SDK Packages
RUN mkdir -p /root/.android/ && touch /root/.android/repositories.cfg && \
  yes | ${ANDROID_HOME}/tools/bin/sdkmanager "--licenses" && \
  ${ANDROID_HOME}/tools/bin/sdkmanager "--update" "--verbose" && \
  ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;${BUILD_TOOLS}" "platform-tools" "platforms;android-${TARGET_SDK}" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

# Install flutter
ENV FLUTTER_HOME "/opt/flutter"
ENV FLUTTER_URL "https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_2.2.3-stable.tar.xz"
RUN mkdir -p ${FLUTTER_HOME} && \
  curl -L ${FLUTTER_URL} -o /tmp/flutter.tar.xz --progress-bar && \
  tar xf /tmp/flutter.tar.xz -C /tmp && \
  mv /tmp/flutter/ -T ${FLUTTER_HOME} && \
  rm -rf /tmp/flutter.tar.xz

ENV PATH=$PATH:$FLUTTER_HOME/bin
ENV PATH=$PATH:$FLUTTER_HOME/bin/cache/dart-sdk/bin
ENV PATH=$PATH:$FLUTTER_HOME/.pub-cache/bin

RUN flutter doctor && \
  chown -R root:root ${FLUTTER_HOME}

# Android NDK
ENV ANDROID_NDK_VERSION r19
ENV ANDROID_NDK_URL http://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
RUN curl -L "${ANDROID_NDK_URL}" -o android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip  \
  && unzip android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip -d ${ANDROID_HOME}  \
  && rm -rf android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
ENV ANDROID_NDK_HOME ${ANDROID_HOME}/android-ndk-${ANDROID_NDK_VERSION}
ENV ANDROID_NDK_ROOT ${ANDROID_HOME}/android-ndk-${ANDROID_NDK_VERSION}
ENV PATH ${ANDROID_NDK_HOME}:$PATH
RUN chmod u+x ${ANDROID_NDK_HOME}/ -R

# Fastlane
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ruby ruby-dev build-essential \
  && rm -rf /var/lib/apt/lists/*

# fastlane depends on 0.6.0 which has a dependency bug
# https://github.com/postmodern/digest-crc/issues/19
RUN gem install digest-crc -v '0.6.1'
RUN gem install fastlane

# gsutil
RUN apt-get update && apt-get install -y gcc python-dev python-setuptools libffi-dev gnupg2 python-pip
RUN pip install gsutil
RUN pip install --upgrade google-auth-oauthlib

# Sentry
RUN apt-get install -y npm
RUN npm config set unsafe-perm true
RUN npm install -g @sentry/cli

# Flutter test results in junit format
RUN flutter pub global activate junitreport

# Circle CI Debugging via SSH
RUN mkdir -p /home/circleci
RUN echo "#!/bin/bash\nexport PATH=/home/circleci/.local/bin:/home/circleci/bin:/opt/sbt/bin:/opt/apache-maven/bin:/opt/apache-ant/bin:/opt/gradle/bin:/usr/local/openjdk-14/bin:${PATH}" > /home/circleci/.bash_profile
RUN chmod a+x /home/circleci/.bash_profile
RUN mkdir -p /root
RUN echo "#!/bin/bash\nexport PATH=/home/circleci/.local/bin:/home/circleci/bin:/opt/sbt/bin:/opt/apache-maven/bin:/opt/apache-ant/bin:/opt/gradle/bin:/usr/local/openjdk-14/bin:${PATH}" > /root/.bash_profile
RUN chmod a+x /root/.bash_profile

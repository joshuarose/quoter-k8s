ARG RUBY_VERSION=3.0.1

FROM ruby:$RUBY_VERSION-slim-buster

ARG PG_MAJOR=11
ARG NODE_MAJOR=14
ARG YARN_VERSION=1.22.5
ARG BUNDLER_VERSION=2.2.15

ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_ROOT=/app
ENV LANG=C.UTF-8
ENV GEM_HOME=/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH=/app/bin:$BUNDLE_BIN:$PATH

# Install essentials
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    curl \
    libcurl3-dev \
    libgit2-dev \
    git \
    cmake \
    gnupg2 \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

# Add PostgreSQL to sources list
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash -

# Add Yarn to the sources list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    less \
    libxml2-dev \
    libgssapi-krb5-2 \
    libpq5 \
    libpam-dev \
    libedit-dev \
    libxslt1-dev \
    libpq-dev \
    postgresql-client-$PG_MAJOR \
    nodejs \
    yarn=$YARN_VERSION-1 \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

ENV PATH /app/bin:$PATH

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler \
    && bundle install -j "$(getconf _NPROCESSORS_ONLN)"  \
    && rm -rf $BUNDLE_PATH/cache/*.gem \
    && find $BUNDLE_PATH/gems/ -name "*.c" -delete \
    && find $BUNDLE_PATH/gems/ -name "*.o" -delete

COPY . ./

RUN RAILS_ENV=production bundle exec rake assets:precompile

CMD bundle exec puma -C ./config/puma.rb
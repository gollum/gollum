FROM ruby:2.7
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get install -y \
    libicu-dev \
    cmake

COPY Gemfile* /tmp/
COPY gollum.gemspec* /tmp/
WORKDIR /tmp
RUN bundle install

WORKDIR /app
COPY . /app
RUN bundle exec rake install

VOLUME /wiki
WORKDIR /wiki
ENTRYPOINT ["/app/docker-run.sh"]
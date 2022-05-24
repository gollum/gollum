FROM ruby:2.7-alpine AS builder

RUN apk add \
    build-base \
    cmake \
    git \
    icu-dev \
    openssl-dev

COPY Gemfile* /tmp/
COPY gollum.gemspec* /tmp/
WORKDIR /tmp
RUN bundle install

RUN gem install \
    asciidoctor \
    creole \
    wikicloth \
    org-ruby \
    RedCloth \
    bibtex-ruby \
    && echo "gem-extra complete"

WORKDIR /app
COPY . /app
RUN bundle exec rake install


FROM ruby:2.7-alpine

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

RUN apk add \
    bash \
    git \
    libc6-compat

VOLUME /wiki
WORKDIR /wiki
COPY docker-run.sh /docker-run.sh
ENTRYPOINT ["/docker-run.sh"]

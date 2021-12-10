FROM ruby:2.7 AS builder

RUN apt-get update && apt-get install -y \
    libicu-dev \
    cmake

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


FROM ruby:2.7-slim

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

RUN apt-get update \
    && apt-get install --no-install-recommends -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

VOLUME /wiki
WORKDIR /wiki
COPY docker-run.sh /docker-run.sh
ENTRYPOINT ["/docker-run.sh"]

FROM ruby:2.7
ENV DEBIAN_FRONTEND="noninteractive"

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

VOLUME /wiki
WORKDIR /wiki
COPY docker-run.sh /docker-run.sh
ENTRYPOINT ["/docker-run.sh"]

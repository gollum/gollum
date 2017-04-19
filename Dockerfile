# Build as:
#   docker build -t gollum .
# Run as:
#   docker run --rm -p 4567:4567 -v ~/mywiki:/data gollum

FROM google/ruby

ENV DEBS git libicu-dev
RUN apt-get -qy update && apt-get -y install ${DEBS} && apt-get -qy clean

ENV GEMS github-markdown
RUN gem install --no-rdoc --no-ri ${GEMS}

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD gollum.gemspec /app/gollum.gemspec
RUN bundle install

ADD . /app
RUN bundle install

VOLUME /data
ENV BUNDLE_GEMFILE /app/Gemfile
WORKDIR /data
ENTRYPOINT ["bundle", "exec", "gollum"]
# TODO:
# * git-push via cron should be done from different container
# * mount git dir as a volume

FROM google/ruby

ENV DEBS libicu-dev
RUN apt-get -qy update && apt-get -y install ${DEBS} && apt-get -qy clean

ENV GEMS github-markdown
RUN gem install --no-rdoc --no-ri ${GEMS}

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD gollum.gemspec /app/gollum.gemspec
RUN bundle install

ADD . /app
RUN bundle install

EXPOSE 4567
VOLUME /data
CMD ["bundle", "exec", "gollum", "--gollum-path=/data"]
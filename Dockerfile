# TODO:
# * git-push via cron should be done from different container
# * mount git dir as a volume

FROM google/ruby

ENV DEBS libicu-dev
RUN apt-get -qy update && apt-get -y install ${DEBS} && apt-get -qy clean

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD gollum.gemspec /app/gollum.gemspec
RUN bundle install
ADD . /app

ENV GEMS github-markdown
RUN gem install --no-rdoc --no-ri ${GEMS}

CMD ["gollum"]
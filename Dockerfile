# TODO:
# * git-push via cron should be done from different container
# * mount git dir as a volume

FROM ubuntu:14.04

ENV DEBS ruby1.9.3 bundler
RUN apt-get -qy update && apt-get -y install ${DEBS} && apt-get -qy clean

ADD . /gollum
WORKDIR /gollum

RUN bundle install

ENV GEMS github-markdown
RUN gem install --no-rdoc --no-ri ${GEMS}

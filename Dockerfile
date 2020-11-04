FROM ruby:2.6.2

LABEL MAINTAINER mizucoffee
ENV PORT 3000
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt -y install aptitude && aptitude -y install v4l2loopback-dkms
RUN gem install bundler
RUN mkdir /aika

COPY ./Gemfile* /aika/
WORKDIR /aika

RUN bundle config set system 'true' && bundle install

CMD ["ruby", "app.rb", "-o", "0.0.0.0"]


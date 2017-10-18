FROM ruby:2.4.2
MAINTAINER Jason Wall <jason@thejayvm.ca>

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/

ENV BUNDLE_WITHOUT development:test

RUN bundle install --deployment

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES yes
ENV SECRET_KEY_BASE 8545ad37fe97bcf5d0cadf0915d11c44c6c28d9b4112aa47c03aa263fca9951c2c5be1a19b8e68542cb9bf213f1c45e157c972407a42aa3b2f413db707936741

COPY . /app
RUN rake assets:precompile

EXPOSE 80

CMD rails server --port 80

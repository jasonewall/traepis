FROM ruby:2.4.2
MAINTAINER Jason Wall <jason@thejayvm.ca>

WORKDIR /app

ENV BUNDLE_PATH /bundle
ENV PATH /bundle/bin:$PATH

EXPOSE 80

CMD rails s --port 80

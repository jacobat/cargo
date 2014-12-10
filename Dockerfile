FROM jacobat/ruby:2.1.5

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y nodejs

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
ADD vendor/cache /app/vendor/cache
WORKDIR /app
RUN bundle install --local

ADD . /app

EXPOSE 3000
CMD rails s

# Tutor Chatbot
> A tutor chatbot microservice that esponds to student answers about coursework.

[![Build Status](https://api.travis-ci.org/raen79/tutor_chatbot.svg?branch=master)](https://travis-ci.org/raen79/tutor_chatbot)
[![Maintainability](https://api.codeclimate.com/v1/badges/0976a8b00ba35bf8abbd/maintainability)](https://codeclimate.com/github/raen79/tutor_chatbot/maintainability)
## Getting Started
### Prerequisites
- Ruby 2.3
- Rails 5.1
- Postgres
- An RSA key pair
- Gmail account
### Installation
#### Database
Create a tutor_chatbot_dev and tutor_chatbot_test database with postgres
#### Environment Variables
`dot-env` gem is installed and so you can set up all your environment variables in a .env file at the root of the project. The following environment variables need to be set:
```
DB_USER = username for you DB
DB_PWD = password for your DB user
GM_USER = Gmail email address
GM_PWD = Gmail password
RSA_PUBLIC_KEY = Your public RSA key (don't worry about \n they are handled)
RSA_PRIVATE_KEY Your RSA private key (only used in testing, so only necessary in test/dev env, in production an external auth service which has not yet been set up will take care of the jwt token gen)
```
The production environment only needs `GM_USER`, `GM_PWD`, and `RSA_PUBLIC_KEY` set up.
## Documentation
http://tutor-chatbot.herokuapp.com/api_docs/swagger#/Faqs
## Running the Tests
`bundle exec rspec`
## Todo
1) Connect to external authentication microservice
2) Add ability for lecturers to upload coursework brief and semantically extract question/answer pairs from it
## Author
- Name: Eran Peer
- Email: eran.peer79@gmail.com

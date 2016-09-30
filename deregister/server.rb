# coding: utf-8

require 'sinatra'
require 'json'

post '/' do
  params = JSON.parse request.body.read
  p params
end

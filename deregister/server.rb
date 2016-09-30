# coding: utf-8

require 'sinatra'
require 'json'
require 'rest-client'

post '/' do
  params = JSON.parse request.body.read
  alerts = params['alerts']
  alerts.each do |alert|
    if alert["labels"]["job"] == "node"
      payload = {
        "Node" => alert["labels"]["instance"]
      }
      RestClient.put(
        "#{ENV['CONSUL_URL']}/v1/catalog/deregister",
        payload.to_json,
        {content_type: :json, accept: :json}
      )
    end
  end
end

# coding: utf-8

require 'sinatra'
require 'json'
require 'yaml'
require 'rest-client'

def unregister_consul(node, conf)
  consul_url = conf['consul_url']
  payload = {
    "Node" => node
  }
  RestClient.put(
    "#{consul_url}/v1/catalog/deregister",
    payload.to_json,
    {content_type: :json, accept: :json}
  )
end

def unregister_gitlab(node, conf)
  gitlab_url = conf['gitlab_url']
  gitlab_token = conf['gitlab_token']

  runners = RestClient.get(
    "#{gitlab_url}/api/v3/runners/all",
    { "PRIVATE-TOKEN" => gitlab_token }
  ).body
  runners = JSON.parse(runners)

  runners.each do |runner|
    if node == runner['description']
      RestClient.delete("#{gitlab_url}/api/v3/runners/#{runner['id']}")
    end
  end
end

post '/' do
  conf = {}
  open(ENV['CONFIG_FILE']) do |io|
    conf = YAML.load(io.read)
  end
  params = JSON.parse request.body.read
  alerts = params['alerts']
  alerts.each do |alert|
    if alert["labels"]["job"] == "node"
      node = alert["labels"]["instance"]
      unregister_consul(node, conf)
      unregister_gitlab(node, conf)
    end
  end
end

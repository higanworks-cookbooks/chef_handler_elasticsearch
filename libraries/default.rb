# Cookbook Name:: chef_handler_elasticsearch
# Library:: default
#
# Copyright 2014, HiganWorks LLC.
#

require 'chef/handler'

if not defined? Chef::RequestID
  require 'securerandom'
end

class Chef::Handler::Elasticsearch < ::Chef::Handler
  require 'timeout'
  attr_reader :opts, :config

  def initialize(opts = {})
    @config = {}
    @default = {
      url: 'http://localhost:9200',
      timeout: 3,
      prefix: 'chef_handler',
      prepare_template: true,
      template_order: 10,
      index_use_utc: true,
      index_date_format: "%Y.%m.%d",
      delete_keys: [],
      mappings: default_mapping
    }
    @opts = opts
    @opts
  end

  def default_mapping
'{
  "_default_" : {
    "numeric_detection" : true,
    "dynamic_date_formats" : ["yyyy-MM-dd HH:mm:ss Z", "date_optional_time"]
  }
}'
  end

  def report
    @default.merge!(node[:chef_handler_elasticsearch].symbolize_keys) if node[:chef_handler_elasticsearch]
    @config= @default.merge(@opts)
    Chef::Log.debug @config.to_s

    client = Chef::HTTP.new(@config[:url])
    index = "/#{@config[:prefix]}-#{build_logstash_date(data)}"

    if exception
      type = 'failure'
    else
      type = 'success'
    end

    prepare_template(client) if @config[:prepare_template]

    body = data.merge({'@timestamp' => Time.at(data[:end_time]).to_datetime.to_s})

    @config[:delete_keys].each do |key|
      body.tap { |h| h.delete(key.to_sym) }
    end

    Chef::Log.debug "===== Puts to es following..."
    Chef::Log.debug body.to_s

    begin
      res = timeout(@config[:timeout]) {
        if defined? Chef::RequestID.instance.request_id
          client.put([index, type, Chef::RequestID.instance.request_id].join('/'), body.to_json)
        else
          client.put([index, type, SecureRandom.uuid].join('/'), body.to_json)
        end
      }
      Chef::Log.debug "===== Response from es following..."
      Chef::Log.debug res.to_s
      Chef::Log.info "== Chef::Handler::Elasticsearch request_id: #{JSON.parse(res)['_id']}"
    rescue => e
      Chef::Log.error "== #{e.class}: Status report could not put to Elasticsearch."
    end
  end

  def build_logstash_date(data)
    if config[:index_use_utc]
      Time.at(data[:end_time]).getutc.strftime(@config[:index_date_format])
    else
      Time.at(data[:end_time]).strftime(@config[:index_date_format])
    end
  end

  def prepare_template(client)
    begin
      res = timeout(@config[:timeout]) {
        client.get("/_template/#{@config[:prefix]}_template")
      }
    rescue Net::HTTPServerException
      put_template(client)
      return
    rescue => e
      Chef::Log.error "== #{e.class}: Status report could not put to Elasticsearch."
      raise e.class, e.message
    end

    unless JSON.parse(@config[:mappings]) == JSON.parse(res)["#{@config[:prefix]}_template"]["mappings"]
      put_template(client)
    end
  end

  def put_template(client)
    begin
      Chef::Log.info "== create mapping template to Elasticsearch."
      res = timeout(@config[:timeout]) {
        client.put("/_template/#{@config[:prefix]}_template", build_template_body)
      }
    rescue => e
      Chef::Log.warn "== #{e.class}: mapping template could not put to Elasticsearch. Exiting..."
      raise e.class, e.message
    end
  end

  def build_template_body
    body = Hash.new
    body["template"] = "#{@config[:prefix]}-*"
    body["order"] = @config[:template_order]
    body["mappings"] = JSON.parse(@config[:mappings])
    Chef::Log.debug "===== Template for index following..."
    Chef::Log.debug body.to_json
    body.to_json
  end
end

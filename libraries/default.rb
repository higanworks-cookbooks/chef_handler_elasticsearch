# Cookbook Name:: chef_handler_elasticsearch
# Library:: default
#
# Copyright 2014, HiganWorks LLC.
#

class Chef::Handler::Elasticsearch < ::Chef::Handler
  attr_reader :opts, :config

  def initialize(opts = {})
    @config = {}
    @default = {
      url: 'http://localhost:9200',
      timeout: 3,
      prefix: 'logstash',
      type: 'chef',
      index_use_utc: true,
      index_date_format: "%Y.%m.%d"
    }
    @opts = opts
    @opts
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

    body = data.merge({'@timestamp' => Time.at(data[:end_time]).to_datetime.to_s})

    Chef::Log.debug "===== Puts to es following..."
    Chef::Log.debug body.to_s

    begin
      require 'timeout'
      res = timeout(@config[:timeout]) {
        client.put([index, type, SecureRandom.uuid].join('/'), body.to_json)
      }
      Chef::Log.debug "===== Response from es following..."
      Chef::Log.debug res.to_s
      Chef::Log.info "== Chef::Handler::Elasticsearch id: #{JSON.parse(res)['_id']}"
    rescue => e
      Chef::Log.warn "== #{e.class}: Status report could not put to Elasticsearch."
    end
  end

  def build_logstash_date(data)
    if config[:index_use_utc]
      Time.at(data[:end_time]).getutc.strftime(@config[:index_date_format])
    else
      Time.at(data[:end_time]).strftime(@config[:index_date_format])
    end
  end
end

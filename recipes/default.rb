#
# Cookbook Name:: chef_handler_elasticsearch
# Recipe:: default
#
# Copyright 2014, HiganWorks LLC.
#

Chef::Config[:report_handlers] << Chef::Handler::Elasticsearch.new
Chef::Config[:exception_handlers] << Chef::Handler::Elasticsearch.new


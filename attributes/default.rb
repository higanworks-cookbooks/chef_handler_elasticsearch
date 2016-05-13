default[:chef_handler_elasticsearch][:url] = 'http://localhost:9200'
default[:chef_handler_elasticsearch][:timeout] = 3
default[:chef_handler_elasticsearch][:prefix] = 'chef_handler'
default[:chef_handler_elasticsearch][:prepare_template] = true
default[:chef_handler_elasticsearch][:index_use_utc] = true
default[:chef_handler_elasticsearch][:index_date_format] = "%Y.%m.%d"

## Template
default[:chef_handler_elasticsearch][:template_order] = 10
default[:chef_handler_elasticsearch][:mappings] = '{
  "_default_" : {
    "numeric_detection" : true,
    "dynamic_date_formats" : ["yyyy-MM-dd HH:mm:ss Z", "date_optional_time"]
  }
}'
default[:chef_handler_elasticsearch][:delete_keys] = []

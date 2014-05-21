chef_handler_elasticsearch Cookbook
==========================

This cookbook add handler for post reports to elasticsearch like logstash style.

Reports are shown by kibana easily.

![kibana](https://dl.dropboxusercontent.com/u/3524956/quiita/chef_handler_elasticsearch.png)

Libraries
---

### default.rb

`Chef::Handler::Elasticsearch`

Put Chef-Client reports to elasticsearch.


Attributes
---

### default.rb

- node[:chef_handler_elasticsearch][:url]
  - Elasticsearch endpoint.
  - default: `'http://localhost:9200'`
- node[:chef_handler_elasticsearch][:timeout]
  - Request for Elasticsearch timeout.
  - default: `3` (second)
- node[:chef_handler_elasticsearch][:prefix]
  - Prefix for index name. e.g: `chef_handler-2014.05.21`
  - default: `'chef_handler'`
- node[:chef_handler_elasticsearch][:index_date_format]
  - Date section format of index name. e.g: `chef_handler-2014.05.21`
  - default: `"%Y.%m.%d"`
- node[:chef_handler_elasticsearch][:index_use_utc]
  - Use utc to index name.
  - default: `true`


### elasticsearch template settings.

- node[:chef_handler_elasticsearch][:prepare_template]
  - Create or update index template before put data.
  - default: `true`
- node[:chef_handler_elasticsearch][:template_order] = 10
  - Index template order.
  - default: `true`
- node[:chef_handler_elasticsearch][:mappings] = '{
  - Index template mapping.
  - default: `"_default_" : {
    "numeric_detection" : true,
    "dynamic_date_formats" : ["yyyy-MM-dd HH:mm:ss Z", "date_optional_time"]
  }
}'`


Recipes
---

### default.rb

Add `Chef::Handler::Elasticsearch` to chef config.


Usage
---

### Add to Chef::Config

e.g. your recipes, libraries.

```
Chef::Config[:report_handlers] << Chef::Handler::Elasticsearch.new
Chef::Config[:exception_handlers] << Chef::Handler::Elasticsearch.new
```

You can pass settings as argument at initialize.

```
Chef::Config[:report_handlers] << Chef::Handler::Elasticsearch.new(
  url: 'http://test.example.com:9200',
  timeout: 10,
)
```

### Add run_list

add `recipe[chef_handler_elasticsearch::default]` your run_list.

You can override default settings with chef layers. Such as role, environment, or node.json.

```
{
  "chef_handler_elasticsearch" : {
    "url" : "http://test.example.com:9200",
    "timeout" : 10
  }
}
```

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------

License: apache2

Author: SAWANOBORI Yukihiko(Higanworks LLC)

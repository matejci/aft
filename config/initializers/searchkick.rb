# frozen_string_literal: true

Searchkick.client = Elasticsearch::Client.new(hosts: [ENV.fetch('ELASTICSEARCH_URL', '127.0.0.1:9200')],
                                              retry_on_failure: true,
                                              transport_options: { request: { timeout: 250 } })

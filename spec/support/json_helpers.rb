module JsonHelpers

  # Request helpers

  def get_json(path)
    get path
    json_parse(last_response.body)
  end

  def post_json(url, data)
    post(url, json(data), headers)
    json_parse(last_response.body)
  end

  def headers
    { 'CONTENT_TYPE' => 'application/json' }
  end

  # JSON helpers

  def json_parse(body)
    MultiJson.load(body, symbolize_keys: true)
  end

  def json(hash)
    MultiJson.dump(hash, pretty: true)
  end

end
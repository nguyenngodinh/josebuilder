json.header = {alg: "<%= algorithm %>", typ: "JWS"}
json.payload do 
  json.array!(@<%= controller_file_path %>) do |<%= file_name %>|
    json.<%= file_name %> = <%= file_name %>.as_json
  end
end
json.signature = JWS.encode(@<%= controller_file_path %>.to_a.as_json, "<%= secret %>", "<%= algorithm %>")

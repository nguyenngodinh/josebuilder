json.header = {alg: "<%= algorithm %>", typ: "JWT"}
json.payload = @<%= file_name %>.as_json
json.signature = JWT.encode(@<%= file_name %>.as_json, "<%= secret %>", "<%= algorithm %>")

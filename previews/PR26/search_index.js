var documenterSearchIndex = {"docs":
[{"location":"pages/constants/#Default-connection-options","page":"Constants","title":"Default connection options","text":"","category":"section"},{"location":"pages/constants/","page":"Constants","title":"Constants","text":"EasyCurl.DEFAULT_CONNECT_TIMEOUT\nEasyCurl.DEFAULT_READ_TIMEOUT\nEasyCurl.MAX_REDIRECTIONS","category":"page"},{"location":"pages/constants/#EasyCurl.DEFAULT_CONNECT_TIMEOUT","page":"Constants","title":"EasyCurl.DEFAULT_CONNECT_TIMEOUT","text":"DEFAULT_CONNECT_TIMEOUT = 60\n\nThe default connection timeout for an Curl Client in seconds.\n\n\n\n\n\n","category":"constant"},{"location":"pages/constants/#EasyCurl.DEFAULT_READ_TIMEOUT","page":"Constants","title":"EasyCurl.DEFAULT_READ_TIMEOUT","text":"DEFAULT_READ_TIMEOUT = 300\n\nThe default read timeout for an Curl Client in seconds.\n\n\n\n\n\n","category":"constant"},{"location":"pages/constants/#EasyCurl.MAX_REDIRECTIONS","page":"Constants","title":"EasyCurl.MAX_REDIRECTIONS","text":"MAX_REDIRECTIONS = 5\n\nThe maximum number of redirections allowed for a request.\n\n\n\n\n\n","category":"constant"},{"location":"pages/constants/#Supported-HTTP-status-codes","page":"Constants","title":"Supported HTTP status codes","text":"","category":"section"},{"location":"pages/constants/","page":"Constants","title":"Constants","text":"EasyCurl.HTTP_STATUS_CODES","category":"page"},{"location":"pages/constants/#EasyCurl.HTTP_STATUS_CODES","page":"Constants","title":"EasyCurl.HTTP_STATUS_CODES","text":"HTTP_STATUS_CODES\n\nA dictionary that maps HTTP status codes to their corresponding messages:\n\n100 - CONTINUE\n101 - SWITCHING_PROTOCOLS\n102 - PROCESSING\n103 - EARLY_HINTS\n200 - OK\n201 - CREATED\n202 - ACCEPTED\n203 - NON_AUTHORITATIVE_INFORMATION\n204 - NO_CONTENT\n205 - RESET_CONTENT\n206 - PARTIAL_CONTENT\n207 - MULTI_STATUS\n208 - ALREADY_REPORTED\n226 - IM_USED\n300 - MULTIPLE_CHOICES\n301 - MOVED_PERMANENTLY\n302 - FOUND\n303 - SEE_OTHER\n304 - NOT_MODIFIED\n307 - TEMPORARY_REDIRECT\n308 - PERMANENT_REDIRECT\n400 - BAD_REQUEST\n401 - UNAUTHORIZED\n402 - PAYMENT_REQUIRED\n403 - FORBIDDEN\n404 - NOT_FOUND\n405 - METHOD_NOT_ALLOWED\n406 - NOT_ACCEPTABLE\n407 - PROXY_AUTHENTICATION_REQUIRED\n408 - REQUEST_TIMEOUT\n409 - CONFLICT\n410 - GONE\n411 - LENGTH_REQUIRED\n412 - PRECONDITION_FAILED\n413 - PAYLOAD_TOO_LARGE\n414 - URI_TOO_LONG\n415 - UNSUPPORTED_MEDIA_TYPE\n416 - RANGE_NOT_SATISFIABLE\n417 - EXPECTATION_FAILED\n418 - IM_A_TEAPOT\n421 - MISDIRECTED_REQUEST\n422 - UNPROCESSABLE_ENTITY\n423 - LOCKED\n424 - FAILED_DEPENDENCY\n425 - TOO_EARLY\n426 - UPGRADE_REQUIRED\n428 - PRECONDITION_REQUIRED\n429 - TOO_MANY_REQUESTS\n431 - REQUEST_HEADER_FIELDS_TOO_LARGE\n451 - UNAVAILABLE_FOR_LEGAL_REASONS\n500 - INTERNAL_SERVER_ERROR\n501 - NOT_IMPLEMENTED\n502 - BAD_GATEWAY\n503 - SERVICE_UNAVAILABLE\n504 - GATEWAY_TIMEOUT\n505 - HTTP_VERSION_NOT_SUPPORTED\n506 - VARIANT_ALSO_NEGOTIATES\n507 - INSUFFICIENT_STORAGE\n508 - LOOP_DETECTED\n510 - NOT_EXTENDED\n511 - NETWORK_AUTHENTICATION_REQUIRED\n\n\n\n\n\n","category":"constant"},{"location":"pages/error_handling/#Error-handling","page":"For Developers","title":"Error handling","text":"","category":"section"},{"location":"pages/error_handling/","page":"For Developers","title":"For Developers","text":"If the problem occurs on the EasyCurl side then CurlError exception will be thrown.","category":"page"},{"location":"pages/error_handling/","page":"For Developers","title":"For Developers","text":"CurlError","category":"page"},{"location":"pages/error_handling/#EasyCurl.CurlError","page":"For Developers","title":"EasyCurl.CurlError","text":"CurlError{code} <: Exception\n\nType wrapping LibCURL error codes. Returned from curl_request when a libcurl error occurs.\n\nFields\n\ncode::UInt32: The LibCURL error code (see libcurl error codes).\nmessage::String: The error message.\n\nExamples\n\njulia> curl_request(\"GET\", \"http://httpbin.org/status/400\", interface = \"9.9.9.9\")\nERROR: CurlError{45}(Failed binding local connection end)\n[...]\n\njulia> curl_request(\"GET\", \"http://httpbin.org/status/400\", interface = \"\")\nERROR: CurlError{7}(Couldn't connect to server)\n[...]\n\n\n\n\n\n","category":"type"},{"location":"pages/error_handling/","page":"For Developers","title":"For Developers","text":"Or, if the problem was caused by HHTP, a CurlStatusError exception will be thrown.","category":"page"},{"location":"pages/error_handling/","page":"For Developers","title":"For Developers","text":"CurlStatusError","category":"page"},{"location":"pages/error_handling/#EasyCurl.CurlStatusError","page":"For Developers","title":"EasyCurl.CurlStatusError","text":"CurlStatusError{code} <: Exception\n\nType wrapping HTTP error codes. Returned from curl_request when an HTTP error occurs.\n\nFields\n\ncode::Int64: The HTTP error code (see HTTP_STATUS_CODES).\nmessage::String: The error message.\nresponse::CurlResponse: The HTTP response object.\n\nExamples\n\njulia> curl_request(\"GET\", \"http://httpbin.org/status/400\", interface = \"0.0.0.0\")\nERROR: CurlStatusError{400}(BAD_REQUEST)\n[...]\n\njulia> curl_request(\"GET\", \"http://httpbin.org/status/404\", interface = \"0.0.0.0\")\nERROR: CurlStatusError{404}(NOT_FOUND)\n[...]\n\n\n\n\n\n","category":"type"},{"location":"pages/error_handling/","page":"For Developers","title":"For Developers","text":"Below is a small example of error handling.","category":"page"},{"location":"pages/error_handling/#Example","page":"For Developers","title":"Example","text":"","category":"section"},{"location":"pages/error_handling/","page":"For Developers","title":"For Developers","text":"using EasyCurl\n\nheaders = Pair{String,String}[\n    \"User-Agent\" => \"EasyCurl.jl\",\n    \"Content-Type\" => \"application/json\",\n]\n\ntry\n    response = curl_request(\"GET\", \"http://httpbin.org/status/400\", query = \"echo=你好嗎\",\n        headers = headers, interface = \"0.0.0.0\", read_timeout = 30, retry = 1)\n    # If the request is successful, you can process the response here\n    # ...\ncatch e\n    if isa(e, CurlError{EasyCurl.CURLE_COULDNT_CONNECT})\n        # Handle the case where the connection to the server could not be made\n    elseif isa(e, CurlError{EasyCurl.CURLE_OPERATION_TIMEDOUT})\n        # Handle the case where the operation timed out\n    elseif isa(e, CurlStatusError{400})\n        # Handle a 400 Bad Request error specifically\n        rethrow(e)\n    end\nend","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: EasyCurl.jl Logo)","category":"page"},{"location":"#EasyCurl.jl","page":"Home","title":"EasyCurl.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"EasyCurl is a lightweight Julia package that provides a user-friendly wrapper for the libcurl C library, for making HTTP requests. It is useful for sending HTTP requests, especially when dealing with RESTful APIs.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To install EasyCurl, simply use the Julia package manager:","category":"page"},{"location":"","page":"Home","title":"Home","text":"] add EasyCurl","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Here is an example usage of EasyCurl:","category":"page"},{"location":"","page":"Home","title":"Home","text":"In the example, a POST request is sent to http://httpbin.org/post using the en0 network interface","category":"page"},{"location":"","page":"Home","title":"Home","text":"using EasyCurl\n\nheaders = Pair{String,String}[\n    \"User-Agent\" => \"EasyCurl.jl\",\n    \"Content-Type\" => \"application/json\"\n]\n\n# 'interface' argument specifies the network interface to use for the request\n# 'read_timeout' and 'connect_timeout' define how long to wait for a response or connection\n# 'retry' argument specifies how many times to retry the request if it fails initially\n\nresponse = curl_request(\"POST\", \"http://httpbin.org/post\", headers = headers, query = \"qry=你好嗎\",\n    body = \"{\\\"data\\\":\\\"hi\\\"}\", interface = \"en0\", read_timeout = 5, connect_timeout = 10, retry = 10)\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response) |> String |> print\n{\n  \"headers\": {\n    \"X-Amzn-Trace-Id\": \"Root=1-6588a009-19f3dc0321bee38106226bb3\",\n    \"Content-Length\": \"13\",\n    \"Host\": \"httpbin.org\",\n    \"Accept\": \"*/*\",\n    \"Content-Type\": \"application/json\",\n    \"Accept-Encoding\": \"gzip\",\n    \"User-Agent\": \"EasyCurl.jl\"\n  },\n  \"json\": {\n    \"data\": \"hi\"\n  },\n  \"files\": {},\n  \"args\": {\n    \"qry\": \"你好嗎\"\n  },\n  \"data\": \"{\\\"data\\\":\\\"hi\\\"}\",\n  \"url\": \"http://httpbin.org/post?qry=你好嗎\",\n  \"form\": {},\n  \"origin\": \"100.250.50.140\"\n}","category":"page"},{"location":"","page":"Home","title":"Home","text":"For HEAD, GET, POST, PUT, and PATCH requests, a similar structure is used to invoke the curl_request function with the appropriate HTTP method specified","category":"page"},{"location":"","page":"Home","title":"Home","text":"using EasyCurl\n\n# HEAD\njulia> curl_head(\"http://httpbin.org/get\", interface = \"0.0.0.0\")\n\n# GET\njulia> curl_get(\"http://httpbin.org/get\", query = Dict{String,String}(\"qry\" => \"你好嗎\"))\n\n# POST\njulia> curl_post(\"http://httpbin.org/post\", query = \"qry=你好嗎\", body = \"{\\\"data\\\":\\\"hi\\\"}\")\n\n# PUT\njulia> curl_put(\"http://httpbin.org/put\", query = \"qry=你好嗎\", body = \"{\\\"data\\\":\\\"hi\\\"}\")\n\n# PATCH\njulia> curl_patch(\"http://httpbin.org/patch\", query = \"qry=你好嗎\", body = \"{\\\"data\\\":\\\"hi\\\"}\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"This example shows how to use CurlClient for making HTTP requests by reusing the same client instance, which can help in speeding up the requests when making multiple calls to the same server:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using EasyCurl\n\nheaders = Pair{String,String}[\n    \"User-Agent\" => \"EasyCurl.jl\",\n    \"Content-Type\" => \"application/json\"\n]\n\ncurl_client = CurlClient()\n\n# Perform a GET request\nresponse = curl_request(\n    curl_client,\n    \"GET\",\n    \"http://httpbin.org/get\",\n    headers = headers\n)\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response) |> String |> print\n{\n  \"headers\": {\n    \"X-Amzn-Trace-Id\": \"Root=1-6588a009-19f3dc0321bee38106226bb3\",\n    \"Content-Length\": \"13\",\n    \"Host\": \"httpbin.org\",\n    \"Accept\": \"*/*\",\n    \"Content-Type\": \"application/json\",\n    \"Accept-Encoding\": \"gzip\",\n    \"User-Agent\": \"EasyCurl.jl\"\n  },\n  ...\n}\n\nclose(curl_client)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Example of error handling with EasyCurl:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using EasyCurl\n\nheaders = Pair{String,String}[\n    \"User-Agent\" => \"EasyCurl.jl\",\n    \"Content-Type\" => \"application/json\",\n]\n\ntry\n    response = curl_request(\"GET\", \"http://httpbin.org/status/400\", query = \"echo=你好嗎\",\n        headers = headers, interface = \"0.0.0.0\", read_timeout = 30, retry = 1)\n    # If the request is successful, you can process the response here\n    # ...\ncatch e\n    if isa(e, CurlError{EasyCurl.CURLE_COULDNT_CONNECT})\n        # Handle the case where the connection to the server could not be made\n    elseif isa(e, CurlError{EasyCurl.CURLE_OPERATION_TIMEDOUT})\n        # Handle the case where the operation timed out\n    elseif isa(e, CurlStatusError{400})\n        # Handle a 400 Bad Request error specifically\n        rethrow(e)\n    end\nend","category":"page"},{"location":"","page":"Home","title":"Home","text":"Using curl_joinurl","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> curl_joinurl(\"http://example.com\", \"path\")\n\"http://example.com/path\"\n\njulia> curl_joinurl(\"http://example.com/\", \"/path/to/resource\")\n\"http://example.com/path/to/resource\"","category":"page"},{"location":"#Using-a-proxy-with-EasyCurl","page":"Home","title":"Using a proxy with EasyCurl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To use a proxy for all your HTTP and HTTPS requests in EasyCurl, you can set the following environment variables:","category":"page"},{"location":"","page":"Home","title":"Home","text":"all_proxy: Proxy for all protocols\nhttp_proxy: Proxy for HTTP requests\nhttps_proxy: Proxy for HTTPS requests\nno_proxy: Domains to exclude from proxying","category":"page"},{"location":"","page":"Home","title":"Home","text":"# 'your_proxy_username' your proxy account's username\n# 'your_proxy_password' your proxy account's password\n# 'your_proxy_host' the hostname or IP address of your proxy server\n# 'your_proxy_port' the port number your proxy server listens on\n\n# socks5 proxy for all protocols\nENV[\"all_proxy\"] = \"socks5://your_proxy_username:your_proxy_password@your_proxy_host:your_proxy_port\"\n\n# domains that should bypass the proxy\nENV[\"no_proxy\"] = \"localhost,.local,.mywork\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"When executing the curl_request function with the proxy parameter, it will ignore the environment variable settings for proxies","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> curl_request(\"GET\", \"http://httpbin.org/get\",\n    proxy = \"socks5://your_proxy_username:your_proxy_password@your_proxy_host:your_proxy_port\")","category":"page"},{"location":"pages/api_reference/#Types","page":"API Reference","title":"Types","text":"","category":"section"},{"location":"pages/api_reference/","page":"API Reference","title":"API Reference","text":"CurlClient\nCurlRequest\nCurlResponse","category":"page"},{"location":"pages/api_reference/#EasyCurl.CurlClient","page":"API Reference","title":"EasyCurl.CurlClient","text":"CurlClient\n\nRepresents a client for making HTTP requests using libcurl. Allows for connection reuse.\n\nFields\n\ncurl_handle::Ptr{CURL}: The libcurl easy handle.\nmulti_handle::Ptr{CURL}: The libcurl multi handle.\n\n\n\n\n\n","category":"type"},{"location":"pages/api_reference/#EasyCurl.CurlRequest","page":"API Reference","title":"EasyCurl.CurlRequest","text":"CurlRequest\n\nRepresents an HTTP request object.\n\nFields\n\nmethod::String: The HTTP method for the request (e.g., \"GET\", \"POST\").\nurl::String: The target URL for the HTTP request.\nmethod::String: Specifies the HTTP method for the request (e.g., \"GET\", \"POST\").\nurl::String: The target URL for the HTTP request.\nheaders::Vector{Pair{String, String}}: A list of header key-value pairs to include in the request.\nbody::Vector{UInt8}: The body of the request, represented as a vector of bytes.\nconnect_timeout::Real: Timeout in seconds for establishing a connection.\nread_timeout::Real: Timeout in seconds for reading the response.\ninterface::Union{String,Nothing}: Specifies a particular network interface to use for the request, or nothing to use the default.\nproxy::Union{String,Nothing}: Specifies a proxy server to use for the request, or nothing to bypass proxy settings.\naccept_encoding::Union{String,Nothing}: Specifies the accepted encodings for the response, such as \"gzip\". Defaults to nothing if not set.\nssl_verifypeer::Bool: Indicates whether SSL certificates should be verified (true) or not (false).\nverbose::Bool: When true, enables detailed output from Curl, useful for debugging purposes.\n\n\n\n\n\n","category":"type"},{"location":"pages/api_reference/#EasyCurl.CurlResponse","page":"API Reference","title":"EasyCurl.CurlResponse","text":"CurlResponse(x::CurlContext)\n\nAn HTTP response object returned on a request completion.\n\nFields\n\nstatus::Int64: The HTTP status code of the response.\nrequest_time::Float64: The time taken for the HTTP request in seconds.\nheaders::Vector{Pair{String,String}}: Headers received in the HTTP response.\nbody::Vector{UInt8}: The response body as a vector of bytes.\n\n\n\n\n\n","category":"type"},{"location":"pages/api_reference/#Client-Requests","page":"API Reference","title":"Client Requests","text":"","category":"section"},{"location":"pages/api_reference/","page":"API Reference","title":"API Reference","text":"curl_open\ncurl_request\ncurl_get\ncurl_patch\ncurl_post\ncurl_put\ncurl_head\ncurl_delete","category":"page"},{"location":"pages/api_reference/#EasyCurl.curl_open","page":"API Reference","title":"EasyCurl.curl_open","text":"curl_open(f::Function, x...; kw...)\n\nA helper function for executing a batch of curl requests, using the same client. Optionally configure the client (see CurlClient for more details).\n\nExamples\n\njulia> curl_open() do client\n           response = curl_request(client, \"GET\", \"http://httpbin.org/get\")\n           curl_status(response)\n       end\n200\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#EasyCurl.curl_request","page":"API Reference","title":"EasyCurl.curl_request","text":"curl_request(method::AbstractString, url::AbstractString; kw...) -> CurlResponse\n\nSend a url HTTP CurlRequest using as method one of \"GET\", \"POST\", etc. and return a CurlResponse object.\n\nKeyword arguments\n\nheaders = Pair{String,String}[]: The headers for the request.\nbody = nothing: The body for the request.\nquery = nothing: The query string for the request.\ninterface = nothing: The interface for the request.\nstatus_exception = true: Whether to throw an exception if the response status code indicates an error.\nconnect_timeout = 60: The connect timeout for the request in seconds.\nread_timeout = 300: The read timeout for the request in seconds.\nretry = 1: The number of times to retry the request if an error occurs.\nproxy = nothing: Which proxy to use for the request.\naccept_encoding = \"gzip\": Encoding to accept.\nverbose::Bool = false: Enables verbose output from Curl for debugging.\nssl_verifypeer = true: Whether peer need to be verified.\n\nExamples\n\njulia> headers = Pair{String,String}[\n           \"User-Agent\" => \"EasyCurl.jl\",\n           \"Content-Type\" => \"application/json\"\n       ]\n\njulia> response = curl_request(\"POST\", \"http://httpbin.org/post\", headers = headers, query = \"qry=你好嗎\",\n    body = \"{\\\"data\\\":\\\"hi\\\"}\", interface = \"en0\", read_timeout = 5, connect_timeout = 10, retry = 10)\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response) |> String |> print\n{\n  \"headers\": {\n    \"X-Amzn-Trace-Id\": \"Root=1-6588a009-19f3dc0321bee38106226bb3\",\n    \"Content-Length\": \"13\",\n    \"Host\": \"httpbin.org\",\n    \"Accept\": \"*/*\",\n    \"Content-Type\": \"application/json\",\n    \"Accept-Encoding\": \"gzip\",\n    \"User-Agent\": \"EasyCurl.jl\"\n  },\n  \"json\": {\n    \"data\": \"hi\"\n  },\n  \"files\": {},\n  \"args\": {\n    \"qry\": \"你好嗎\"\n  },\n  \"data\": \"{\\\"data\\\":\\\"hi\\\"}\",\n  \"url\": \"http://httpbin.org/post?qry=你好嗎\",\n  \"form\": {},\n  \"origin\": \"100.250.50.140\"\n}\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#EasyCurl.curl_get","page":"API Reference","title":"EasyCurl.curl_get","text":"curl_get(url::AbstractString; kw...) -> CurlResponse\n\nShortcut for curl_request function, work similar to curl_request(\"GET\", url; kw...).\n\nExamples\n\njulia> headers = Pair{String,String}[\n           \"User-Agent\" => \"EasyCurl.jl\",\n           \"Content-Type\" => \"application/json\"\n       ]\n\njulia> response = curl_get(\"http://httpbin.org/get\", headers = headers,\n    query = Dict{String,String}(\"qry\" => \"你好嗎\"))\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response) |> String |> print\n{\n  \"args\": {\n    \"qry\": \"你好嗎\"\n  },\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip\",\n    \"Content-Type\": \"application/json\",\n    \"Host\": \"httpbin.org\",\n    \"User-Agent\": \"EasyCurl.jl\",\n    \"X-Amzn-Trace-Id\": \"Root=1-6589e259-24815d6d62da962a06fc7edf\"\n  },\n  \"origin\": \"100.250.50.140\",\n  \"url\": \"http://httpbin.org/get?qry=你好嗎\"\n}\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#EasyCurl.curl_patch","page":"API Reference","title":"EasyCurl.curl_patch","text":"curl_patch(url::AbstractString; kw...) -> CurlResponse\n\nShortcut for curl_request function, work similar to curl_request(\"PATCH\", url; kw...).\n\nExamples\n\njulia> headers = Pair{String,String}[\n           \"User-Agent\" => \"EasyCurl.jl\",\n           \"Content-Type\" => \"application/json\"\n       ]\n\njulia> response = curl_patch(\"http://httpbin.org/patch\", headers = headers,\n    query = \"qry=你好嗎\", body = \"{\\\"data\\\":\\\"hi\\\"}\")\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response) |> String |> print\n{\n  \"args\": {\n    \"qry\": \"你好嗎\"\n  },\n  \"data\": \"{\\\"data\\\":\\\"hi\\\"}\",\n  \"files\": {},\n  \"form\": {},\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip\",\n    \"Content-Length\": \"13\",\n    \"Content-Type\": \"application/json\",\n    \"Host\": \"httpbin.org\",\n    \"User-Agent\": \"EasyCurl.jl\",\n    \"X-Amzn-Trace-Id\": \"Root=1-6589e410-33f8cb5a31db9fba6c0a746f\"\n  },\n  \"json\": {\n    \"data\": \"hi\"\n  },\n  \"origin\": \"100.250.50.140\",\n  \"url\": \"http://httpbin.org/patch?qry=你好嗎\"\n}\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#EasyCurl.curl_post","page":"API Reference","title":"EasyCurl.curl_post","text":"curl_post(url::AbstractString; kw...) -> CurlResponse\n\nShortcut for curl_request function, work similar to curl_request(\"POST\", url; kw...).\n\nExamples\n\njulia> headers = Pair{String,String}[\n           \"User-Agent\" => \"EasyCurl.jl\",\n           \"Content-Type\" => \"application/json\"\n       ]\n\njulia> response = curl_post(\"http://httpbin.org/post\", headers = headers,\n    query = \"qry=你好嗎\", body = \"{\\\"data\\\":\\\"hi\\\"}\")\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response) |> String |> print\n{\n  \"args\": {\n    \"qry\": \"你好嗎\"\n  },\n  \"data\": \"{\\\"data\\\":\\\"hi\\\"}\",\n  \"files\": {},\n  \"form\": {},\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip\",\n    \"Content-Length\": \"13\",\n    \"Content-Type\": \"application/json\",\n    \"Host\": \"httpbin.org\",\n    \"User-Agent\": \"EasyCurl.jl\",\n    \"X-Amzn-Trace-Id\": \"Root=1-6589e32c-7f09b85d56e11aea59cde1d6\"\n  },\n  \"json\": {\n    \"data\": \"hi\"\n  },\n  \"origin\": \"100.250.50.140\",\n  \"url\": \"http://httpbin.org/post?qry=你好嗎\"\n}\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#EasyCurl.curl_put","page":"API Reference","title":"EasyCurl.curl_put","text":"curl_put(url::AbstractString; kw...) -> CurlResponse\n\nShortcut for curl_request function, work similar to curl_request(\"PUT\", url; kw...).\n\nExamples\n\njulia> headers = Pair{String,String}[\n           \"User-Agent\" => \"EasyCurl.jl\",\n           \"Content-Type\" => \"application/json\"\n       ]\n\njulia> response = curl_put(\"http://httpbin.org/put\", headers = headers,\n    query = \"qry=你好嗎\", body = \"{\\\"data\\\":\\\"hi\\\"}\")\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response) |> String |> print\n{\n  \"args\": {\n    \"qry\": \"你好嗎\"\n  },\n  \"data\": \"{\\\"data\\\":\\\"hi\\\"}\",\n  \"files\": {},\n  \"form\": {},\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip\",\n    \"Content-Length\": \"13\",\n    \"Content-Type\": \"application/json\",\n    \"Host\": \"httpbin.org\",\n    \"User-Agent\": \"EasyCurl.jl\",\n    \"X-Amzn-Trace-Id\": \"Root=1-6589e3b0-58cdde84399ad8be30eb4e46\"\n  },\n  \"json\": {\n    \"data\": \"hi\"\n  },\n  \"origin\": \"100.250.50.140\",\n  \"url\": \"http://httpbin.org/put?qry=你好嗎\"\n}\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#EasyCurl.curl_head","page":"API Reference","title":"EasyCurl.curl_head","text":"curl_head(url::AbstractString; kw...) -> CurlResponse\n\nShortcut for curl_request function, work similar to curl_request(\"HEAD\", url; kw...).\n\nExamples\n\njulia> headers = Pair{String,String}[\n           \"User-Agent\" => \"EasyCurl.jl\",\n           \"Content-Type\" => \"application/json\"\n       ]\n\njulia> response = curl_head(\"http://httpbin.org/get\", headers = headers,\n    query = \"qry=你好嗎\", interface = \"0.0.0.0\")\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response)\nUInt8[]\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#EasyCurl.curl_delete","page":"API Reference","title":"EasyCurl.curl_delete","text":"curl_delete(url::AbstractString; kw...) -> CurlResponse\n\nShortcut for curl_request function, work similar to curl_request(\"DELETE\", url; kw...).\n\nExamples\n\njulia> headers = Pair{String,String}[\n           \"User-Agent\" => \"EasyCurl.jl\",\n           \"Content-Type\" => \"application/json\"\n       ]\n\njulia> response = curl_delete(\"http://httpbin.org/delete\", headers = headers,\n    query = \"qry=你好嗎\", body = \"{\\\"data\\\":\\\"hi\\\"}\")\n\njulia> curl_status(response)\n200\n\njulia> curl_body(response) |> String |> print\n{\n  \"args\": {\n    \"qry\": \"你好嗎\"\n  },\n  \"data\": \"{\\\"data\\\":\\\"hi\\\"}\",\n  \"files\": {},\n  \"form\": {},\n  \"headers\": {\n    \"Accept\": \"*/*\",\n    \"Accept-Encoding\": \"gzip\",\n    \"Content-Length\": \"13\",\n    \"Content-Type\": \"application/json\",\n    \"Host\": \"httpbin.org\",\n    \"User-Agent\": \"EasyCurl.jl\",\n    \"X-Amzn-Trace-Id\": \"Root=1-6589e5f7-1c1ff2407f567ff17786576d\"\n  },\n  \"json\": {\n    \"data\": \"hi\"\n  },\n  \"origin\": \"100.250.50.140\",\n  \"url\": \"http://httpbin.org/delete?qry=你好嗎\"\n}\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#Utilities","page":"API Reference","title":"Utilities","text":"","category":"section"},{"location":"pages/api_reference/","page":"API Reference","title":"API Reference","text":"curl_joinurl","category":"page"},{"location":"pages/api_reference/#EasyCurl.curl_joinurl","page":"API Reference","title":"EasyCurl.curl_joinurl","text":"curl_joinurl(basepart::AbstractString, parts::AbstractString...)::String\n\nConstruct a URL by concatenating a base part with one or more path segments. This function ensures that each segment is separated by a single forward slash (/), regardless of whether the basepart or parts already contain slashes at their boundaries.\n\nExamples\n\njulia> curl_joinurl(\"http://example.com\", \"path\")\n\"http://example.com/path\"\n\njulia> curl_joinurl(\"http://example.com/\", \"/path/to/resource\")\n\"http://example.com/path/to/resource\"\n\n\n\n\n\n","category":"function"}]
}

module EasyCurl

export curl_open,
    curl_request,
    curl_get,
    curl_patch,
    curl_post,
    curl_put,
    curl_head,
    curl_delete

export curl_body,
    curl_status,
    curl_headers,
    curl_request_time,
    curl_iserror,
    curl_header

export curl_joinurl

export CurlClient,
    CurlRequest,
    CurlResponse,
    CurlError,
    CurlStatusError

using LibCURL

"""
    DEFAULT_CONNECT_TIMEOUT = 60

The default connection timeout for an Curl Client in seconds.
"""
const DEFAULT_CONNECT_TIMEOUT = 60

"""
    DEFAULT_READ_TIMEOUT = 300

The default read timeout for an Curl Client in seconds.
"""
const DEFAULT_READ_TIMEOUT = 300

"""
    MAX_REDIRECTIONS = 5

The maximum number of redirections allowed for a request.
"""
const MAX_REDIRECTIONS = 5

"""
    CurlClient

Represents a client for making HTTP requests using libcurl. Allows for connection reuse.

## Fields

- `curl_handle::Ptr{Cvoid}`: The libcurl easy handle.
- `multi_handle::Ptr{Cvoid}`: The libcurl multi handle.
"""
struct CurlClient
    curl_handle::Ptr{Cvoid}
    multi_handle::Ptr{Cvoid}

    CurlClient() = new(curl_easy_init(), curl_multi_init())
end

curl_easy_cleanup(c::CurlClient) = LibCURL.curl_easy_cleanup(c.curl_handle)
curl_easy_escape(c::CurlClient, x...) = LibCURL.curl_easy_escape(c.curl_handle, x...)
curl_easy_getinfo(c::CurlClient, x...) = LibCURL.curl_easy_getinfo(c.curl_handle, x...)
curl_easy_setopt(c::CurlClient, x...) = LibCURL.curl_easy_setopt(c.curl_handle, x...)
curl_easy_unescape(c::CurlClient, x...) = LibCURL.curl_easy_unescape(c.curl_handle, x...)

function Base.close(c::CurlClient)
    curl_multi_cleanup(c.multi_handle)
    curl_easy_cleanup(c)
    nothing
end

include("Static.jl")
include("Utils.jl")

"""
    CurlError{code} <: Exception

Type wrapping LibCURL error codes. Returned from [`curl_request`](@ref) when a libcurl error occurs.

## Fields
- `code::UInt32`: The LibCURL error code (see [libcurl error codes](https://curl.se/libcurl/c/libcurl-errors.html)).
- `message::String`: The error message.

## Examples

```julia-repl
julia> curl_request("GET", "http://httpbin.org/status/400", interface = "9.9.9.9")
ERROR: CurlError{45}(Failed binding local connection end)
[...]

julia> curl_request("GET", "http://httpbin.org/status/400", interface = "")
ERROR: CurlError{7}(Couldn't connect to server)
[...]
```
"""
struct CurlError{code} <: Exception
    code::UInt64
    message::String

    function CurlError(code::Integer, message::String)
        return new{code}(code, message)
    end
end

function Base.showerror(io::IO, e::CurlError)
    print(io, "CurlError{$(Int64(e.code))}(", e.message, ")")
end

mutable struct CurlContext
    header_list_ptr::Ptr{Cvoid}
    http_version::Ref{Clong}
    response_code::Ref{Clong}
    request_time::Ref{Cdouble}
    header_data::IOBuffer
    body_data::IOBuffer

    function CurlContext()
        c = new(C_NULL, Ref{Clong}(), Ref{Clong}(), Ref{Cdouble}(), IOBuffer(), IOBuffer())
        finalizer(close, c)
        return c
    end
end

function Base.close(x::CurlContext)
    close(x.header_data)
    close(x.body_data)
    nothing
end

"""
    CurlResponse(x::CurlContext)

An HTTP response object returned on a request completion.

## Fields

- `status::Int64`: The HTTP status code of the response.
- `request_time::Float64`: The time taken for the HTTP request in seconds.
- `headers::Vector{Pair{String,String}}`: Headers received in the HTTP response.
- `body::Vector{UInt8}`: The response body as a vector of bytes.
"""
struct CurlResponse
    version::Int64
    status::Int64
    request_time::Float64
    headers::Vector{Pair{String,String}}
    body::Vector{UInt8}

    function CurlResponse(x::CurlContext)
        return new(
            x.http_version[],
            x.response_code[],
            x.request_time[],
            parse_headers(take!(x.header_data)),
            take!(x.body_data),
        )
    end
end

function Base.show(io::IO, x::CurlResponse)
    println(io, CurlResponse)
    println(io, "\"\"\"")
    print(io, "HTTP/", http_version_as_string(x.version))
    println(io, " $(x.status) $(Base.get(HTTP_STATUS_CODES, x.status, ""))")
    for (k, v) in x.headers
        println(io, "$k: '$v'")
    end
    println(io, "\"\"\"")
    if length(x.body) > 1000
        v = view(x.body, 1:1000)
        print(io, "    ", strip(String(v)))
        println(io, "\n    ⋮")
    else
        v = view(x.body, 1:length(x.body))
        println(io, "    ", strip(String(v)))
    end
end

"""
    curl_status(x::CurlResponse) -> Int

Extracts the HTTP status code from a [`CurlResponse`](@ref) object.

## Examples

```julia-repl
julia> response = curl_request("GET", "http://httpbin.org/get")

julia> curl_status(response)
200
```
"""
curl_status(x::CurlResponse) = x.status
status(x...; kw...) = curl_status(x...; kw...)

"""
    curl_iserror(x::CurlResponse) -> Bool

Determines if the HTTP response indicates an error (status codes 400 and above).

## Examples

```julia-repl
julia> response = curl_request("GET", "http://httpbin.org/get")

julia> curl_iserror(response)
false
```
"""
curl_iserror(x::CurlResponse) = x.status >= 400
iserror(x...; kw...) = curl_iserror(x...; kw...)

"""
    curl_body(x::CurlResponse) -> String

Extracts the body of the HTTP response as a string.

## Examples

```julia-repl
julia> response = curl_request("GET", "http://httpbin.org/get")

julia> curl_body(response) |> String |> print
{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "EasyCurl/3.0.0",
    "X-Amzn-Trace-Id": "Root=1-66d985f2-4f01659e569022ee4dc145a8"
  },
  "origin": "95.217.119.142",
  "url": "http://httpbin.org/get"
}
```
"""
curl_body(x::CurlResponse) = x.body
body(x...; kw...) = curl_body(x...; kw...)

"""
    curl_headers(x::CurlResponse) -> Dict{String, String}

Extracts all headers from a [`CurlResponse`](@ref) object as a dictionary.

## Examples

```julia-repl
julia> response = curl_request("GET", "http://httpbin.org/get")

julia> curl_headers(response)
7-element Vector{Pair{String, String}}:
"date" => "Thu, 05 Sep 2024 10:24:48 GMT"
"content-type" => "application/json"
"content-length" => "258"
"connection" => "keep-alive"
"server" => "gunicorn/19.9.0"
"access-control-allow-origin" => "*"
"access-control-allow-credentials" => "true"
```
"""
curl_headers(x::CurlResponse) = x.headers
headers(x...; kw...) = curl_headers(x...; kw...)

"""
    curl_request_time(x::CurlResponse) -> Float64

Extracts the total request time for the HTTP request that resulted in the [`CurlResponse`](@ref).

## Examples

```julia-repl
julia> response = curl_request("GET", "http://httpbin.org/get")

julia> curl_request_time(response)
0.384262
```
"""
curl_request_time(x::CurlResponse) = x.request_time
request_time(x...; kw...) = curl_request_time(x...; kw...)

"""
    curl_headers(x::CurlResponse, key::AbstractString) -> Vector{String}

Retrieve all values for a specific header field from a [`CurlResponse`](@ref) object. This function is case-insensitive with regard to the header field name.

## Examples

```julia-repl
julia> response = curl_request("GET", "http://httpbin.org/get")

julia> curl_headers(response, "Content-Type")
1-element Vector{String}:
 "application/json"

julia> curl_headers(response, "nonexistent-header")
 String[]
```
"""
function curl_headers(x::CurlResponse, key::AbstractString)
    h = String[]
    for (k, v) in x.headers
        lowercase(key) == lowercase(k) && push!(h, v)
    end
    return h
end

"""
    curl_header(x::CurlResponse, key::AbstractString, def = nothing) -> Union{String, Nothing}

Retrieve the first value of a specific header field from a [`CurlResponse`](@ref) object. If the header is not found, the function returns a default value. This function is case-insensitive with regard to the header field name.

## Examples

```julia-repl
julia> response = curl_request("GET", "http://httpbin.org/get")

julia> curl_header(response, "Content-Type")
"application/json"

julia> curl_header(response, "nonexistent-header", "default-value")
"default-value"
```
"""
function curl_header(x::CurlResponse, key::AbstractString, def = nothing)
    for (k, v) in x.headers
        lowercase(key) == lowercase(k) && return v
    end
    return def
end

header(x...; kw...) = curl_header(x...; kw...)

"""
    CurlRequest

Represents an HTTP request object.

## Fields

- `method::String`: The HTTP method for the request (e.g., `"GET"`, `"POST"`).
- `url::String`: The target URL for the HTTP request.
- `method::String`: Specifies the HTTP method for the request (e.g., `"GET"`, `"POST"`).
- `url::String`: The target URL for the HTTP request.
- `headers::Vector{Pair{String, String}}`: A list of header key-value pairs to include in the request.
- `body::Vector{UInt8}`: The body of the request, represented as a vector of bytes.
- `connect_timeout::Real`: Timeout in seconds for establishing a connection.
- `read_timeout::Real`: Timeout in seconds for reading the response.
- `interface::Union{String,Nothing}`: Specifies a particular network interface to use for the request, or `nothing` to use the default.
- `proxy::Union{String,Nothing}`: Specifies a proxy server to use for the request, or `nothing` to bypass proxy settings.
- `accept_encoding::Union{String,Nothing}`: Specifies the accepted encodings for the response, such as `"gzip"`. Defaults to `nothing` if not set.
- `ssl_verifypeer::Bool`: Indicates whether SSL certificates should be verified (`true`) or not (`false`).
- `verbose::Bool`: When `true`, enables detailed output from Curl, useful for debugging purposes.
"""
struct CurlRequest
    method::String
    url::String
    headers::Vector{Pair{String,String}}
    body::Vector{UInt8}
    connect_timeout::Real
    read_timeout::Real
    interface::Union{String,Nothing}
    proxy::Union{String,Nothing}
    accept_encoding::Union{String,Nothing}
    ssl_verifypeer::Bool
    verbose::Bool
    ctx::CurlContext

    function CurlRequest(
        method::AbstractString,
        url::AbstractString;
        headers::Vector{Pair{String,String}} = Pair{String,String}[],
        body::Vector{UInt8} = UInt8[],
        connect_timeout::Real = DEFAULT_CONNECT_TIMEOUT,
        read_timeout::Real = DEFAULT_READ_TIMEOUT,
        interface::Union{String,Nothing} = nothing,
        proxy::Union{String,Nothing} = nothing,
        accept_encoding::Union{String,Nothing} = "gzip",
        ssl_verifypeer::Bool = true,
        verbose::Bool = false,
    )
        return new(
            method,
            url,
            headers,
            body,
            connect_timeout,
            read_timeout,
            interface,
            proxy,
            accept_encoding,
            ssl_verifypeer,
            verbose,
            CurlContext(),
        )
    end
end

"""
    CurlStatusError{code} <: Exception

Type wrapping HTTP error codes. Returned from [`curl_request`](@ref) when an HTTP error occurs.

## Fields

- `code::Int64`: The HTTP error code (see [`HTTP_STATUS_CODES`](@ref)).
- `message::String`: The error message.
- `response::CurlResponse`: The HTTP response object.

## Examples

```julia-repl
julia> curl_request("GET", "http://httpbin.org/status/400", interface = "0.0.0.0")
ERROR: CurlStatusError{400}(BAD_REQUEST)
[...]

julia> curl_request("GET", "http://httpbin.org/status/404", interface = "0.0.0.0")
ERROR: CurlStatusError{404}(NOT_FOUND)
[...]
```
"""
struct CurlStatusError{code} <: Exception
    code::Int64
    message::String
    response::CurlResponse

    function CurlStatusError(x::CurlResponse)
        return new{x.status}(x.status, Base.get(HTTP_STATUS_CODES, x.status, HTTP_STATUS_CODES[500]), x)
    end
end

function Base.showerror(io::IO, e::CurlStatusError)
    print(io, "CurlStatusError{$(e.code)}(", e.message, ")")
end

#__ libcurl

function write_response_body(curlbuf::Ptr{UInt8}, s::Csize_t, n::Csize_t, p_ctxt::Ptr{Cvoid})
    result = unsafe_pointer_to_objref(p_ctxt)
    sz = s * n
    unsafe_write(result.body_data, curlbuf, sz)
    return sz::Csize_t
end

function write_response_headers(curlbuf::Ptr{UInt8}, s::Csize_t, n::Csize_t, p_ctxt::Ptr{Cvoid})
    result = unsafe_pointer_to_objref(p_ctxt)
    sz = s * n
    unsafe_write(result.header_data, curlbuf, sz)
    return sz::Csize_t
end

function setup_curl_request(c::CurlClient, r::CurlRequest)
    curl_easy_setopt(c, CURLOPT_URL, r.url)
    curl_easy_setopt(c, CURLOPT_CAINFO, LibCURL.cacert)
    curl_easy_setopt(c, CURLOPT_FOLLOWLOCATION, 1)
    curl_easy_setopt(c, CURLOPT_MAXREDIRS, MAX_REDIRECTIONS)
    curl_easy_setopt(c, CURLOPT_CONNECTTIMEOUT, r.connect_timeout)
    curl_easy_setopt(c, CURLOPT_TIMEOUT, r.read_timeout)
    curl_easy_setopt(c, CURLOPT_WRITEFUNCTION, write_response_body)
    curl_easy_setopt(c, CURLOPT_INTERFACE, something(r.interface, C_NULL))
    curl_easy_setopt(c, CURLOPT_ACCEPT_ENCODING, something(r.accept_encoding, C_NULL))
    curl_easy_setopt(c, CURLOPT_SSL_VERIFYPEER, r.ssl_verifypeer)
    curl_easy_setopt(c, CURLOPT_USERAGENT, "EasyCurl/3.0.0")
    curl_easy_setopt(c, CURLOPT_PROXY, something(r.proxy, C_NULL))
    curl_easy_setopt(c, CURLOPT_VERBOSE, r.verbose)

    response_body_callback =
        @cfunction(write_response_body, Csize_t, (Ptr{UInt8}, Csize_t, Csize_t, Ptr{Cvoid}))

    response_header_callback =
        @cfunction(write_response_headers, Csize_t, (Ptr{UInt8}, Csize_t, Csize_t, Ptr{Cvoid}))

    curl_easy_setopt(c, CURLOPT_WRITEFUNCTION, response_body_callback)
    curl_easy_setopt(c, CURLOPT_WRITEDATA, pointer_from_objref(r.ctx))

    curl_easy_setopt(c, CURLOPT_HEADERFUNCTION, response_header_callback)
    curl_easy_setopt(c, CURLOPT_HEADERDATA, pointer_from_objref(r.ctx))

    for (k,v) in r.headers
        h = k * ": " * v
        r.ctx.header_list_ptr = curl_slist_append(r.ctx.header_list_ptr, h)
    end

    curl_easy_setopt(c, CURLOPT_HTTPHEADER, r.ctx.header_list_ptr)
end

struct CURLMsg
    msg::CURLMSG
    easy::Ptr{Cvoid}
    code::CURLcode
end

function perform_curl_request(c::CurlClient, r::CurlRequest)
    curl_multi_add_handle(c.multi_handle, c.curl_handle)

    try
        still_running = Ref{Cint}(1)
        curl_multi_perform(c.multi_handle, still_running)
        numfds = Ref{Cint}()

        while still_running[] > 0
            m = curl_multi_perform(c.multi_handle, still_running)
            if m == CURLM_OK
                m = curl_multi_wait(c.multi_handle, C_NULL, 0, 1000, numfds)
            end
            if m != CURLE_OK
                error_msg = unsafe_string(curl_multi_strerror(m))
                throw(CurlError(m, error_msg))
            end
        end

        while true
            p = curl_multi_info_read(c.multi_handle, Ref{Cint}())
            p == C_NULL && break
            m = unsafe_load(convert(Ptr{CURLMsg}, p))
            if m.msg == CURLMSG_DONE
                if m.code != CURLE_OK
                    error_msg = unsafe_string(curl_easy_strerror(m.code))
                    throw(CurlError(m.code, error_msg))
                end
            end
        end

        curl_easy_getinfo(c, CURLINFO_HTTP_VERSION, r.ctx.http_version)
        curl_easy_getinfo(c, CURLINFO_RESPONSE_CODE, r.ctx.response_code)
        curl_easy_getinfo(c, CURLINFO_TOTAL_TIME, r.ctx.request_time)
    finally
        curl_multi_remove_handle(c.multi_handle, c.curl_handle)
        curl_slist_free_all(r.ctx.header_list_ptr)
    end
end

function perform_curl_request(m::String, c::CurlClient, r::CurlRequest)
    setup_curl_request(c, r)
    if m == "GET"
        curl_easy_setopt(c, CURLOPT_HTTPGET, 1)
    elseif m == "HEAD"
        curl_easy_setopt(c, CURLOPT_NOBODY, 1)
    elseif m == "POST"
        curl_easy_setopt(c, CURLOPT_POST, 1)
        curl_easy_setopt(c, CURLOPT_POSTFIELDSIZE, length(r.body))
        curl_easy_setopt(c, CURLOPT_COPYPOSTFIELDS, pointer(r.body))
    elseif m == "PUT"
        curl_easy_setopt(c, CURLOPT_POSTFIELDS, r.body)
        curl_easy_setopt(c, CURLOPT_POSTFIELDSIZE, length(r.body))
        curl_easy_setopt(c, CURLOPT_CUSTOMREQUEST, "PUT")
    elseif m == "PATCH"
        curl_easy_setopt(c, CURLOPT_POSTFIELDS, r.body)
        curl_easy_setopt(c, CURLOPT_POSTFIELDSIZE, length(r.body))
        curl_easy_setopt(c, CURLOPT_CUSTOMREQUEST, "PATCH")
    elseif m == "DELETE"
        curl_easy_setopt(c, CURLOPT_POSTFIELDS, r.body)
        curl_easy_setopt(c, CURLOPT_CUSTOMREQUEST, "DELETE")
    else
        throw(CurlError(405, "`$(m)` method not supported"))
    end
    perform_curl_request(c, r)
end

"""
    curl_request(method::AbstractString, url::AbstractString; kw...) -> CurlResponse

Send a `url` HTTP CurlRequest using as `method` one of `"GET"`, `"POST"`, etc. and return a [`CurlResponse`](@ref) object.

## Keyword arguments

- `headers = Pair{String,String}[]`: The headers for the request.
- `body = nothing`: The body for the request.
- `query = nothing`: The query string for the request.
- `interface = nothing`: The interface for the request.
- `status_exception = true`: Whether to throw an exception if the response status code indicates an error.
- `connect_timeout = 60`: The connect timeout for the request in seconds.
- `read_timeout = 300`: The read timeout for the request in seconds.
- `retry = 1`: The number of times to retry the request if an error occurs.
- `retry_delay = 0.25`: Delay between retry attempts in seconds. Specifies the waiting time before attempting the request again after a failure.
- `proxy = nothing`: Which proxy to use for the request.
- `accept_encoding = "gzip"`: Encoding to accept.
- `verbose::Bool = false`: Enables verbose output from Curl for debugging.
- `ssl_verifypeer = true`: Whether peer need to be verified.

## Examples

```julia-repl
julia> headers = Pair{String,String}[
           "User-Agent" => "EasyCurl.jl",
           "Content-Type" => "application/json"
       ]

julia> response = curl_request("POST", "http://httpbin.org/post", headers = headers, query = "qry=你好嗎",
    body = "{\\"data\\":\\"hi\\"}", interface = "en0", read_timeout = 5, connect_timeout = 10, retry = 10)

julia> curl_status(response)
200

julia> curl_body(response) |> String |> print
{
  "headers": {
    "X-Amzn-Trace-Id": "Root=1-6588a009-19f3dc0321bee38106226bb3",
    "Content-Length": "13",
    "Host": "httpbin.org",
    "Accept": "*/*",
    "Content-Type": "application/json",
    "Accept-Encoding": "gzip",
    "User-Agent": "EasyCurl.jl"
  },
  "json": {
    "data": "hi"
  },
  "files": {},
  "args": {
    "qry": "你好嗎"
  },
  "data": "{\\"data\\":\\"hi\\"}",
  "url": "http://httpbin.org/post?qry=你好嗎",
  "form": {},
  "origin": "100.250.50.140"
}
```
"""
function curl_request(method::AbstractString, url::AbstractString; kw...)
    return curl_open(c -> curl_request(c, method, url; kw...))
end

function curl_request(
    curl_client::CurlClient,
    method::AbstractString,
    url::AbstractString;
    headers::Vector{Pair{String,String}} = Pair{String,String}[],
    query = nothing,
    body = nothing,
    status_exception::Bool = true,
    retry::Int64 = 0,
    retry_delay::Real = 0.25,
    kw...,
)::CurlResponse
    @label retry
    req = CurlRequest(
        uppercase(method),
        req_url(curl_client, url, query);
        headers = headers,
        body = to_bytes(body),
        kw...,
    )
    try
        perform_curl_request(req.method, curl_client, req)
        r = CurlResponse(req.ctx)
        if status_exception && curl_iserror(r)
            throw(CurlStatusError(r))
        end
        return r
    catch
        retry -= 1
        sleep(retry_delay)
        retry >= 0 && @goto retry
        rethrow()
    end
end

request(x...; kw...) = curl_request(x...; kw...)

"""
    curl_open(f::Function, x...; kw...)

A helper function for executing a batch of curl requests, using the same client. Optionally
configure the client (see [`CurlClient`](@ref) for more details).

## Examples

```julia-repl
julia> curl_open() do client
           response = curl_request(client, "GET", "http://httpbin.org/get")
           curl_status(response)
       end
200
```
"""
function curl_open(f::Function, x...; kw...)
    c = CurlClient(x...; kw...)
    try
        f(c)
    finally
        close(c)
    end
end

"""
    curl_get(url::AbstractString; kw...) -> CurlResponse

Shortcut for [`curl_request`](@ref) function, work similar to `curl_request("GET", url; kw...)`.

## Examples

```julia-repl
julia> headers = Pair{String,String}[
           "User-Agent" => "EasyCurl.jl",
           "Content-Type" => "application/json"
       ]

julia> response = curl_get("http://httpbin.org/get", headers = headers,
    query = Dict{String,String}("qry" => "你好嗎"))

julia> curl_status(response)
200

julia> curl_body(response) |> String |> print
{
  "args": {
    "qry": "\u4f60\u597d\u55ce"
  },
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "EasyCurl.jl",
    "X-Amzn-Trace-Id": "Root=1-6589e259-24815d6d62da962a06fc7edf"
  },
  "origin": "100.250.50.140",
  "url": "http://httpbin.org/get?qry=\u4f60\u597d\u55ce"
}
```
"""
curl_get(url; kw...)::CurlResponse = curl_request("GET", url; kw...)
get(url; kw...)::CurlResponse = curl_get(url; kw...)

"""
    curl_head(url::AbstractString; kw...) -> CurlResponse

Shortcut for [`curl_request`](@ref) function, work similar to `curl_request("HEAD", url; kw...)`.

## Examples

```julia-repl
julia> headers = Pair{String,String}[
           "User-Agent" => "EasyCurl.jl",
           "Content-Type" => "application/json"
       ]

julia> response = curl_head("http://httpbin.org/get", headers = headers,
    query = "qry=你好嗎", interface = "0.0.0.0")

julia> curl_status(response)
200

julia> curl_body(response)
UInt8[]
```
"""
curl_head(url; kw...)::CurlResponse = curl_request("HEAD", url; kw...)
head(url; kw...) = curl_head(url; kw...)

"""
    curl_post(url::AbstractString; kw...) -> CurlResponse

Shortcut for [`curl_request`](@ref) function, work similar to `curl_request("POST", url; kw...)`.

## Examples

```julia-repl
julia> headers = Pair{String,String}[
           "User-Agent" => "EasyCurl.jl",
           "Content-Type" => "application/json"
       ]

julia> response = curl_post("http://httpbin.org/post", headers = headers,
    query = "qry=你好嗎", body = "{\\"data\\":\\"hi\\"}")

julia> curl_status(response)
200

julia> curl_body(response) |> String |> print
{
  "args": {
    "qry": "\u4f60\u597d\u55ce"
  },
  "data": "{\\"data\\":\\"hi\\"}",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip",
    "Content-Length": "13",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "EasyCurl.jl",
    "X-Amzn-Trace-Id": "Root=1-6589e32c-7f09b85d56e11aea59cde1d6"
  },
  "json": {
    "data": "hi"
  },
  "origin": "100.250.50.140",
  "url": "http://httpbin.org/post?qry=\u4f60\u597d\u55ce"
}
```
"""
curl_post(url; kw...)::CurlResponse = curl_request("POST", url; kw...)
post(url; kw...) = curl_post(url; kw...)

"""
    curl_put(url::AbstractString; kw...) -> CurlResponse

Shortcut for [`curl_request`](@ref) function, work similar to `curl_request("PUT", url; kw...)`.

## Examples

```julia-repl
julia> headers = Pair{String,String}[
           "User-Agent" => "EasyCurl.jl",
           "Content-Type" => "application/json"
       ]

julia> response = curl_put("http://httpbin.org/put", headers = headers,
    query = "qry=你好嗎", body = "{\\"data\\":\\"hi\\"}")

julia> curl_status(response)
200

julia> curl_body(response) |> String |> print
{
  "args": {
    "qry": "\u4f60\u597d\u55ce"
  },
  "data": "{\\"data\\":\\"hi\\"}",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip",
    "Content-Length": "13",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "EasyCurl.jl",
    "X-Amzn-Trace-Id": "Root=1-6589e3b0-58cdde84399ad8be30eb4e46"
  },
  "json": {
    "data": "hi"
  },
  "origin": "100.250.50.140",
  "url": "http://httpbin.org/put?qry=\u4f60\u597d\u55ce"
}
```
"""
curl_put(url; kw...)::CurlResponse = curl_request("PUT", url; kw...)
put(url; kw...) = curl_put(url; kw...)

"""
    curl_patch(url::AbstractString; kw...) -> CurlResponse

Shortcut for [`curl_request`](@ref) function, work similar to `curl_request("PATCH", url; kw...)`.

## Examples

```julia-repl
julia> headers = Pair{String,String}[
           "User-Agent" => "EasyCurl.jl",
           "Content-Type" => "application/json"
       ]

julia> response = curl_patch("http://httpbin.org/patch", headers = headers,
    query = "qry=你好嗎", body = "{\\"data\\":\\"hi\\"}")

julia> curl_status(response)
200

julia> curl_body(response) |> String |> print
{
  "args": {
    "qry": "\u4f60\u597d\u55ce"
  },
  "data": "{\\"data\\":\\"hi\\"}",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip",
    "Content-Length": "13",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "EasyCurl.jl",
    "X-Amzn-Trace-Id": "Root=1-6589e410-33f8cb5a31db9fba6c0a746f"
  },
  "json": {
    "data": "hi"
  },
  "origin": "100.250.50.140",
  "url": "http://httpbin.org/patch?qry=\u4f60\u597d\u55ce"
}
```
"""
curl_patch(url; kw...)::CurlResponse = curl_request("PATCH", url; kw...)
patch(url; kw...)::CurlResponse = curl_patch(url; kw...)

"""
    curl_delete(url::AbstractString; kw...) -> CurlResponse

Shortcut for [`curl_request`](@ref) function, work similar to `curl_request("DELETE", url; kw...)`.

## Examples

```julia-repl
julia> headers = Pair{String,String}[
           "User-Agent" => "EasyCurl.jl",
           "Content-Type" => "application/json"
       ]

julia> response = curl_delete("http://httpbin.org/delete", headers = headers,
    query = "qry=你好嗎", body = "{\\"data\\":\\"hi\\"}")

julia> curl_status(response)
200

julia> curl_body(response) |> String |> print
{
  "args": {
    "qry": "\u4f60\u597d\u55ce"
  },
  "data": "{\\"data\\":\\"hi\\"}",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip",
    "Content-Length": "13",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "EasyCurl.jl",
    "X-Amzn-Trace-Id": "Root=1-6589e5f7-1c1ff2407f567ff17786576d"
  },
  "json": {
    "data": "hi"
  },
  "origin": "100.250.50.140",
  "url": "http://httpbin.org/delete?qry=\u4f60\u597d\u55ce"
}
```
"""
curl_delete(url; kw...)::CurlResponse = curl_request("DELETE", url; kw...)
delete(url; kw...)::CurlResponse = curl_delete(url; kw...)

end

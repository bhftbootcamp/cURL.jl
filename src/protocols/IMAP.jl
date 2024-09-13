#__ IMAP

export imap_request,
    imap_total_time,
    imap_body

export IMAPResponse,
    IMAPRequest,
    IMAPOptions

"""
    IMAPResponse <: CurlResponse

An IMAP response object returned on a request completion.

## Fields
| Name | Description | Accessors (`get`) |
|:-----|:------------|:------------------|
| `total_time::Float64` | Total time spent receiving a response in seconds. | `imap_total_time(x)`, `curl_total_time(x)` |
| `body::Vector{UInt8}` | The response body as a vector of bytes. | `imap_body(x)`, `curl_body(x)`|
"""
mutable struct IMAPResponse <: CurlResponse
    total_time::Float64
    body::Vector{UInt8}

    function IMAPResponse()
        return new(0.0, Vector{UInt8}())
    end
end

imap_total_time(x::IMAPResponse) = x.total_time
imap_body(x::IMAPResponse) = x.body

curl_total_time(x::IMAPResponse) = imap_total_time(x)
curl_body(x::IMAPResponse) = imap_body(x)

function Base.show(io::IO, x::IMAPResponse)
    println(io, IMAPResponse)
    if length(imap_body(x)) > 1000
        v = view(imap_body(x), 1:1000)
        print(io, "    ", strip(String(v)))
        println(io, "\n    ⋮")
    else
        v = view(imap_body(x), 1:length(imap_body(x)))
        println(io, "    ", strip(String(v)))
    end
end

"""
    IMAPOptions <: CurlOptions

Represents options for configuring an IMAP request.

## Fields
| Name | Description | Default |
|:-----|:------------|:--------|
| `read_timeout::Real` | Timeout in seconds for reading the response. | `30` |
| `connect_timeout::Real` | Maximum time in seconds that you allow the connection phase to take. | `10` |
| `ssl_verifyhost::Bool` | Enables SSL certificate's host verification. | `true` |
| `ssl_verifypeer::Bool` | Enables the SSL certificate verification. | `true` |
| `verbose::Bool` | Enables detailed output from Curl (useful for debugging). | `false` |
| `proxy::Union{String,Nothing}` | Proxy server URL, or `nothing` to bypass proxy settings. | `nothing` |
| `interface::Union{String,Nothing}` | Specifies a particular network interface to use for the request, or `nothing` to use the default. | `nothing` |
"""
struct IMAPOptions <: CurlOptions
    read_timeout::Int
    connect_timeout::Int
    ssl_verifyhost::Bool
    ssl_verifypeer::Bool
    verbose::Bool
    proxy::Union{String,Nothing}
    interface::Union{String,Nothing}

    function IMAPOptions(;
        read_timeout = 30,
        connect_timeout = 10,
        ssl_verifyhost = true,
        ssl_verifypeer = true,
        verbose = false,
        proxy = nothing,
        interface = nothing,
    )
        return new(
            read_timeout,
            connect_timeout,
            ssl_verifyhost,
            ssl_verifypeer,
            verbose,
            proxy,
            interface,
        )
    end
end

struct IMAPRequest <: CurlRequest
    url::String
    username::String
    password::String
    command::Union{Nothing,String}
    options::IMAPOptions
    response::IMAPResponse
end

#__ libcurl

function perform_request(c::CurlClient, r::IMAPRequest)
    # Basic request settings
    curl_easy_setopt(c, CURLOPT_URL, r.url)
    curl_easy_setopt(c, CURLOPT_USERNAME, r.username)
    curl_easy_setopt(c, CURLOPT_PASSWORD, r.password)

    # Custom command if provided
    curl_easy_setopt(c, CURLOPT_CUSTOMREQUEST, something(r.command, C_NULL))

    # Timeouts
    curl_easy_setopt(c, CURLOPT_CONNECTTIMEOUT, r.options.connect_timeout)
    curl_easy_setopt(c, CURLOPT_TIMEOUT, r.options.read_timeout)

    # SSL settings
    curl_easy_setopt(c, CURLOPT_SSL_VERIFYPEER, r.options.ssl_verifypeer)
    curl_easy_setopt(c, CURLOPT_SSL_VERIFYHOST, r.options.ssl_verifyhost ? 2 : 0)

    # Network settings
    curl_easy_setopt(c, CURLOPT_INTERFACE, something(r.options.interface, C_NULL))
    curl_easy_setopt(c, CURLOPT_PROXY, something(r.options.proxy, C_NULL))

    # Verbose debug output
    curl_easy_setopt(c, CURLOPT_VERBOSE, r.options.verbose)

    # Setup callback for response handling
    c_write_callback = @cfunction(write_callback, Csize_t, (Ptr{UInt8}, Csize_t, Csize_t, Ptr{Cvoid}))
    curl_easy_setopt(c, CURLOPT_WRITEFUNCTION, c_write_callback)
    curl_easy_setopt(c, CURLOPT_WRITEDATA, pointer_from_objref(r.response))

    # Perform request
    curl_easy_perform(c)

    # Gather response details
    r.response.total_time = get_total_total_time(c)

    return nothing
end

"""
    imap_request(url::String, username::String, password::String; kw...) -> IMAPResponse

Send a `url` IMAP request using `username` and `password`, then return a [`IMAPResponse`](@ref) object.

## Keyword arguments
| Name | Description | Default |
|:-----|:------------|:--------|
| `mailbox::Union{Nothing,String}` | Required mailbox. | `nothing` |
| `command` | Available IMAP commands after authentication. | `nothing` |
| `path::Union{Nothing,String}` | The specific path or criteria of the query. | `nothing` |
| `retry::Int64` | Number of retries. | `0` |
| `retry_delay::Real` | Delay after failed request. | `0.25` |
| `options...` | Another IMAP request [options](@ref IMAPOptions). |  |

## Examples

```julia-repl
julia> response = imap_request(
           "imaps://imap.gmail.com:993",
           "your_imap_username",
           "your_imap_password",
           mailbox = "INBOX",
           command = "SEARCH SINCE 09-Sep-2024",
       );

julia> imap_body(response) |> String |> print
* SEARCH 1399 1400 1401 1402 1403 1404 1405 1406 1407 1408 1409 1410
```
"""
function imap_request end

function imap_request(
    client::CurlClient,
    url::String,
    username::String,
    password::String;
    path::Union{Nothing,String} = nothing,
    mailbox::Union{Nothing,String} = nothing,
    command = nothing,
    retry::Int64 = 0,
    retry_delay::Real = 0.25,
    options...,
)::IMAPResponse
    with_retry(retry, retry_delay) do
        req = IMAPRequest(
            build_imap_url(url, mailbox, path),
            username,
            password,
            command,
            IMAPOptions(; options...),
            IMAPResponse(),
        )
        perform_request(client, req)
        req.response
    end
end

function imap_request(url::String, x...; kw...)
    return curl_open(c -> imap_request(c, url, x...; kw...))
end
# Preludex

An Elixir SDK for [Prelude](https://prelude.so/), a powerful API for phone verification.

## Installation

The package can be installed by adding `preludex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:preludex, "~> 0.1.0"}
  ]
end
```

## Configuration

The API token is configured at runtime through environment variables:

```bash
export PRELUDE_API_TOKEN="your-api-token"
```

For security reasons, we recommend using environment variables for sensitive data like API tokens. In production environments, the application will raise an error if the API token is not set.

## Usage

```
PRELUDE_API_TOKEN="your-api-token" make iex
```

```elixir
iex(1)> Preludex.Verify.create_or_retry("+34123456789")
{:ok,
 %{
   "id" => "...",
   "metadata" => %{},
   "method" => "message",
   "request_id" => "...",
   "status" => "success"
 }}
iex(2)> Preludex.Verify.check("3051", "+34123456789")
{:ok,
 %{
   "id" => "...",
   "metadata" => %{},
   "request_id" => "...",
   "status" => "success"
 }}
 ```

### Create a Verification Request

```elixir
alias Preludex.Verify

# Basic usage
{:ok, %{"status" => status}} = Verify.create_or_retry("+34123456789")

case status do
  "success" ->
    IO.puts("Verification code sent!")
  "retry" ->
    IO.puts("Please wait before requesting another code")
  "blocked" ->
    IO.puts("Phone number blocked")
end

# With options
{:ok, verification} = Verify.create_or_retry("+34123456789",
  # Customize verification settings
  code_size: 6,
  locale: "es-ES",
  
  # Enable auto-fill on Android
  app_realm: [
    platform: "android",
    hash: "your_app_hash_here"
  ]
)
```

### Check a Verification Code

```elixir
alias Preludex.Verify

{:ok, %{"status" => status}} = Verify.check("123456", "+30123456789")

case status do
  "success" ->
    IO.puts("Code verified successfully!")
  "failure" ->
    IO.puts("Invalid code")
  "expired_or_not_found" ->
    IO.puts("Code has expired or verification not found")
end
```

## Error Handling

The SDK uses `{:ok, result}` and `{:error, reason}` tuples for operation results. Possible errors include:

- `:bad_request` - Invalid parameters (400)
- `:unauthorized` - Invalid API token (401)
- `:forbidden` - Insufficient permissions (403)
- `:not_found` - Resource not found (404)
- `:unprocessable_entity` - Invalid request data (422)
- `:rate_limit_exceeded` - Too many requests (429)
- `:server_error` - Internal server error (500)
- `:network_error` - Connection or timeout issues

Example error handling:

```elixir
case Verify.create_or_retry(params) do
  {:ok, verification} ->
    # Handle successful verification request
    verification

  {:error, :unauthorized} ->
    # Handle invalid API token
    Logger.error("Invalid API token")

  {:error, :rate_limit_exceeded} ->
    # Handle rate limiting
    Process.sleep(1000)
    # Retry the request

  {:error, reason} ->
    # Handle other errors
    Logger.error("Error creating verification: #{inspect(reason)}")
end
```

## Development

### Version Management

The project uses Docker containers to provide a consistent development environment. The versions of Elixir and Erlang are managed through the `.versions` file:

```bash
# Show current versions
make versions

# Show current Elixir version
make version

# Override Elixir version for a single command
ELIXIR_VERSION=1.14.5 make compile
```

The version precedence is:
1. Environment variable (`ELIXIR_VERSION`)
2. `.versions` file
3. Default fallback (1.15.7)

## Documentation

- [API Documentation](https://docs.prelude.so/)
- [Hex Docs](https://hexdocs.pm/preludex) (coming soon)

## Testing

```bash
mix test
```

The SDK includes a comprehensive test suite. For integration tests, you'll need to set the `PRELUDE_API_TOKEN` environment variable with a valid test API token.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## About

`Preludex` is an unofficial Elixir SDK for Prelude. It is not affiliated with or endorsed by [Prelude](https://prelude.so/).

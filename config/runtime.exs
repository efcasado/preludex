import Config

# Configure Prelude API token
config :preludex,
  api_token: System.get_env("PRELUDE_API_TOKEN")

if config_env() == :prod do
  # Add any production-specific configuration here
  # For example, you might want to require the API token in production:
  if is_nil(System.get_env("PRELUDE_API_TOKEN")) do
    raise """
    Environment variable PRELUDE_API_TOKEN is missing.
    """
  end
end

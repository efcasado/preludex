import Config

# Configuration that doesn't require runtime information
# can be placed here. Runtime configuration should go in runtime.exs.

# Configure Tesla to use Finch adapter
config :tesla, :adapter, {Tesla.Adapter.Finch, name: Preludex.Finch}

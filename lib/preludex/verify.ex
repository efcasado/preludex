defmodule Preludex.Verify do
  @moduledoc """
  Handles verification operations through the Prelude API.
  """

  use Tesla
  require Logger

  @base_url "https://api.prelude.dev"

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.BearerAuth, token: api_token()

  @type create_options :: [
    app_realm: app_realm_options(),
    code_size: 4..8,
    custom_code: String.t(),
    locale: String.t(),
    sender_id: String.t(),
    template_id: String.t()
  ]

  @type app_realm_options :: [
    platform: String.t(),
    hash: String.t()
  ]

  @allowed_options [:app_realm, :code_size, :custom_code, :locale, :sender_id, :template_id]

  @doc """
  Creates a new verification request or retries an existing one.

  ## Parameters

    * `phone_number` - String, e.g., "+30123456789"
    * `opts` - Optional keyword list of options:
      * `:app_realm` - Automatically retrieve and fill OTP code on mobile apps (Android only)
        * `:platform` - String, currently only "android" is supported
        * `:hash` - String, Android SMS Retriever API hash code
      * `:code_size` - Integer between 4 and 8, defaults to Dashboard setting
      * `:custom_code` - String, custom code for OTP verification (requires approval from Prelude team)
      * `:locale` - String, BCP-47 formatted locale string
      * `:sender_id` - String, custom sender ID (needs to be enabled by Prelude team)
      * `:template_id` - String, verification settings template ID

  ## Examples

      # Basic usage
      {:ok, verification} = Verify.create_or_retry("+34123456789")

      # With options
      {:ok, verification} = Verify.create_or_retry("+34123456789",
        locale: "es-ES",
        code_size: 6
      )

  """
  @spec create_or_retry(String.t(), create_options()) :: {:ok, map()} | {:error, atom()}
  def create_or_retry(phone_number, opts \\ []) do
    options = Enum.filter(opts, fn {key, _value} -> key in @allowed_options end) |> Map.new()
    params = %{
      target: %{
        type: "phone_number",
        value: phone_number
      },
      options: options
    }

    # Handle app_realm separately since it's nested
    #params = case Keyword.get(opts, :app_realm) do
    #  nil -> params
    #  app_realm -> Map.put(params, :app_realm, Map.new(app_realm))
    #end

    # Add all other allowed options
    #params = Enum.reduce(opts, params, fn {key, value}, acc ->
    #  if key in @allowed_options and key != :app_realm and not is_nil(value) do
    #    Map.put(acc, key, value)
    #  else
    #    acc
    #  end
    #end)

    case post("/v2/verification", params) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}
      {:ok, %{status: 400} = resp} ->
        Logger.error(inspect(resp))
        {:error, :bad_request}
      {:ok, %{status: 401} = resp} ->
        Logger.error(inspect(resp))
        {:error, :unauthorized}
      {:ok, %{status: 403} = resp} ->
        Logger.error(inspect(resp))
        {:error, :forbidden}
      {:ok, %{status: 404} = resp} ->
        Logger.error(inspect(resp))
        {:error, :not_found}
      {:ok, %{status: 422} = resp} ->
        Logger.error(inspect(resp))
        {:error, :unprocessable_entity}
      {:ok, %{status: 429} = resp} ->
        Logger.warning(inspect(resp))
        {:error, :rate_limit_exceeded}
      {:ok, %{status: status} = resp} when status >= 500 ->
        Logger.error(inspect(resp))
        {:error, :server_error}
      {:error, _} = error ->
        Logger.error(inspect(error))
        {:error, :network_error}
      unexpected ->
        Logger.error(inspect(unexpected))
        {:error, :unknown_error}
    end
  end

  @doc """
  Checks a verification code for a given target.

  ## Parameters

    * `code` - String code to verify
    * `phone_number` - String, E.164 formatted phone number

  ## Examples

      {:ok, result} = Verification.check(
        "123456",
        "+30123456789"
      )

  """
  @spec check(String.t(), String.t()) :: {:ok, map()} | {:error, atom()}
  def check(code, phone_number) do
    params = %{
      code: code,
      target: %{
        type: "phone_number",
        value: phone_number
      }
    }

    case post("/v2/verification/check", params) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}
      {:ok, %{status: 400} = resp} ->
        Logger.error(inspect(resp))
        {:error, :bad_request}
      {:ok, %{status: 401} = resp} ->
        Logger.error(inspect(resp))
        {:error, :unauthorized}
      {:ok, %{status: 403} = resp} ->
        Logger.error(inspect(resp))
        {:error, :forbidden}
      {:ok, %{status: 404} = resp} ->
        Logger.error(inspect(resp))
        {:error, :not_found}
      {:ok, %{status: 422} = resp} ->
        Logger.error(inspect(resp))
        {:error, :unprocessable_entity}
      {:ok, %{status: 429} = resp} ->
        Logger.error(inspect(resp))
        {:error, :rate_limit_exceeded}
      {:ok, %{status: status} = resp} when status >= 500 ->
        Logger.error(inspect(resp))
        {:error, :server_error}
      {:error, _} = error ->
        Logger.error(inspect(error))
        {:error, :network_error}
      unexpected ->
        Logger.error(inspect(unexpected))
        {:error, :unknown_error}
    end
  end

  defp api_token do
    Application.get_env(:preludex, :api_token) ||
      raise "Prelude API token not configured. Add the following to your config:\n\n" <>
            "config :preludex, api_token: System.get_env(\"PRELUDE_API_TOKEN\")"
  end
end

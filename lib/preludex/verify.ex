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

  @doc """
  Creates a new verification request or retries an existing one.

  ## Parameters

    * `phone_number` - String, e.g., "+30123456789"

  ## Examples

      {:ok, verification} = Verification.create_or_retry("+30123456789")

  """
  @spec create_or_retry(String.t()) :: {:ok, map()} | {:error, atom()}
  def create_or_retry(phone_number) do
    params = %{
      target: %{
        type: "phone_number",
        value: phone_number
      }
    }
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

defmodule XmlEtl.Http do
  @moduledoc """
  HTTP-related functionality for the XML ETL process.
  """

  alias XmlEtl.Config

  @doc """
  Builds HTTP headers with authentication for API requests.
  """
  def build_headers(username, password) do
    [
      {"Content-Type", "application/xml"},
      {"Authorization", "Basic " <> Base.encode64("#{username}:#{password}")}
    ]
  end

  @doc """
  Sends a POST request to the specified URL with the given body and headers.
  Returns {:ok, response} or {:error, reason}.
  """
  def post_request(url, body, headers \\ []) do
    # Ensure URL is a valid string and properly encoded
    url =
      url
      |> URI.parse()
      |> Config.encode_uri_components()
      |> URI.to_string()

    # Use HTTPoison.post/3 instead of post! to handle errors gracefully
    case HTTPoison.post(url, body, headers) do
      {:ok, response} ->
        IO.puts("Request successful. Status code: #{response.status_code}")
        {:ok, response}

      {:error, error} ->
        IO.puts("Request failed: #{inspect(error)}")
        {:error, error}
    end
  end
end

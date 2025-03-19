defmodule XmlEtl.Config do
  @moduledoc """
  Configuration handling for the XML ETL process.
  """

  @doc """
  Parses command-line arguments and merges them with environment variables.
  Returns a structured configuration map.
  """
  def parse_args(args) do
    {opts, _args, _} =
      OptionParser.parse(
        args,
        switches: [url: :string, username: :string, password: :string, file: :string],
        aliases: [u: :url, n: :username, p: :password, f: :file]
      )

    # Get values from environment variables if not provided in command-line args
    url =
      opts
      |> Keyword.get(:url, System.get_env("API_URL", "http://localhost:4000/api"))
      |> URI.parse()
      |> encode_uri_components()
      |> URI.to_string()

    username = Keyword.get(opts, :username, System.get_env("API_USERNAME", "admin"))
    password = Keyword.get(opts, :password, System.get_env("API_PASSWORD", "admin"))
    file = Keyword.get(opts, :file, System.get_env("DEFAULT_XML_FILE"))

    connection_name =
      Keyword.get(opts, :connection_name, System.get_env("CONNECTION_NAME", "brahhh"))

    %{
      url: url,
      username: username,
      password: password,
      file: file,
      connection_name: connection_name
    }
  end

  @doc """
  Encodes URI components to handle special characters.
  """
  def encode_uri_components(%URI{} = uri) do
    path = if uri.path, do: URI.encode(uri.path), else: nil
    query = if uri.query, do: URI.encode_query(URI.decode_query(uri.query)), else: nil
    fragment = if uri.fragment, do: URI.encode(uri.fragment), else: nil

    %{uri | path: path, query: query, fragment: fragment}
  end
end

defmodule XmlEtl do
  @moduledoc """
  XML ETL process that reads from .env configuration.
  Provides functionality to extract XML data, transform if needed,
  and load it to an API endpoint.
  """

  alias XmlEtl.{Config, Http, XmlHandler}

  # Load .env file if in dev or test environment
  if Mix.env() in [:dev, :test] do
    Dotenv.load()
    Mix.shell().info("Loaded configuration from .env file")
  end

  @doc """
  Main entry point for the XML ETL process.
  Accepts command-line arguments to override default configuration.
  """
  def main(args \\ []) do
    IO.puts("Starting the ETL process")

    # Parse command-line arguments
    config = Config.parse_args(args)

    # Extract XML content
    xml_body = XmlHandler.get_xml_content(config.file)

    # Create authentication headers
    headers = Http.build_headers(config.username, config.password)

    # Send request to API
    response = Http.post_request(config.url, xml_body, headers)
    IO.inspect(response, label: "API Response")

    :ok
  end
end

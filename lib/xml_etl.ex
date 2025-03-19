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
  Main entry point for the ETL process.
  Accepts command-line arguments to override default configuration.
  """
  def main(args \\ []) do
    IO.puts("Starting the ETL process")

    wsdl_path =
      "https://eksz-test.fa.la1.oraclecloud.com/xmlpserver/services/v2/ReportService?wsdl"

    # Fetch WSDL content
    case HTTPoison.get(wsdl_path) do
      {:ok, %HTTPoison.Response{status_code: 200, body: wsdl_content}} ->
        {:ok, parsed_wsdl} = Soap.Wsdl.parse(wsdl_content, [])

        # Parse command-line arguments
        config = Config.parse_args(args)

        # Create SOAP request for getListOfSubjectArea
        soap_request = """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v2="http://xmlns.oracle.com/oxp/service/v2">
           <soapenv:Header/>
           <soapenv:Body>
              <v2:getListOfSubjectArea>
                 <v2:userID>#{config.username}</v2:userID>
                 <v2:password>#{config.password}</v2:password>
                 <v2:connectionName>#{config.connection_name}</v2:connectionName>
              </v2:getListOfSubjectArea>
           </soapenv:Body>
        </soapenv:Envelope>
        """

        # Create authentication headers
        headers = Http.build_headers(config.username, config.password)

        # Send SOAP request
        case Http.post_request(config.url, soap_request, headers) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
            # Check if response is gzip compressed
            if Enum.any?(headers, fn {k, v} ->
                 String.downcase(k) == "content-encoding" and String.downcase(v) == "gzip"
               end) do
              case :zlib.gunzip(body) do
                {:ok, decompressed} ->
                  IO.puts("Decompressed Response:")
                  IO.puts(decompressed)
                  :ok

                {:error, reason} ->
                  IO.puts("Failed to decompress response: #{inspect(reason)}")
                  {:error, :decompression_failed}
              end
            else
              IO.puts("Response:")
              IO.puts(body)
              :ok
            end

          {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
            IO.puts("Request failed with status code: #{status_code}")
            IO.puts("Response body: #{body}")
            {:error, :request_failed}

          {:error, %HTTPoison.Error{reason: reason}} ->
            IO.puts("Request failed: #{inspect(reason)}")
            {:error, :request_error}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Failed to fetch WSDL. Status code: #{status_code}")
        IO.puts("Response body: #{body}")
        {:error, :wsdl_fetch_failed}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Failed to fetch WSDL. Error: #{inspect(reason)}")
        {:error, :wsdl_fetch_error}
    end
  end
end

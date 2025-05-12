defmodule CodeHorizon.Templates.ThumbGenerator do
  @moduledoc """
  Service for generating thumbnails for templates using AI.

  This module leverages AI providers (Anthropic and Stability AI) to generate visual
  thumbnails based on template descriptions and color schemes.
  """

  alias CodeHorizon.Templates.Template

  # Default image dimensions for generated thumbnails
  @default_image_size "50x50"

  @doc """
  Generates a thumbnail for a template based on its description and colors.

  ## Parameters
    * template - The Template struct containing description and color information
    * opts - Optional parameters map, can include :size for custom dimensions

  ## Returns
    * `{:ok, path}` - Success with the public path to the generated thumbnail
    * `{:error, reason}` - Error with description of what went wrong
  """
  @spec generate_thumbnail(Template.t()) :: {:ok, String.t()} | {:error, String.t()}
  def generate_thumbnail(%Template{} = template, opts \\ %{}) do
    # Select the appropriate AI model based on environment
    model = get_model_by_env()

    # Generate the image and save it if successful
    case request_image_generation(template, model, opts) do
      {:ok, image_binary} ->
        save_thumbnail(template, image_binary)

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Handles the core image generation process by preparing the API request
  # and processing the response from the AI provider
  defp request_image_generation(template, model, opts) do
    # Create appropriate prompt from template data
    prompt = build_prompt(template)
    # Extract size from options or use default
    size = Map.get(opts, :size, @default_image_size)

    # Configure HTTP client with proper authentication
    client =
      Tesla.client([
        {Tesla.Middleware.BaseUrl, get_api_base_url(model)},
        {Tesla.Middleware.Headers, [{"authorization", "Bearer #{get_api_key(model)}"}]},
        {Tesla.Middleware.JSON}
      ])

    # Make the API request and process the response
    case make_image_request(client, model, prompt, size) do
      {:ok, %{body: body}} ->
        extract_image_from_response(model, body)

      error ->
        {:error, "Failed to generate image: #{inspect(error)}"}
    end
  end

  # Makes an API request to Anthropic Claude for image generation
  # Formats the request according to Anthropic's API specifications
  defp make_image_request(client, :anthropic, prompt, size) do
    Tesla.post(client, "/v1/images/generations", %{
      "prompt" => prompt,
      "width" => elem(parse_size(size), 0),
      "height" => elem(parse_size(size), 1)
    })
  end

  # Makes an API request to Stability AI for image generation
  # Formats the request according to Stability AI's API specifications
  defp make_image_request(client, :stability_ai, prompt, size) do
    {width, height} = parse_size(size)

    Tesla.post(client, "/v1/generation/text-to-image", %{
      "text_prompts" => [%{"text" => prompt}],
      "width" => width,
      "height" => height
    })
  end

  # Utility function to parse "WIDTHxHEIGHT" format into a tuple of integers
  defp parse_size(size) do
    [width, height] = String.split(size, "x")
    {String.to_integer(width), String.to_integer(height)}
  end

  # Extracts image binary data from OpenAI API response format
  defp extract_image_from_response(:openai, %{"data" => [%{"b64_json" => base64_img} | _]}) do
    {:ok, Base.decode64!(base64_img)}
  end

  # Extracts image binary data from Anthropic API response format
  defp extract_image_from_response(:anthropic, response) do
    case response do
      %{"images" => [base64_img | _]} -> {:ok, Base.decode64!(base64_img)}
      _ -> {:error, "Invalid response format"}
    end
  end

  # Extracts image binary data from Stability AI API response format
  defp extract_image_from_response(:stability_ai, %{"artifacts" => [%{"base64" => base64_img} | _]}) do
    {:ok, Base.decode64!(base64_img)}
  end

  # Fallback for unsupported models or invalid response formats
  defp extract_image_from_response(_, _) do
    {:error, "Unsupported model or invalid response"}
  end

  # Constructs a descriptive prompt for the AI model based on template attributes
  # Includes relevant details about style, colors, and description
  defp build_prompt(%Template{} = template) do
    colors = Enum.join([template.primary_color, template.accent_color], ", ")

    """
    Create a minimalist thumbnail image for a web template with the following description:
    #{template.description}.
    Use these colors: #{colors}.
    The style should be modern, clean, and visually appealing for a web interface.
    """
  end

  # Saves the generated image to the filesystem and returns a public URL path
  # Creates directory structure if it doesn't exist
  defp save_thumbnail(template, image_binary) do
    filename = "template_thumb_#{template.id}.png"
    filepath = Path.join(["priv", "static", "uploads", "thumbs", filename])

    # Ensure directory exists
    File.mkdir_p!(Path.dirname(filepath))

    # Write image to file and return public path or error
    case File.write(filepath, image_binary) do
      :ok ->
        public_path = "/uploads/thumbs/#{filename}"
        {:ok, public_path}

      error ->
        {:error, "Failed to save thumbnail: #{inspect(error)}"}
    end
  end

  # Selects the appropriate AI model based on current environment
  # Uses production models in production and cost-effective alternatives in other environments
  defp get_model_by_env do
    case Application.get_env(:my_app, :environment) do
      :prod -> :anthropic
      :staging -> :stability_ai
      # Default for development and test
      _ -> :stability_ai
    end
  end

  # Returns the base URL for the specified AI provider's API
  defp get_api_base_url(:anthropic), do: "https://api.anthropic.com"
  defp get_api_base_url(:stability_ai), do: "https://api.stability.ai"

  # Retrieves API key for the specified AI provider
  # First checks environment variables, then falls back to application config
  defp get_api_key(model) do
    case model do
      :anthropic -> System.get_env("ANTHROPIC_API_KEY") || Application.get_env(:my_app, :anthropic_api_key)
      :stability_ai -> System.get_env("STABILITY_API_KEY") || Application.get_env(:my_app, :stability_api_key)
    end
  end
end

module OembedHelper
  # Embed a URL using OEmbed
  # Usage: <%= embed_url("https://www.youtube.com/watch?v=dQw4w9WgXcQ") %>
  def embed_url(url, options = {})
    return "" if url.blank?

    begin
      resource = OEmbed::Providers.get(url, options)
      resource.html.html_safe
    rescue OEmbed::NotFound
      content_tag(:div, class: "embed-error") do
        content_tag(:p, "Unable to embed: #{url}")
      end
    rescue => e
      Rails.logger.error "OEmbed error: #{e.message}"
      content_tag(:div, class: "embed-error") do
        link_to url, url, target: "_blank", rel: "noopener"
      end
    end
  end

  # Embed YouTube video
  def embed_youtube(url_or_id, width: 560, height: 315)
    video_id = extract_youtube_id(url_or_id)
    return "" unless video_id

    content_tag(:iframe, nil,
      width: width,
      height: height,
      src: "https://www.youtube.com/embed/#{video_id}",
      frameborder: 0,
      allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
      allowfullscreen: true
    )
  end

  # Embed Vimeo video
  def embed_vimeo(url_or_id, width: 640, height: 360)
    video_id = extract_vimeo_id(url_or_id)
    return "" unless video_id

    content_tag(:iframe, nil,
      src: "https://player.vimeo.com/video/#{video_id}",
      width: width,
      height: height,
      frameborder: 0,
      allow: "autoplay; fullscreen; picture-in-picture",
      allowfullscreen: true
    )
  end

  private

  def extract_youtube_id(url_or_id)
    return url_or_id unless url_or_id.include?("youtube.com") || url_or_id.include?("youtu.be")

    if url_or_id.include?("youtube.com/watch?v=")
      URI.parse(url_or_id).query.split("&").find { |p| p.start_with?("v=") }&.split("=")&.last
    elsif url_or_id.include?("youtu.be/")
      url_or_id.split("youtu.be/").last.split("?").first
    end
  end

  def extract_vimeo_id(url_or_id)
    return url_or_id unless url_or_id.include?("vimeo.com")
    url_or_id.split("vimeo.com/").last.split("?").first
  end
end

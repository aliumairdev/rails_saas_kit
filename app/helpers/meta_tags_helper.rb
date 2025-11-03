module MetaTagsHelper
  def meta_title(title = nil)
    if title.present?
      content_for(:meta_title, title)
    else
      content_for?(:meta_title) ? content_for(:meta_title) : "Review Collector - Automate Your Customer Review Requests"
    end
  end

  def meta_description(description = nil)
    if description.present?
      content_for(:meta_description, description)
    else
      content_for?(:meta_description) ? content_for(:meta_description) : "Automate your customer review collection process. Send review requests via email, track responses, and boost your online reputation."
    end
  end

  def meta_image(image = nil)
    if image.present?
      content_for(:meta_image, image)
    else
      content_for?(:meta_image) ? content_for(:meta_image) : asset_url("logo.png")
    end
  end

  def meta_tags
    tags = []

    # Basic meta tags
    tags << tag.meta(name: "description", content: meta_description)
    tags << tag.meta(name: "keywords", content: "review collection, customer reviews, review requests, email automation, reputation management")

    # Open Graph tags
    tags << tag.meta(property: "og:title", content: meta_title)
    tags << tag.meta(property: "og:description", content: meta_description)
    tags << tag.meta(property: "og:image", content: meta_image)
    tags << tag.meta(property: "og:url", content: request.original_url)
    tags << tag.meta(property: "og:type", content: "website")

    # Twitter Card tags
    tags << tag.meta(name: "twitter:card", content: "summary_large_image")
    tags << tag.meta(name: "twitter:title", content: meta_title)
    tags << tag.meta(name: "twitter:description", content: meta_description)
    tags << tag.meta(name: "twitter:image", content: meta_image)

    safe_join(tags, "\n")
  end
end

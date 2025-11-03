class ApiClientGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  class_option :url, type: :string, desc: "Base URL for the API", default: nil
  class_option :methods, type: :array, desc: "Methods to generate (format: name:type)", default: []

  def create_client_file
    template "client.rb.tt", File.join("app/clients", class_path, "#{file_name}_client.rb")
  end

  def create_test_file
    template "client_test.rb.tt", File.join("test/clients", class_path, "#{file_name}_client_test.rb")
  end

  private

  def base_url
    options[:url] || "https://api.example.com"
  end

  def methods_to_generate
    options[:methods].map do |method_spec|
      name, type = method_spec.split(":")
      {
        name: name,
        type: type || "index"
      }
    end
  end

  def http_method_for_type(type)
    case type
    when "index", "show"
      "get"
    when "create"
      "post"
    when "update"
      "put"
    when "destroy"
      "delete"
    else
      "get"
    end
  end

  def method_signature_for_type(name, type)
    case type
    when "show", "update", "destroy"
      "def #{name}(id)\n"
    when "create"
      "def #{name}(**params)\n"
    else
      "def #{name}\n"
    end
  end

  def method_params_for_type(type)
    case type
    when "show", "destroy"
      '"/#{id}"'
    when "create", "update"
      'body: params'
    else
      '""'
    end
  end
end

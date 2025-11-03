module TrixSystemTestHelper
  # Fill in a Trix editor with content
  # Usage: fill_in_trix_editor "post_content", with: "Hello world"
  def fill_in_trix_editor(id, with:)
    find(:xpath, "//trix-editor[@input='#{id}']").click.set(with)
  end

  # Assert content in Trix editor
  def assert_trix_editor_content(id, text)
    editor = find(:xpath, "//trix-editor[@input='#{id}']")
    assert_includes editor.text, text
  end
end

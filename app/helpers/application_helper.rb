require 'redcarpet'
module ApplicationHelper
    def render_markdown(text)
        renderer = Redcarpet::Render::HTML.new(
        filter_html: true,  # Prevent raw HTML in Markdown from being rendered
        hard_wrap: true     # Add <br> tags for line breaks
        )
        markdown = Redcarpet::Markdown.new(renderer, {
            autolink: true,               # Automatically link URLs
            tables: true,                 # Enable tables
            fenced_code_blocks: true,     # Enable fenced code blocks
            strikethrough: true,          # Enable strikethrough using ~~
            lax_spacing: true,            # Allow spacing between paragraphs
            space_after_headers: true,    # Allow space after header `# Header`
            superscript: true             # Enable superscripts (e.g., 2^nd^)
        })
        markdown.render(text).html_safe
        #Sanitize.fragment(raw_html, Sanitize::Config::BASIC)
      end
end

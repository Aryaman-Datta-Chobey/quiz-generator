require 'kramdown'
require 'kramdown-parser-gfm'
#Dummy comment 
module ApplicationHelper
  def render_markdown(text)
    # Configure Kramdown to use GFM and MathJax for LaTeX math rendering
    options = {
      input: 'GFM',                # Use GFM parser for GitHub Flavored Markdown
      hard_wrap: true,             # Add <br> tags for line breaks in paragraphs
      syntax_highlighter: nil,     # Disable syntax highlighting (use your choice if needed)
      math_engine: 'mathjax',      # Use MathJax for LaTeX math rendering
      gfm_quirks: 'paragraph_end'  # Handle GFM quirks (optional)
    }
    # Parse and convert the Markdown to HTML
    html = Kramdown::Document.new(text, options).to_html
    html.html_safe # Mark as safe for Rails views
  end
end
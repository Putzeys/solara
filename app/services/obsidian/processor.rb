module Obsidian
  class Processor
    class Error < StandardError; end

    DEFAULT_PROMPT = <<~PROMPT
      You are a personal knowledge management assistant. Analyze the following content and organize it for my Obsidian vault.

      Content: {{content}}
      Source: {{source}}
      Channel: {{channel}}
      Context: {{context}}
      Date: {{date}}

      Return valid JSON with this structure:
      {
        "title": "Clean, descriptive title for the note",
        "folder": "One of: inbox, aprendizados, projetos, diario, referencias, fases",
        "tags": ["relevant", "tags"],
        "body": "Well-organized markdown content with ## headings, bullet points, and connections",
        "connections": ["Related Topic 1", "Related Topic 2"]
      }
    PROMPT

    def initialize(user)
      @user = user
      @llm = Obsidian::LlmClient.new(user)
      @writer = Obsidian::Writer.new(user)
    end

    def process(content:, source: "capture", channel: nil, context: nil)
      raise Error, "LLM not configured" unless @llm.configured?
      raise Error, "Obsidian vault not configured" unless @writer.configured?

      prompt = build_prompt(content, source, channel, context)
      llm_response = @llm.chat(prompt)

      if @user.obsidian_response_format == "json"
        write_from_json(llm_response)
      else
        write_raw_markdown(llm_response, content)
      end
    end

    private

    def build_prompt(content, source, channel, context)
      template = @user.obsidian_prompt_template.presence || DEFAULT_PROMPT

      template
        .gsub("{{content}}", content.to_s)
        .gsub("{{source}}", source.to_s)
        .gsub("{{channel}}", channel.to_s)
        .gsub("{{context}}", context.to_s)
        .gsub("{{date}}", Date.current.to_s)
    end

    def write_from_json(response)
      # Extract JSON from response (handle markdown code blocks)
      json_str = response[/\{.*\}/m]
      raise Error, "LLM did not return valid JSON" unless json_str

      data = JSON.parse(json_str)

      title = data["title"] || "Untitled"
      folder = data["folder"] || "inbox"
      tags = Array(data["tags"])
      body = data["body"] || ""
      connections = Array(data["connections"])

      # Add wikilinks for connections
      if connections.any?
        body += "\n\n## Related\n"
        connections.each { |c| body += "- [[#{c}]]\n" }
      end

      frontmatter = {
        "created" => Time.current.iso8601,
        "source" => "solara",
        "tags" => tags
      }

      @writer.write(folder: folder, filename: title, content: body, frontmatter: frontmatter)
    end

    def write_raw_markdown(response, original_content)
      # Extract title from first heading or first line
      title = response[/^#\s+(.+)/, 1] || original_content.to_s.truncate(60, omission: "")
      title = title.strip

      frontmatter = {
        "created" => Time.current.iso8601,
        "source" => "solara"
      }

      @writer.write(folder: "inbox", filename: title, content: response, frontmatter: frontmatter)
    end
  end
end

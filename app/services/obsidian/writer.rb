require "fileutils"

module Obsidian
  class Writer
    class Error < StandardError; end

    def initialize(user)
      @vault_path = user.obsidian_vault_path
    end

    def configured?
      @vault_path.present? && Dir.exist?(@vault_path)
    end

    def write(folder:, filename:, content:, frontmatter: {})
      raise Error, "Vault path not configured or doesn't exist" unless configured?

      sanitized_folder = sanitize_path(folder)
      sanitized_filename = sanitize_filename(filename)

      dir = File.join(@vault_path, sanitized_folder)
      file_path = File.join(dir, "#{sanitized_filename}.md")

      # Prevent path traversal: ensure resolved path stays inside vault
      resolved_dir = File.expand_path(dir)
      resolved_vault = File.expand_path(@vault_path)
      unless resolved_dir.start_with?("#{resolved_vault}/") || resolved_dir == resolved_vault
        raise Error, "Path traversal detected: folder '#{folder}' resolves outside vault"
      end

      FileUtils.mkdir_p(resolved_dir)

      md = build_markdown(content, frontmatter)
      File.write(File.join(resolved_dir, "#{sanitized_filename}.md"), md)

      # Return relative path from vault root
      File.join(sanitized_folder, "#{sanitized_filename}.md")
    end

    def search(query, limit: 20)
      raise Error, "Vault path not configured or doesn't exist" unless configured?

      results = []
      query_down = query.downcase
      resolved_vault = File.expand_path(@vault_path)

      Dir.glob(File.join(resolved_vault, "**", "*.md")).each do |file|
        relative = file.sub("#{resolved_vault}/", "")
        name = File.basename(file, ".md")

        # Search in filename
        name_match = name.downcase.include?(query_down)

        # Search in content (first 5000 chars for performance)
        content = File.read(file, 5000) rescue next
        content_match = content.downcase.include?(query_down)

        next unless name_match || content_match

        # Extract a snippet around the match
        snippet = extract_snippet(content, query_down)

        results << {
          path: relative,
          name: name,
          snippet: snippet,
          modified_at: File.mtime(file)
        }

        break if results.size >= limit
      end

      results.sort_by { |r| r[:modified_at] }.reverse
    end

    private

    def build_markdown(content, frontmatter)
      parts = []

      if frontmatter.any?
        parts << "---"
        frontmatter.each do |key, value|
          if value.is_a?(Array)
            parts << "#{key}:"
            value.each { |v| parts << "  - #{v}" }
          else
            parts << "#{key}: #{value}"
          end
        end
        parts << "---"
        parts << ""
      end

      parts << content
      parts.join("\n")
    end

    def sanitize_path(path)
      path.to_s.gsub(/[^\w\s\-\/]/, "").strip.gsub(/\s+/, " ")
    end

    def sanitize_filename(name)
      name.to_s
        .gsub(/[^\w\s\-]/, "")
        .strip
        .gsub(/\s+/, " ")
        .truncate(100, omission: "")
    end

    def extract_snippet(content, query)
      # Strip frontmatter
      body = content.sub(/\A---.*?---\s*/m, "")
      idx = body.downcase.index(query)
      return body.truncate(150) unless idx

      start = [ idx - 60, 0 ].max
      snippet = body[start, 150]
      "...#{snippet.strip}..."
    end
  end
end

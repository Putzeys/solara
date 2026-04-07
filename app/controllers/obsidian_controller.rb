class ObsidianController < ApplicationController
  def index
  end

  def capture
    content = params[:content].to_s.strip

    if content.blank?
      redirect_to obsidian_path, alert: "Content cannot be empty."
      return
    end

    processor = Obsidian::Processor.new(current_user)
    @result_path = processor.process(content: content, source: "capture")

    redirect_to obsidian_path, notice: "Note saved to #{@result_path}"
  rescue Obsidian::Processor::Error, Obsidian::LlmClient::Error, Obsidian::Writer::Error => e
    redirect_to obsidian_path, alert: e.message
  end

  def search
    @query = params[:q].to_s.strip

    if @query.blank?
      @results = []
    else
      writer = Obsidian::Writer.new(current_user)
      @results = writer.search(@query)
    end

    render :index
  rescue Obsidian::Writer::Error => e
    @results = []
    @search_error = e.message
    render :index
  end

  def test_connection
    llm = Obsidian::LlmClient.new(current_user)
    llm.test_connection

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("obsidian-test-result",
          "<div id='obsidian-test-result' class='mt-2 text-sm text-emerald-600 flex items-center gap-1.5'>
            <svg class='w-4 h-4' fill='currentColor' viewBox='0 0 20 20'><path fill-rule='evenodd' d='M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z' clip-rule='evenodd'/></svg>
            Connected! LLM responded successfully.
          </div>".html_safe
        )
      }
      format.html { redirect_to settings_path, notice: "LLM connection successful!" }
    end
  rescue Obsidian::LlmClient::Error => e
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("obsidian-test-result",
          "<div id='obsidian-test-result' class='mt-2 text-sm text-red-600 flex items-center gap-1.5'>
            <svg class='w-4 h-4' fill='currentColor' viewBox='0 0 20 20'><path fill-rule='evenodd' d='M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z' clip-rule='evenodd'/></svg>
            #{ERB::Util.html_escape(e.message)}
          </div>".html_safe
        )
      }
      format.html { redirect_to settings_path, alert: e.message }
    end
  end
end

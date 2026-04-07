class ObsidianSyncJob < ApplicationJob
  queue_as :default

  def perform(user_id, content:, source: "capture", channel: nil, context: nil)
    user = User.find(user_id)
    processor = Obsidian::Processor.new(user)

    result_path = processor.process(
      content: content,
      source: source,
      channel: channel,
      context: context
    )

    Rails.logger.info "[Obsidian] Wrote note to: #{result_path}"
    result_path
  rescue Obsidian::Processor::Error, Obsidian::LlmClient::Error, Obsidian::Writer::Error => e
    Rails.logger.error "[Obsidian] Sync failed: #{e.message}"
    raise
  end
end

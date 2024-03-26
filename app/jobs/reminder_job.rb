class ReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder_id)
    reminder = Reminder.find_by(id: reminder_id)
    return unless reminder

    message = {
      type: 'text',
      text: "#{reminder.title}の時間です"
    }
    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
    response = client.push_message(reminder.user.line_user_id, message)
    Rails.logger.info("Sent reminder: #{response}")
  end
end
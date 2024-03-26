class LineBotController < ApplicationController
  require 'line/bot'
  skip_before_action :verify_authenticity_token, only: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each do |event|
      if event.type == Line::Bot::Event::MessageType::Text
        handle_text_message(event)
      end
    end

    head :ok
  end

  private

  def handle_text_message(event)
    user_id = event['source']['userId']
    user = User.find_or_create_by(line_user_id: user_id)
    user_message = event.message['text']
  
    if user_message.downcase == 'キャンセル'
      user.update(status: nil, temporary_data: nil)
      cancel_operation(event['replyToken'])
    elsif user.status == 'awaiting_time'
      process_user_message(user, user_message, event['replyToken'])
    else
      start_reminder_setting(user, user_message, event['replyToken'])
    end
  end
  
  def start_reminder_setting(user, text, reply_token)
    user.update(status: 'awaiting_time', temporary_data: text)
    ask_for_time(reply_token)
  end

  def process_user_message(user, text, reply_token)
    parsed_datetime = parse_message(text)
    if parsed_datetime
      set_and_confirm_reminder(user, user.temporary_data, parsed_datetime, reply_token)
      user.update(status: nil, temporary_data: nil)
    else
      send_error_message(reply_token, "日時情報を正しく認識できませんでした")
    end
  end

  def set_and_confirm_reminder(user, title, reminder_time, reply_token)
    reminder = ReminderService.create(user: user, title: title, reminder_time: reminder_time)
    
    if reminder.persisted?
      confirm_reminder_set(reply_token, title, reminder.reminder_time)
    else
      send_error_message(reply_token, "リマインダーを設定できませんでした")
    end
  end

  def cancel_operation(reply_token)
    message = {
      type: 'text',
      text: '操作をキャンセルしました'
    }
    client.reply_message(reply_token, message)
  end
  
  def ask_for_time(reply_token)
    message = {
      type: 'text',
      text: 'いつリマインドしますか？'
    }
    client.reply_message(reply_token, message)
  end

  def confirm_reminder_set(reply_token, title, parsed_datetime)
    message = {
      type: 'text',
      text: "#{parsed_datetime.strftime('%Y年%m月%d日%H時%M分')}に「#{title}」をリマインドします"
    }
    client.reply_message(reply_token, message)
  end

  def send_error_message(reply_token, message_text)
    message = {
      type: 'text',
      text: message_text
    }
    client.reply_message(reply_token, message)
  end

  def parse_message(message)
    parsed_datetime_str = NaturalLanguageProcessor.parse_time_from_text(message)
    if parsed_datetime_str.present?
      parsed_datetime = DateTime.parse(parsed_datetime_str)
      return parsed_datetime
    else
      return nil
    end
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_MESSAGING_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
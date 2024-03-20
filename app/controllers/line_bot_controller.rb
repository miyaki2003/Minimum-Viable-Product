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

  def handle_text_message(line_event)
    user_id = line_event['source']['userId']
    user = User.find_or_create_by(line_user_id: user_id)
    user_message = line_event.message['text']

    if user_message.downcase == 'キャンセル'
      clear_user_status(user)
      cancel_operation(line_event['replyToken'])
      return
    end

  case get_user_status(user)
  when nil, '', 'awaiting_title'
    set_user_status(user, 'awaiting_time', user_message)
    ask_for_time(line_event['replyToken'])
  when 'awaiting_time'
    process_datetime_input(user, user_message, line_event)
  end
end
  
  def get_user_status(user)
    user.status
  end

  def set_user_status(user, status, temporary_data = nil)
    user.update(status: status, temporary_data: temporary_data)
  end

  def get_temporary_data(user)
    user.temporary_data
  end

  def process_datetime_input(user, time_text, line_event)
    parsed_datetime_str = NaturalLanguageProcessor.parse_time_from_text(time_text)
  
    if parsed_datetime_str.present?
      parsed_datetime = Time.zone.parse(parsed_datetime_str)
      user.line_events.create(title: get_temporary_data(user), reminder_time: parsed_datetime)
      confirm_reminder_set(line_event['replyToken'], get_temporary_data(user), parsed_datetime)
      clear_user_status(user)
    else
      send_error_message(line_event['replyToken'], "日時情報を正しく認識できませんでした。もう一度入力してください。")
    end
  end


  def clear_user_status(user)
    user.update(status: nil, temporary_data: nil)
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

  def cancel_operation(reply_token)
    message = {
      type: 'text',
      text: '操作をキャンセルしました。'
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


  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_MESSAGING_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
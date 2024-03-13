class LineBotController < ApplicationController
  require 'line/bot'
  skip_before_action :verify_authenticity_token, only: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end

    events = client.parse_events_from(body)

    events.each do |event|
      if event.type == Line::Bot::Event::MessageType::Text
        user_message = event.message['text']
        reply_text = ""

        if user_message == "会議"
          reply_text = "いつリマインドしますか？"
        else
          reply_text = "理解できませんでした"
        end

        message = {
          type: 'text',
          text: reply_text
        }
        client.reply_message(event['replyToken'], message)
      end
    end

    head :ok
  end



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
    user_message = line_event.message['text']
    reply_text = parse_message(user_message)

  if reply_text
    LineEvent.create(user_id: user_id, message: reply_text[:message], reminder_time: reply_text[:time])
    response_message = "リマインドを設定しました: #{reply_text[:message]} - #{reply_text[:time].strftime('%Y-%m-%d %H:%M')}"
  else
    response_message = "メッセージを理解できませんでした。"
  end

  message = {
    type: 'text',
    text: response_message
  }
  client.reply_message(line_event['replyToken'], message)
end
  
  def parse_time(time_str)
  end



  

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_MESSAGING_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
require 'net/http'
require 'uri'
require 'json'
require 'chronic'

class NaturalLanguageProcessor
  def self.translate_japanese_to_english(text)
    if text =~ /今日の(\d+)時(\d*)分?/
      hour = $1.to_i
      minutes = $2.empty? ? '0' : $2
      "today at #{format('%d', hour)}:#{minutes}"
    end
  end

  def self.parse_time_from_text(text)
    translated_text = translate_japanese_to_english(text)
    datetime = Chronic.parse(translated_text)
    if datetime
      datetime.strftime('%Y-%m-%d %H:%M')
    else
      nil
    end
  end
end

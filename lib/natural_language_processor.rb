require 'google/cloud/language'

class NaturalLanguageProcessor
  def self.parse_time_from_text(text)
    language_service = Google::Cloud::Language.language_service

    document = { content: text, type: :PLAIN_TEXT }
    response = language_service.analyze_entities document: document

    datetime_entity = response.entities.find { |entity| entity.type == :DATE_TIME }
    datetime_entity&.metadata['value']
  end
end
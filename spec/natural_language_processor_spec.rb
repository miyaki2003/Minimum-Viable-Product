require 'spec_helper'
require_relative '../lib/natural_language_processor'

RSpec.describe NaturalLanguageProcessor do
  describe '.parse_time_from_text' do
    context 'when the text contains a date or time' do
      it 'returns the recognized date or time as a string' do
        text = "Let's meet tomorrow at 3pm"
        expect(NaturalLanguageProcessor.parse_time_from_text(text)).to eq('2024-03-14T15:00:00Z') # 期待される日時の値はテスト環境によって異なります
      end
    end

    context 'when the text does not contain a date or time' do
      it 'returns nil' do
        text = "This text does not contain a date or time"
        expect(NaturalLanguageProcessor.parse_time_from_text(text)).to be_nil
      end
    end

    context 'when an error occurs with the API' do
      it 'raises an error' do
        allow(Google::Cloud::Language).to receive(:language_service).and_raise(StandardError, 'API Error')

        text = "This text should trigger an API error"
        expect { NaturalLanguageProcessor.parse_time_from_text(text) }.to raise_error(StandardError, 'API Error')
      end
    end
  end
end

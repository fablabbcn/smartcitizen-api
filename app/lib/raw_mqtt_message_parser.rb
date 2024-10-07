require_relative "../grammars/raw_message"

class RawMqttMessageParser
  def initialize
    @parser = RawMessageParser.new
  end

  def parse(message)
    parser.parse(self.convert_to_ascii(message.strip))&.to_hash
  end

  private

  def convert_to_ascii(string)
    string.encode("US-ASCII", invalid: :replace, undef: :replace, replace: "")
  end

  attr_reader :parser
end

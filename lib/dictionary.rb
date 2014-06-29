module Dictionary
  @@dictionary = ActiveSupport::JSON.decode(File.read("db/dictionary_html.json"))

  def self.query(name)
    @@dictionary[name]
  end
end

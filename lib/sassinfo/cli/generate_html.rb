module Sassinfo
  # The HTML generator
  class Cli::GenerateHtml < Thor::Group
    include Thor::Actions

    argument :info

    def self.source_root
      File.dirname(__FILE__) + "/../../../template"
    end

    def go
      self.destination_root = options[:output_path]

      directory("static")

      template("index.html.erb", "index.html")

      puts "gonna do some stuff! #{info.inspect}"
    end
  end
end

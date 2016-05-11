require "thor"
require "thor/group"
require "json"

require File.dirname(__FILE__) + "/../sassinfo"
require File.dirname(__FILE__) + "/sass/info"

module Sassinfo
  # CLI class
  class Cli < Thor::Group
    desc "Generates sassinfo for file"

    class_option :format, aliases: "-f", type: :string, default: "html"

    class_option :load_path, aliases: "-I", type: :array

    class_option :document_root_path, aliases: "-d", type: :string

    class_option :output_path, aliases: "-o", type: :string, default: "out"

    argument :file

    def generate
      unless File.exist?(file)
        puts "No such file #{file}"
        exit
      end

      info_options = {
        document_root_path: options[:document_root_path] || "."
      }

      info = Sassinfo::Sass::Info.new(
        file,
        nil,
        info_options
      )

      case options[:format]
      when "json"
        format_json(info)
      else
        invoke Sassinfo::Cli::GenerateHtml, [info], options
      end
    end

    protected

    def format_json(info)
      data = {
        colors: info.colors,
        variables: info.variables,
        fonts: info.fonts,
        mixins: info.mixins
      }

      puts JSON.pretty_generate(data)
    end
  end
end

require File.dirname(__FILE__) + "/cli/generate_html"

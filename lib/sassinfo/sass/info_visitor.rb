require "pathname"

module Sassinfo::Sass
  # InfoVisitor
  #
  # The InfoVistor finds info on:
  #
  # - Variables
  # - Mixins
  # - Fonts
  class InfoVisitor < Sass::Tree::Visitors::Perform
    public :visit, :with_environment

    attr_reader :variables, :mixins, :fonts, :root_env

    def initialize(environment)
      super(environment)
      @variables = {}
      @mixins = {}
      @fonts = {}

      @root_env = nil
    end

    # Hack to expose the root environment
    def visit_children(parent)
      new_env = Sass::Environment.new(@environment, parent.options)

      @root_env = new_env if parent.is_a? Sass::Tree::RootNode

      with_environment new_env do
        parent.children = parent.children.map { |c| visit(c) }.flatten
        parent
      end
    end

    def visit_prop(node)
      find_variable_use_recursive([node.value])

      super(node)
    end

    def visit_variable(node)
      r = super
      env = @environment
      env = env.global_env if node.global

      # Clunky way to skip non-global definitions
      return r unless top_level_env?(env)

      value = env.var(node.name)

      store_variable(node.name.to_s, value)

      r
    end

    def visit_mixindef(node)
      r = super

      store_mixin(node)

      r
    end

    def visit_mixin(node)
      mark_as_used(@mixins, node.name)
      super(node)
    end

    def visit_directive(node)
      r = super

      store_font(node) if node.name == "@font-face"

      r
    end

    protected

    def top_level_env?(env)
      env == @root_env
    end

    def find_variable_use_recursive(values)
      values.each do |child|
        case child
        when Sass::Script::Tree::Variable
          mark_as_used(@variables, child.name)
        else
          find_variable_use_recursive(child.children)
        end
      end
    end

    def mark_as_used(hash, name)
      hash[name] ||= {}

      if hash[name].key?(:used)
        hash[name][:used] += 1
      else
        hash[name][:used] = 1
      end
    end

    def store_font(node)
      data = {
        font_family: "",
        font_weight: "regular",
        _node: node.deep_copy
      }

      node.children.each do |n|
        next unless n.is_a?(Sass::Tree::PropNode)
        case n.resolved_name
        when "font-family"
          data[:font_family] = n.resolved_value
        when "font-weight"
          data[:font_weight] = n.resolved_value
        end
      end

      key = [data[:font_family], data[:font_weight]].join("-")
      @fonts[key] ||= {}
      @fonts[key].update(data)
      @fonts
    end

    def store_mixin(node)
      key = node.name
      @mixins[key] ||= {}
      @mixins[key][:used] = 0 unless @mixins[key].key?(:used)
      @mixins[key][:css] = nil

      if node.args.any? || node.splat || node.has_content
        @mixins[key][:has_params] = true
      else
        @mixins[key][:has_params] = false
      end

      @mixins
    end

    def store_variable(key, value)
      @variables[key] ||= {}
      @variables[key][:used] = 0 unless @variables[key].key?(:used)
      @variables[key].update(get_value(value))
      @variables
    end

    # rubocop:disable Metrics/MethodLength
    def get_value(value)
      case value
      when Sass::Script::Value::Map
        {
          value: get_map_values(value)
        }
      when Sass::Script::Value::List
        {
          value: get_list_values(value)
        }
      when Sass::Script::Value::Color
        {
          value: value.to_s,
          type: :color
        }
      when Sass::Script::Value::Number
        {
          value: value.value,
          unit: value.unit_str,
          type: :number
        }
      else
        {
          value: value.value,
          type: nil
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def get_list_values(list)
      list.value.map do |value|
        get_value(value)
      end
    end

    def get_map_values(map)
      values = {}
      map.value.each do |k, v|
        values[k.to_s] = get_value(v)
      end
      values
    end
  end
end

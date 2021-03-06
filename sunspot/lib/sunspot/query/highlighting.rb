module Sunspot
  module Query
    #
    # A query component that builds parameters for requesting highlights
    #
    class Highlighting #:nodoc:
      def initialize(fields=[], options={})
        @fields  = fields
        @options = options
      end

      #
      # Return Solr highlighting params
      #
      def to_params
        params = {
          :hl => 'on',
          :"hl.tag.pre" => '@@@hl@@@',
          :"hl.tag.post" => '@@@endhl@@@',
          :"hl.useFastVectorHighlighter" => true
        }
        unless @fields.empty?
          params[:"hl.fl"] = @fields.map { |field| field.indexed_name }
        end
        if max_snippets = @options[:max_snippets]
          params.merge!(make_params('snippets', max_snippets))
        end
        if fragment_size = @options[:fragment_size]
          params.merge!(make_params('fragsize', fragment_size))
        end
        if @options[:merge_contiguous_fragments]
          params.merge!(make_params('mergeContiguous', 'true'))
        end
        if @options[:phrase_highlighter]
          params.merge!(make_params('usePhraseHighlighter', 'true'))
          if @options[:require_field_match]
            params.merge!(make_params('requireFieldMatch', 'true'))
          end
        end
        if formatter = @options[:formatter]
          params.merge!(make_params('formatter', formatter))
        end
        if fragmenter = @options[:fragmenter]
          params.merge!(make_params('fragmenter', fragmenter))
        end
        if frag_list_builder = @options[:frag_list_builder]
          params.merge!(make_params('fragListBuilder', frag_list_builder))
        end

        params
      end

      private

      def make_params(name, value)
        if @fields.empty?
          { :"hl.#{name}" => value }
        else
          @fields.inject({}) do |hash, field|
            hash.merge!(:"f.#{field.indexed_name}.hl.#{name}" => value)
          end
        end
      end
    end
  end
end

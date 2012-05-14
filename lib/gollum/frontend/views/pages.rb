module Precious
  module Views
    class Pages < Layout
      attr_reader :results, :ref

      def title
        "All Files"
      end

      def pages_as_nested_list
        tree = {}
        if has_results
          @results.each do |page|
            if !page.path.include?('/')
              tree[page.path] = page.path
              next
            end

            # "example/foo/bar"
            #   => ["example", "foo", "bar"]
            #     => tree["example"]["foo"]["bar"] = 'path'

            # Split our path.
            path_chunks = page.path.split('/')

            # Create the root.
            tree[path_chunks.first] ||= {}

            # Keep track of current node.
            node = tree[path_chunks.first]

            # Deal with the children.
            path_chunks[1..-1].each do |chunk|
              if chunk == path_chunks.last
                node[chunk] = page.path
              end
              node[chunk] ||= {}
              node = node[chunk]
            end
          end

          "<ul>#{listify(tree)}</ul>"
        end
      end

      def listify(tree, path="")
        html = ""
        tree.each do |parent, child|
          if !child.is_a? Hash
            html << "<li><a href=\"/edit/#{child}\">#{parent}</a></li>"
          else
            html << "<li>#{parent}<ul>#{listify(child)}</ul></li>"
          end
        end

        html
      end

      def has_results
        !@results.empty?
      end

      def no_results
        @results.empty?
      end
    end
  end
end

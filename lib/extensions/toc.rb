module Gollum::Extensions
  class Toc_gen
    attr_accessor :header_tags
    
    NODE_CONTENT = 0
    NODE_ORDER   = 1
    
    def initialize (doc, settings = {})
      @doc = doc
      @header_tags = ['title','h1','h2','h3','h4','h5','h6']
    end
    
    # Generates a table of contents for @doc using headers
    #
    # Returns Nokogiri::XML::Node if there were headers to parse, or nil if none were found
    def generate
      return unless (headings = find_headings).count > 0
      
      node_count = 0
      lvl = 0
      @lvls = [].fill(0..@header_tags.count) {[]}
      
      headings.each do |h|
        node_count += 1
        lvl_new = heading_to_lvl h

        @lvls[lvl_new].push [build_toc_node(h), node_count]
        
        # Pass in the highest level prior to flattening for efficiency
        flatten_to_lvl(lvl, lvl_new) if lvl_new < lvl
        
        lvl = lvl_new
      end
      
      flatten_to_lvl(lvl, 0)
    end
    
    # Escape title string for use in ID attribute
    #
    # title - Title string
    #
    # Returns string  
    def insert_anchors
      find_headings.each do |h|
        rep_h = Nokogiri::XML::Node.new('a', @doc)
        rep_h['name'] = anchor_id(h.content)
        rep_h.add_child(h.clone)
        h.replace(rep_h)
      end
    end
    
    # Escape title string for use in ID attribute
    #
    # title - Title string
    #
    # Returns string  
    def anchor_id (title)
      CGI::escape(title)
    end
    
    # Convert heading into list element
    #
    # heading - Nokogiri::XML::Node representing a single heading
    #
    # Returns string
    def build_toc_node(heading)
      xml_node = Nokogiri::XML::Node.new('li', @doc)
      xml_node.add_child("<a href='#" + anchor_id(heading.content) + "'>" + heading.content + "</a>")
      xml_node
    end
    
    # Search the current @doc for headings
    #
    # Returns Nokogiri::XML::NodeSet
    def find_headings
      @doc.css(@header_tags.join ' ,')
    end
    
    # Convert specified heading to integer level
    #
    # heading - Nokogiri::XML::Node representing a single heading
    #
    # Returns int
    def heading_to_lvl(heading)
      heading.name.gsub('h','').to_i
    end

    # Convert Nokogiri::XML:Nodes higher in the level array than the specified low_idx
    # into a node tree, and either append or prepend the tree to the level specified
    # by low_idx.
    #
    # low_idx - The level in the array to flatten to
    # high  - The highest level to flatten from
    #
    # Returns Nokogiri::XML::Nodes if low_idx is 0, else nil
    def flatten_to_lvl(high_idx, low_idx = 0)
      lvl = high_idx + 1 
      lvl_up = nil
      
      @lvls[low_idx..high_idx].reverse_each do |lvl_children|
        lvl -= 1
        next if lvl_children.count() == 0 || !lvl_up && (lvl_up = lvl)
        
        flatten_lvl(lvl_up,lvl)     
        lvl_up = lvl   
      end
      
      # Level 0 flattens all levels, and returns an XML node containing the TOC data
      flatten_lvl(lvl_up, 0).first[NODE_CONTENT] if lvl == 0 && lvl_up
    end

    # Insert all Nokogiri::XML::Nodes at lvl_src into a new ul XML::Node as children.
    # Then either append or prepend the ul node, depending on whether the first child
    # at the src_level appeared before or after the node in the dst_level in @doc
    #
    # lvl_src - The level in the array to src li XML::Nodes from
    # lvl_dst - The level in the array to insert resulting ul XML::Node
    #
    # Returns array of Nokogiri::XML::Nodes @ lvl_dst
    def flatten_lvl(lvl_src, lvl_dst)
      lvl_sib = Nokogiri::XML::Node.new('ul', @doc)
      src_pos = @lvls[lvl_src].first[NODE_ORDER]
      @lvls[lvl_src].each {|lvl_child| lvl_sib.add_child(lvl_child[NODE_CONTENT])}
      @lvls[lvl_src] = []
      
      lvl_dst > 0 && src_pos < @lvls[lvl_dst].last[NODE_ORDER] ?
        @lvls[lvl_dst].insert(-2,[lvl_sib, src_pos]) :
        @lvls[lvl_dst].push([lvl_sib, src_pos])
      @lvls[lvl_dst]
    end
  end
end
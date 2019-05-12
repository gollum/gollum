ace.define("ace/snippets/graphqlschema",["require","exports","module"],function(e,t,n){"use strict";t.snippetText="# Type Snippet\ntrigger type\nsnippet type\n	type ${1:type_name} {\n		${2:type_siblings}\n	}\n\n# Input Snippet\ntrigger input\nsnippet input\n	input ${1:input_name} {\n		${2:input_siblings}\n	}\n\n# Interface Snippet\ntrigger interface\nsnippet interface\n	interface ${1:interface_name} {\n		${2:interface_siblings}\n	}\n\n# Interface Snippet\ntrigger union\nsnippet union\n	union ${1:union_name} = ${2:type} | ${3: type}\n\n# Enum Snippet\ntrigger enum\nsnippet enum\n	enum ${1:enum_name} {\n		${2:enum_siblings}\n	}\n",t.scope="graphqlschema"});                (function() {
                    ace.require(["ace/snippets/graphqlschema"], function(m) {
                        if (typeof module == "object" && typeof exports == "object" && module) {
                            module.exports = m;
                        }
                    });
                })();
            
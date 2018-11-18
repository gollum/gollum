ace.define("ace/snippets/drools",["require","exports","module"],function(e,t,n){"use strict";t.snippetText='\nsnippet rule\n	rule "${1?:rule_name}"\n	when\n		${2:// when...} \n	then\n		${3:// then...}\n	end\n\nsnippet query\n	query ${1?:query_name}\n		${2:// find} \n	end\n	\nsnippet declare\n	declare ${1?:type_name}\n		${2:// attributes} \n	end\n\n',t.scope="drools"});
                (function() {
                    ace.require(["ace/snippets/drools"], function(m) {
                        if (typeof module == "object" && typeof exports == "object" && module) {
                            module.exports = m;
                        }
                    });
                })();
            
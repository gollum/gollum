/*
Language: TeX
Author: Vladimir Moskva <vladmos@gmail.com>
Website: http://fulc.ru/
*/

hljs.LANGUAGES.tex = function() {
  var COMMAND1 = {
    className: 'command',
    begin: '\\\\[a-zA-Zа-яА-я]+[\\*]?',
    relevance: 10
  };
  var COMMAND2 = {
    className: 'command',
    begin: '\\\\[^a-zA-Zа-яА-я0-9]',
    relevance: 0
  };
  var SPECIAL = {
    className: 'special',
    begin: '[{}\\[\\]\\&#~]',
    relevance: 0
  };

  return {
    defaultMode: {
      contains: [
        { // parameter
          begin: '\\\\[a-zA-Zа-яА-я]+[\\*]? *= *-?\\d*\\.?\\d+(pt|pc|mm|cm|in|dd|cc|ex|em)?',
          returnBegin: true,
          contains: [
            COMMAND1, COMMAND2,
            {
              className: 'number',
              begin: ' *=', end: '-?\\d*\\.?\\d+(pt|pc|mm|cm|in|dd|cc|ex|em)?',
              excludeBegin: true
            }
          ],
          relevance: 10
        },
        COMMAND1, COMMAND2,
        SPECIAL,
        {
          className: 'formula',
          begin: '\\$\\$', end: '\\$\\$',
          contains: [COMMAND1, COMMAND2, SPECIAL],
          relevance: 0
        },
        {
          className: 'formula',
          begin: '\\$', end: '\\$',
          contains: [COMMAND1, COMMAND2, SPECIAL],
          relevance: 0
        },
        {
          className: 'comment',
          begin: '%', end: '$',
          relevance: 0
        }
      ]
    }
  };
}();

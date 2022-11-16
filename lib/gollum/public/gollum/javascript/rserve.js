(function() {

var Rserve = {};

(function() {

function make_basic(type, proto) {
    proto = proto || {
        json: function() {
            throw "json() unsupported for type " + this.type;
        }
    };
    var wrapped_proto = {
        json: function(resolver) {
            var result = proto.json.call(this, resolver);
            result.r_type = type;
            if (!_.isUndefined(this.attributes))
                result.r_attributes = _.object(_.map(
                    this.attributes.value,
                    function(v) { return [v.name, v.value.json(resolver)]; }));
            return result;
        }
    };
    return function(v, attrs) {
        function r_object() {
            this.type = type;
            this.value = v;
            this.attributes = attrs;
        }
        r_object.prototype = wrapped_proto;
        var result = new r_object();
        return result;
    };
}

Rserve.Robj = {
    "null": function(attributes) {
        return {
            type: "null",
            value: null,
            attributes: attributes,
            json: function() { return null; }
        };
    },

    clos: function(formals, body, attributes) {
        return {
            type: "clos",
            value: { formals: formals,
                     body: body },
            attributes: attributes,
            json: function() { throw "json() unsupported for type clos"; }
        };
    },

    vector: make_basic("vector", {
        json: function(resolver) {
            var values = _.map(this.value, function (x) { return x.json(resolver); });
            if (_.isUndefined(this.attributes)) {
                return values;
            } else {
		// FIXME: there is no reason why names should be the first or only
		//        attribute, so the code should really look
		//        for "names" and not cry if it doesn't exist
                if (this.attributes.value[0].name == "names") {
                    var keys   = this.attributes.value[0].value.value;
                    var result = {};
                    _.each(keys, function(key, i) {
			result[key] = values[i];
                    });
                    return result;
		}
		// FIXME: how can we pass other important attributes
		//        like "class" ?
		return values;
            }
        }
    }),
    symbol: make_basic("symbol", {
        json: function() {
            return this.value;
        }
    }),
    list: make_basic("list"),
    lang: make_basic("lang", {
        json: function(resolver) {
            var values = _.map(this.value, function (x) { return x.json(resolver); });
            if (_.isUndefined(this.attributes)) {
                return values;
            } else {
		// FIXME: lang doens't have "names" attribute since
		//        names are sent as tags (langs are pairlists)
		//        so this seems superfluous (it is dangerous
		//        if lang ever had attributes since there is
		//        no reason to fail in that case)
                if(this.attributes.value[0].name!="names")
                    throw "expected names here";
                var keys   = this.attributes.value[0].value.value;
                var result = {};
                _.each(keys, function(key, i) {
                    result[key] = values[i];
                });
                return result;
            }
        }
    }),
    tagged_list: make_basic("tagged_list", {
        json: function(resolver) {
            function classify_list(list) {
                if (_.all(list, function(elt) { return elt.name === null; })) {
                    return "plain_list";
                } else if (_.all(list, function(elt) { return elt.name !== null; })) {
                    return "plain_object";
                } else
                    return "mixed_list";
            }
            var list = this.value.slice(1);
            switch (classify_list(list)) {
            case "plain_list":
                return _.map(list, function(elt) { return elt.value.json(resolver); });
            case "plain_object":
                return _.object(_.map(list, function(elt) {
                    return [elt.name, elt.value.json(resolver)];
                }));
            case "mixed_list":
                return list;
            default:
                throw "Internal Error";
            }
        }
    }),
    tagged_lang: make_basic("tagged_lang", {
        json: function(resolver) {
            var pair_vec = _.map(this.value, function(elt) { return [elt.name, elt.value.json(resolver)]; });
            return pair_vec;
        }
    }),
    vector_exp: make_basic("vector_exp"),
    int_array: make_basic("int_array", {
        json: function() {
            if(this.attributes && this.attributes.type==='tagged_list'
               && this.attributes.value[0].name==='levels'
               && this.attributes.value[0].value.type==='string_array') {
                var levels = this.attributes.value[0].value.value;
                var arr = _.map(this.value, function(factor) { return levels[factor-1]; });
                arr.levels = levels;
                return arr;
            }
            else {
                if (this.value.length === 1)
                    return this.value[0];
                else
                    return this.value;
            }
        }
    }),
    double_array: make_basic("double_array", {
        json: function() {
            if (this.value.length === 1 && _.isUndefined(this.attributes))
                return this.value[0];
            else
                return this.value;
        }
    }),
    string_array: make_basic("string_array", {
        json: function(resolver) {
            if (this.value.length === 1) {
                if (_.isUndefined(this.attributes))
                    return this.value[0];
                if (this.attributes.value[0].name === 'class' &&
                    this.attributes.value[0].value.value.indexOf("javascript_function") !== -1)
                    return resolver(this.value[0]);
                return this.value;
            } else
                return this.value;
        }
    }),
    bool_array: make_basic("bool_array", {
        json: function() {
            if (this.value.length === 1 && _.isUndefined(this.attributes))
                return this.value[0];
            else
                return this.value;
        }
    }),
    raw: make_basic("raw", {
        json: function() {
            if (this.value.length === 1 && _.isUndefined(this.attributes))
                return this.value[0];
            else
                return this.value;
        }
    }),
    string: make_basic("string", {
        json: function() {
            return this.value;
        }
    })
};

})();
// Simple constants and functions are defined here,
// in correspondence with Rserve's Rsrv.h

Rserve.Rsrv = {
    PAR_TYPE: function(x) { return x & 255; },
    PAR_LEN: function(x) { return x >>> 8; },
    PAR_LENGTH: function(x) { return x >>> 8; },
    par_parse: function(x) { return [Rserve.Rsrv.PAR_TYPE(x), Rserve.Rsrv.PAR_LEN(x)]; },
    SET_PAR: function(ty, len) { return ((len & 0xffffff) << 8 | (ty & 255)); },
    CMD_STAT: function(x) { return (x >>> 24) & 127; },
    SET_STAT: function(x, s) { return x | ((s & 127) << 24); },

    IS_OOB_SEND: function(x) { return (x & 0xffff000) === Rserve.Rsrv.OOB_SEND; },
    IS_OOB_MSG: function(x) { return (x & 0xffff000) === Rserve.Rsrv.OOB_MSG; },
    OOB_USR_CODE: function(x) { return x & 0xfff; },

    CMD_RESP           : 0x10000,
    RESP_OK            : 0x10000 | 0x0001,
    RESP_ERR           : 0x10000 | 0x0002,
    OOB_SEND           : 0x20000 | 0x1000,
    OOB_MSG            : 0x20000 | 0x2000,
    ERR_auth_failed    : 0x41,
    ERR_conn_broken    : 0x42,
    ERR_inv_cmd        : 0x43,
    ERR_inv_par        : 0x44,
    ERR_Rerror         : 0x45,
    ERR_IOerror        : 0x46,
    ERR_notOpen        : 0x47,
    ERR_accessDenied   : 0x48,
    ERR_unsupportedCmd : 0x49,
    ERR_unknownCmd     : 0x4a,
    ERR_data_overflow  : 0x4b,
    ERR_object_too_big : 0x4c,
    ERR_out_of_mem     : 0x4d,
    ERR_ctrl_closed    : 0x4e,
    ERR_session_busy   : 0x50,
    ERR_detach_failed  : 0x51,
    ERR_disabled       : 0x61,
    ERR_unavailable    : 0x62,
    ERR_cryptError     : 0x63,
    ERR_securityClose  : 0x64,

    CMD_login            : 0x001,
    CMD_voidEval         : 0x002,
    CMD_eval             : 0x003,
    CMD_shutdown         : 0x004,
    CMD_switch           : 0x005,
    CMD_keyReq           : 0x006,
    CMD_secLogin         : 0x007,
    CMD_OCcall           : 0x00f,
    CMD_openFile         : 0x010,
    CMD_createFile       : 0x011,
    CMD_closeFile        : 0x012,
    CMD_readFile         : 0x013,
    CMD_writeFile        : 0x014,
    CMD_removeFile       : 0x015,
    CMD_setSEXP          : 0x020,
    CMD_assignSEXP       : 0x021,
    CMD_detachSession    : 0x030,
    CMD_detachedVoidEval : 0x031,
    CMD_attachSession    : 0x032,
    CMD_ctrl             : 0x40,
    CMD_ctrlEval         : 0x42,
    CMD_ctrlSource       : 0x45,
    CMD_ctrlShutdown     : 0x44,
    CMD_setBufferSize    : 0x081,
    CMD_setEncoding      : 0x082,
    CMD_SPECIAL_MASK     : 0xf0,
    CMD_serEval          : 0xf5,
    CMD_serAssign        : 0xf6,
    CMD_serEEval         : 0xf7,

    DT_INT        : 1,
    DT_CHAR       : 2,
    DT_DOUBLE     : 3,
    DT_STRING     : 4,
    DT_BYTESTREAM : 5,
    DT_SEXP       : 10,
    DT_ARRAY      : 11,
    DT_LARGE      : 64,

    XT_NULL          : 0,
    XT_INT           : 1,
    XT_DOUBLE        : 2,
    XT_STR           : 3,
    XT_LANG          : 4,
    XT_SYM           : 5,
    XT_BOOL          : 6,
    XT_S4            : 7,
    XT_VECTOR        : 16,
    XT_LIST          : 17,
    XT_CLOS          : 18,
    XT_SYMNAME       : 19,
    XT_LIST_NOTAG    : 20,
    XT_LIST_TAG      : 21,
    XT_LANG_NOTAG    : 22,
    XT_LANG_TAG      : 23,
    XT_VECTOR_EXP    : 26,
    XT_VECTOR_STR    : 27,
    XT_ARRAY_INT     : 32,
    XT_ARRAY_DOUBLE  : 33,
    XT_ARRAY_STR     : 34,
    XT_ARRAY_BOOL_UA : 35,
    XT_ARRAY_BOOL    : 36,
    XT_RAW           : 37,
    XT_ARRAY_CPLX    : 38,
    XT_UNKNOWN       : 48,
    XT_LARGE         : 64,
    XT_HAS_ATTR      : 128,

    BOOL_TRUE  : 1,
    BOOL_FALSE : 0,
    BOOL_NA    : 2,

    GET_XT: function(x) { return x & 63; },
    GET_DT: function(x) { return x & 63; },
    HAS_ATTR: function(x) { return (x & Rserve.Rsrv.XT_HAS_ATTR) > 0; },
    IS_LARGE: function(x) { return (x & Rserve.Rsrv.XT_LARGE) > 0; },

    // # FIXME A WHOLE LOT OF MACROS HERE WHICH ARE PROBABLY IMPORTANT
    // ##############################################################################

    status_codes: {
        0x41 : "ERR_auth_failed"   ,
        0x42 : "ERR_conn_broken"   ,
        0x43 : "ERR_inv_cmd"       ,
        0x44 : "ERR_inv_par"       ,
        0x45 : "ERR_Rerror"        ,
        0x46 : "ERR_IOerror"       ,
        0x47 : "ERR_notOpen"       ,
        0x48 : "ERR_accessDenied"  ,
        0x49 : "ERR_unsupportedCmd",
        0x4a : "ERR_unknownCmd"    ,
        0x4b : "ERR_data_overflow" ,
        0x4c : "ERR_object_too_big",
        0x4d : "ERR_out_of_mem"    ,
        0x4e : "ERR_ctrl_closed"   ,
        0x50 : "ERR_session_busy"  ,
        0x51 : "ERR_detach_failed" ,
        0x61 : "ERR_disabled"      ,
        0x62 : "ERR_unavailable"   ,
        0x63 : "ERR_cryptError"    ,
        0x64 : "ERR_securityClose"
    }
};
(function() {

function read(m)
{
    var handlers = {};

    function lift(f, amount) {
        return function(attributes, length) {
            return [f.call(that, attributes, length), amount || length];
        };
    }

    function bind(m, f) {
        return function(attributes, length) {
            var t = m.call(that, attributes, length);
            var t2 = f(t[0])(attributes, length - t[1]);
            return [t2[0], t[1] + t2[1]];
        };
    }

    function unfold(f) {
        return function(attributes, length) {
            var result = [];
            var old_length = length;
            while (length > 0) {
                var t = f.call(that, attributes, length);
                result.push(t[0]);
                length -= t[1];
            }
            return [result, old_length];
        };
    }

    function decodeRString(s) {
        // R encodes NA as a string containing just 0xff
        if(s.length === 1 && s.charCodeAt(0) === 255)
            return null;
        // UTF-8 to UTF-16
        // http://monsur.hossa.in/2012/07/20/utf-8-in-javascript.html
        // also, we don't want to lose the value when reporting an error in decoding
        try {
            return decodeURIComponent(escape(s));
        }
        catch(xep) {
            throw new Error('Invalid UTF8: ' + s);
        }
    }

    var that = {
        offset: 0,
        data_view: m.make(Rserve.EndianAwareDataView),
        msg: m,

        //////////////////////////////////////////////////////////////////////

        read_int: function() {
            var old_offset = this.offset;
            this.offset += 4;
            return this.data_view.getInt32(old_offset);
        },
        read_string: function(length) {
            // FIXME SLOW
            var result = "";
            while (length--) {
                var c = this.data_view.getInt8(this.offset++);
                if (c) result = result + String.fromCharCode(c);
            }
            return decodeRString(result);
        },
        read_stream: function(length) {
            var old_offset = this.offset;
            this.offset += length;
            return this.msg.view(old_offset, length);
        },
        read_int_vector: function(length) {
            var old_offset = this.offset;
            this.offset += length;
            return this.msg.make(Int32Array, old_offset, length);
        },
        read_double_vector: function(length) {
            var old_offset = this.offset;
            this.offset += length;
            return this.msg.make(Float64Array, old_offset, length);
        },

        //////////////////////////////////////////////////////////////////////
        // these are members of the reader monad

        read_null: lift(function(a, l) { return Rserve.Robj.null(a); }),

        read_unknown: lift(function(a, l) {
            this.offset += l;
            return Rserve.Robj.null(a);
        }),

        read_string_array: function(attributes, length) {
            var a = this.read_stream(length).make(Uint8Array);
            var result = [];
            var current_str = "";
            for (var i=0; i<a.length; ++i)
                if (a[i] === 0) {
                    current_str = decodeRString(current_str);
                    result.push(current_str);
                    current_str = "";
                } else {
                    current_str = current_str + String.fromCharCode(a[i]);
                }
            return [Rserve.Robj.string_array(result, attributes), length];
        },
        read_bool_array: function(attributes, length) {
            var l2 = this.read_int();
            var s = this.read_stream(length-4);
            var a = _.map(s.make(Uint8Array).subarray(0, l2), function(v) {
                return v ? true : false;
            });
            return [Rserve.Robj.bool_array(a, attributes), length];
        },
        read_raw: function(attributes, length) {
            var l2 = this.read_int();
            var s = this.read_stream(length-4);
            var a = new Uint8Array(s.make(Uint8Array).subarray(0, l2)).buffer;
            return [Rserve.Robj.raw(a, attributes), length];
        },

        read_sexp: function() {
            var d = this.read_int();
            var _ = Rserve.Rsrv.par_parse(d);
            var t = _[0], l = _[1];
            var total_read = 4;
            var attributes = undefined;
            if (Rserve.Rsrv.IS_LARGE(t)) {
                var extra_length = this.read_int();
                total_read += 4;
                l += extra_length * Math.pow(2, 24);
                t &= ~64;
            }
            if (t & Rserve.Rsrv.XT_HAS_ATTR) {
                t = t & ~Rserve.Rsrv.XT_HAS_ATTR;
                var attr_result = this.read_sexp();
                attributes = attr_result[0];
                total_read += attr_result[1];
                l -= attr_result[1];
            }
            if (handlers[t] === undefined) {
                throw new Rserve.RserveError("Unimplemented " + t, -1);
            } else {
                var result = handlers[t].call(this, attributes, l);
                return [result[0], total_read + result[1]];
            }
        }
    };

    that.read_clos = bind(that.read_sexp, function(formals) {
              return bind(that.read_sexp, function(body)    {
              return lift(function(a, l) {
              return Rserve.Robj.clos(formals, body, a);
              }, 0);
              } );
    });

    that.read_list = unfold(that.read_sexp);

    function read_symbol_value_pairs(lst) {
        var result = [];
        for (var i=0; i<lst.length; i+=2) {
            var value = lst[i], tag = lst[i+1];
            if (tag.type === "symbol") {
                result.push({ name: tag.value,
                              value: value });
            } else {
                result.push({ name: null,
                              value: value });
            }
        }
        return result;
    }
    that.read_list_tag = bind(that.read_list, function(lst) {
        return lift(function(attributes, length) {
            var result = read_symbol_value_pairs(lst);
            return Rserve.Robj.tagged_list(result, attributes);
        }, 0);
    });
    that.read_lang_tag = bind(that.read_list, function(lst) {
        return lift(function(attributes, length) {
            var result = read_symbol_value_pairs(lst);
            return Rserve.Robj.tagged_lang(result, attributes);
        }, 0);
    });

    function xf(f, g) { return bind(f, function(t) {
        return lift(function(a, l) { return g(t, a); }, 0);
    }); }
    that.read_vector       = xf(that.read_list, Rserve.Robj.vector);
    that.read_list_no_tag  = xf(that.read_list, Rserve.Robj.list);
    that.read_lang_no_tag  = xf(that.read_list, Rserve.Robj.lang);
    that.read_vector_exp   = xf(that.read_list, Rserve.Robj.vector_exp);

    function sl(f, g) { return lift(function(a, l) {
        return g(f.call(that, l), a);
    }); }
    that.read_symname      = sl(that.read_string,        Rserve.Robj.symbol);
    that.read_int_array    = sl(that.read_int_vector,    Rserve.Robj.int_array);
    that.read_double_array = sl(that.read_double_vector, Rserve.Robj.double_array);

    handlers[Rserve.Rsrv.XT_NULL]         = that.read_null;
    handlers[Rserve.Rsrv.XT_UNKNOWN]      = that.read_unknown;
    handlers[Rserve.Rsrv.XT_VECTOR]       = that.read_vector;
    handlers[Rserve.Rsrv.XT_CLOS]         = that.read_clos;
    handlers[Rserve.Rsrv.XT_SYMNAME]      = that.read_symname;
    handlers[Rserve.Rsrv.XT_LIST_NOTAG]   = that.read_list_no_tag;
    handlers[Rserve.Rsrv.XT_LIST_TAG]     = that.read_list_tag;
    handlers[Rserve.Rsrv.XT_LANG_NOTAG]   = that.read_lang_no_tag;
    handlers[Rserve.Rsrv.XT_LANG_TAG]     = that.read_lang_tag;
    handlers[Rserve.Rsrv.XT_VECTOR_EXP]   = that.read_vector_exp;
    handlers[Rserve.Rsrv.XT_ARRAY_INT]    = that.read_int_array;
    handlers[Rserve.Rsrv.XT_ARRAY_DOUBLE] = that.read_double_array;
    handlers[Rserve.Rsrv.XT_ARRAY_STR]    = that.read_string_array;
    handlers[Rserve.Rsrv.XT_ARRAY_BOOL]   = that.read_bool_array;
    handlers[Rserve.Rsrv.XT_RAW]          = that.read_raw;

    handlers[Rserve.Rsrv.XT_STR]          = sl(that.read_string, Rserve.Robj.string);

    return that;
}

var incomplete_ = [], incomplete_header_ = null, msg_bytes_ = 0, remaining_ = 0;
function clear_incomplete() {
    incomplete_ = [];
    incomplete_header_ = null;
    remaining_ = 0;
    msg_bytes_ = 0;
}

function parse(msg)
{
    var result = {};
    if(incomplete_.length) {
        result.header = incomplete_header_;
        incomplete_.push(msg);
        remaining_ -= msg.byteLength;
        if(remaining_ < 0) {
            result.ok = false;
            result.message = "Messages add up to more than expected length: got " +
                            (msg_bytes_-remaining_) + ", expected " + msg_bytes_;
            clear_incomplete();
            return result;
        }
        else if(remaining_ === 0) {
            var complete_msg = new ArrayBuffer(msg_bytes_),
                array = new Uint8Array(complete_msg),
                offset = 0;
            incomplete_.forEach(function(frame, i) {
                array.set(new Uint8Array(frame), offset);
                offset += frame.byteLength;
            });
            if(offset !== msg_bytes_) {
                result.ok = false;
                result.message = "Internal error - frames added up to " + offset + " not " + msg_bytes_;
                clear_incomplete();
                return result;
            }
            clear_incomplete();
            msg = complete_msg;
        }
        else {
            result.ok = true;
            result.incomplete = true;
            return result;
        }
    }

    var header = new Int32Array(msg, 0, 4);
    var resp = header[0] & 16777215, status_code = header[0] >>> 24;
    var length = header[1], length_high = header[3];
    var msg_id = header[2];
    result.header = [resp, status_code, msg_id];

    if(length_high) {
        result.ok = false;
        result.message = "rserve.js cannot handle messages larger than 4GB";
        return result;
    }

    var full_msg_length = length + 16; // header length + data length
    if(full_msg_length > msg.byteLength) {
        incomplete_.push(msg);
        incomplete_header_ = header;
        msg_bytes_ = full_msg_length;
        remaining_ = msg_bytes_ - msg.byteLength;
        result.header = header;
        result.ok = true;
        result.incomplete = true;
        return result;
    }

    if (resp === Rserve.Rsrv.RESP_ERR) {
        result.ok = false;
        result.status_code = status_code;
        result.message = "ERROR FROM R SERVER: " + (Rserve.Rsrv.status_codes[status_code] ||
                                         status_code)
               + " " + result.header[0] + " " + result.header[1]
               + " " + msg.byteLength
               + " " + msg;
        return result;
    }

    if (!( resp === Rserve.Rsrv.RESP_OK || Rserve.Rsrv.IS_OOB_SEND(resp) || Rserve.Rsrv.IS_OOB_MSG(resp))) {
        result.ok = false;
        result.message = "Unexpected response from Rserve: " + resp + " status: " + Rserve.Rsrv.status_codes[status_code];
        return result;
    }
    try {
        result.payload = parse_payload(msg);
        result.ok = true;
    } catch (e) {
        result.ok = false;
        result.message = e.message;
    }
    return result;
}

function parse_payload(msg)
{
    var payload = Rserve.my_ArrayBufferView(msg, 16, msg.byteLength - 16);
    if (payload.length === 0)
        return null;

    var reader = read(payload);

    var d = reader.read_int();
    var _ = Rserve.Rsrv.par_parse(d);
    var t = _[0], l = _[1];
    if (Rserve.Rsrv.IS_LARGE(t)) {
        var more_length = reader.read_int();
        l += more_length * Math.pow(2, 24);
        if (l > (Math.pow(2, 32))) { // resist the 1 << 32 temptation here!
            // total_length is greater than 2^32.. bail out because of node limits
            // even though in theory we could go higher than that.
            throw new Error("Payload too large: " + l + " bytes");
        }
        t &= ~64;
    }
    if (t === Rserve.Rsrv.DT_INT) {
        return { type: "int", value: reader.read_int() };
    } else if (t === Rserve.Rsrv.DT_STRING) {
        return { type: "string", value: reader.read_string(l) };
    } else if (t === Rserve.Rsrv.DT_BYTESTREAM) { // NB this returns a my_ArrayBufferView()
        return { type: "stream", value: reader.read_stream(l) };
    } else if (t === Rserve.Rsrv.DT_SEXP) {
        _ = reader.read_sexp();
        var sexp = _[0], l2 = _[1];
        return { type: "sexp", value: sexp };
    } else
        throw new Rserve.RserveError("Bad type for parse? " + t + " " + l, -1);
}

Rserve.parse_websocket_frame = parse;
Rserve.parse_payload = parse_payload;

})();
// we want an endian aware dataview mostly because ARM can be big-endian, and
// that might put us in trouble wrt handheld devices.
//////////////////////////////////////////////////////////////////////////////

(function() {
    var _is_little_endian;

    (function() {
        var x = new ArrayBuffer(4);
        var bytes = new Uint8Array(x),
        words = new Uint32Array(x);
        bytes[0] = 1;
        if (words[0] === 1) {
            _is_little_endian = true;
        } else if (words[0] === 16777216) {
            _is_little_endian = false;
        } else {
            throw "we're bizarro endian, refusing to continue";
        }
    })();

    Rserve.EndianAwareDataView = (function() {

        var proto = {
            'setInt8': function(i, v) { return this.view.setInt8(i, v); },
            'setUint8': function(i, v) { return this.view.setUint8(i, v); },
            'getInt8': function(i) { return this.view.getInt8(i); },
            'getUint8': function(i) { return this.view.getUint8(i); }
        };

        var setters = ['setInt32', 'setInt16', 'setUint32', 'setUint16',
                       'setFloat32', 'setFloat64'];
        var getters = ['getInt32', 'getInt16', 'getUint32', 'getUint16',
                       'getFloat32', 'getFloat64'];

        for (var i=0; i<setters.length; ++i) {
            var name = setters[i];
            proto[name]= (function(name) {
                return function(byteOffset, value) {
                    return this.view[name](byteOffset, value, _is_little_endian);
                };
            })(name);
        }
        for (i=0; i<getters.length; ++i) {
            var name = getters[i];
            proto[name]= (function(name) {
                return function(byteOffset) {
                    return this.view[name](byteOffset, _is_little_endian);
                };
            })(name);
        }

        function my_dataView(buffer, byteOffset, byteLength) {
            if (byteOffset === undefined) {
                // work around node.js bug https://github.com/joyent/node/issues/6051
                if (buffer.byteLength === 0) {
                    this.view = {
                        byteLength: 0, byteOffset: 0
                    };
                } else
                    this.view = new DataView(buffer);
            } else {
                this.view = new DataView(buffer, byteOffset, byteLength);
            }
        };
        my_dataView.prototype = proto;
        return my_dataView;
    })();

    Rserve.my_ArrayBufferView = function(b, o, l) {
        o = _.isUndefined(o) ? 0 : o;
        l = _.isUndefined(l) ? b.byteLength : l;
        return {
            buffer: b,
            offset: o,
            length: l,
            data_view: function() {
                return new Rserve.EndianAwareDataView(this.buffer, this.offset,
                                                      this.buffer.byteLength - this.offset);
            },
            make: function(ctor, new_offset, new_length) {
                new_offset = _.isUndefined(new_offset) ? 0 : new_offset;
                new_length = _.isUndefined(new_length) ? this.length : new_length;
                var element_size = ctor.BYTES_PER_ELEMENT || 1;
                var n_els = new_length / element_size;
                if ((this.offset + new_offset) % element_size != 0) {
                    var view = new DataView(this.buffer, this.offset + new_offset, new_length);
                    var output_buffer = new ArrayBuffer(new_length);
                    var out_view = new DataView(output_buffer);
                    for (var i=0; i < new_length; ++i) {
                        out_view.setUint8(i, view.getUint8(i));
                    }
                    return new ctor(output_buffer);
                } else {
                    return new ctor(this.buffer,
                                    this.offset + new_offset,
                                    n_els);
                }
            },
            skip: function(offset) {
                return Rserve.my_ArrayBufferView(
                    this.buffer, this.offset + offset, this.buffer.byteLength);
            },
            view: function(new_offset, new_length) {
                var ofs = this.offset + new_offset;
                if(ofs + new_length > this.buffer.byteLength)
                    throw new Error("Rserve.my_ArrayBufferView.view: bounds error: size: " +
                                    this.buffer.byteLength + " offset: " + ofs + " length: " + new_length);
                return Rserve.my_ArrayBufferView(
                    this.buffer, ofs, new_length);
            }
        };
    };

})(this);
(function() {

function _encode_command(command, buffer, msg_id) {
    if (!_.isArray(buffer))
        buffer = [buffer];
    if (!msg_id) msg_id = 0;
    var length = _.reduce(buffer,
                          function(memo, val) {
                              return memo + val.byteLength;
                          }, 0),
        big_buffer = new ArrayBuffer(16 + length),
        view = new Rserve.EndianAwareDataView(big_buffer);
    view.setInt32(0, command);
    view.setInt32(4, length);
    view.setInt32(8, msg_id);
    view.setInt32(12, 0);
    var offset = 16;
    _.each(buffer, function(b) {
        var source_array = new Uint8Array(b);
        for (var i=0; i<source_array.byteLength; ++i)
            view.setUint8(offset+i, source_array[i]);
        offset += b.byteLength;
    });
    return big_buffer;
};

function _encode_string(str) {
    var strl = ((str.length + 1) + 3) & ~3; // pad to 4-byte boundaries.
    var payload_length = strl + 4;
    var result = new ArrayBuffer(payload_length);
    var view = new Rserve.EndianAwareDataView(result);
    view.setInt32(0, Rserve.Rsrv.DT_STRING + (strl << 8));
    for (var i=0; i<str.length; ++i)
        view.setInt8(4+i, str.charCodeAt(i));
    return result;
};

function _encode_bytes(bytes) {
    var payload_length = bytes.length;
    var header_length = 4;
    var result = new ArrayBuffer(payload_length + header_length);
    var view = new Rserve.EndianAwareDataView(result);
    view.setInt32(0, Rserve.Rsrv.DT_BYTESTREAM + (payload_length << 8));
    for (var i=0; i<bytes.length; ++i)
        view.setInt8(4+i, bytes[i]);
    return result;
};

Rserve.create = function(opts) {
    opts = _.defaults(opts || {}, {
        host: 'http://127.0.0.1:8081',
        on_connect: function() {}
    });
    var host = opts.host;
    var onconnect = opts.on_connect;
    var socket = new WebSocket(host);
    socket.binaryType = 'arraybuffer';
    var handle_error = opts.on_error || function(error) { throw new Rserve.RserveError(error, -1); };
    var received_handshake = false;

    var result;
    var command_counter = 0;

    var captured_functions = {};

    var fresh_hash = function() {
        var k;
        do {
            // while js has no crypto rngs :(
            k = String(Math.random()).slice(2,12);
        } while (k in captured_functions);
        if (k.length !== 10)
            throw new Error("Bad rng, no cookie");
        return k;
    };

    function convert_to_hash(value) {
        var hash = fresh_hash();
        captured_functions[hash] = value;
        return hash;
    }

    function _encode_value(value, forced_type)
    {
        var sz = Rserve.determine_size(value, forced_type);
        // all this will still break if sz is, say, >= 2^31.
        if (sz > 16777215) {
            var buffer = new ArrayBuffer(sz + 8);
            var view = Rserve.my_ArrayBufferView(buffer);
            // can't left shift value here because value will have bit 32 set and become signed..
            view.data_view().setInt32(0, Rserve.Rsrv.DT_SEXP + ((sz & 16777215) * Math.pow(2, 8)) + Rserve.Rsrv.DT_LARGE);
            // but *can* right shift because we assume sz is less than 2^31 or so to begin with
            view.data_view().setInt32(4, sz >>> 24);
            Rserve.write_into_view(value, view.skip(8), forced_type, convert_to_hash);
            return buffer;
        } else {
            var buffer = new ArrayBuffer(sz + 4);
            var view = Rserve.my_ArrayBufferView(buffer);
            view.data_view().setInt32(0, Rserve.Rsrv.DT_SEXP + (sz << 8));
            Rserve.write_into_view(value, view.skip(4), forced_type, convert_to_hash);
            return buffer;
        }
    }

    function hand_shake(msg)
    {
        msg = msg.data;
        if (typeof msg === 'string') {
            if (msg.substr(0,4) !== 'Rsrv') {
                handle_error("server is not an RServe instance", -1);
            } else if (msg.substr(4, 4) !== '0103') {
                handle_error("sorry, rserve only speaks the 0103 version of the R server protocol", -1);
            } else if (msg.substr(8, 4) !== 'QAP1') {
                handle_error("sorry, rserve only speaks QAP1", -1);
            } else {
                received_handshake = true;
                if (opts.login)
                    result.login(opts.login);
                result.running = true;
                onconnect && onconnect.call(result);
            }
        } else {
            var view = new DataView(msg);
            var header = String.fromCharCode(view.getUint8(0)) +
                String.fromCharCode(view.getUint8(1)) +
                String.fromCharCode(view.getUint8(2)) +
                String.fromCharCode(view.getUint8(3));

            if (header === 'RsOC') {
                received_handshake = true;
                result.ocap_mode = true;
                result.bare_ocap = Rserve.parse_payload(msg).value;
                result.ocap = Rserve.wrap_ocap(result, result.bare_ocap);
                result.running = true;
                onconnect && onconnect.call(result);
            } else
                handle_error("Unrecognized server answer: " + header, -1);
        }
    }

    socket.onclose = function(msg) {
        result.running = false;
        result.closed = true;
        opts.on_close && opts.on_close(msg);
    };

    socket.onmessage = function(msg) {
        // node.js Buffer vs ArrayBuffer workaround
        if (msg.data.constructor.name === 'Buffer')
            msg.data = (new Uint8Array(msg.data)).buffer;
        if (opts.debug)
            opts.debug.message_in && opts.debug.message_in(msg);
        if (!received_handshake) {
            hand_shake(msg);
            return;
        }
        if (typeof msg.data === 'string') {
            opts.on_raw_string && opts.on_raw_string(msg.data);
            return;
        }
        var v = Rserve.parse_websocket_frame(msg.data);
        if(v.incomplete)
            return;
        var msg_id = v.header[2], cmd = v.header[0] & 0xffffff;
        var queue = _.find(queues, function(queue) { return queue.msg_id == msg_id; });
        // console.log("onmessage, queue=" + (queue ? queue.name : "<unknown>") + ", ok= " + v.ok+ ", cmd=" + cmd +", msg_id="+ msg_id);
        // FIXME: in theory we should not need a fallback, but in case we miss some
        // odd edge case, we revert to the old behavior.
        // The way things work, the queue will be undefined only for OOB messages:
        // SEND doesn't need reply, so it's irrelevant, MSG is handled separately below and
        // enforces the right queue.
        if (!queue) queue = queues[0];
        if (!v.ok) {
            queue.result_callback([v.message, v.status_code], undefined);
            // handle_error(v.message, v.status_code);
        } else if (cmd === Rserve.Rsrv.RESP_OK) {
            queue.result_callback(null, v.payload);
        } else if (Rserve.Rsrv.IS_OOB_SEND(cmd)) {
            opts.on_data && opts.on_data(v.payload);
        } else if (Rserve.Rsrv.IS_OOB_MSG(cmd)) {
            // OOB MSG may use random msg_id, so we have to use the USR_CODE to detect the right queue
            // FIXME: we may want to consider adjusting the protocol specs to require msg_id
            //        to be retained by OOB based on the outer OCcall message (thus inheriting
            //        the msg_id), but curretnly it's not mandated.
            queue = (Rserve.Rsrv.OOB_USR_CODE(cmd) > 255) ? compute_queue : ctrl_queue;
            // console.log("OOB MSG result on queue "+ queue.name);
            var p;
            try {
                p = Rserve.wrap_all_ocaps(result, v.payload); // .value.json(result.resolve_hash);
            } catch (e) {
                _send_cmd_now(Rserve.Rsrv.RESP_ERR | cmd,
                              _encode_string(String(e)), msg_id);
                return;
            }
            if(_.isString(p[0])) {
                if (_.isUndefined(opts.on_oob_message)) {
                    _send_cmd_now(Rserve.Rsrv.RESP_ERR | cmd,
                                  _encode_string("No handler installed"), msg_id);
                } else {
                    queue.in_oob_message = true;
                    // breaking changes here: it appears that the callback had its arguments
                    // reversed from the standard (error, message), and was passing the message
                    // even on error
                    opts.on_oob_message(v.payload, function(error, result) {
                        if (!queue.in_oob_message) {
                            handle_error("Don't call oob_message_handler more than once.");
                            return;
                        }
                        queue.in_oob_message = false;
                        if(error) {
                            _send_cmd_now(cmd | Rserve.Rsrv.RESP_ERR, _encode_string(error), msg_id);
                        }
                        else {
                            _send_cmd_now(cmd | Rserve.Rsrv.RESP_OK, _encode_string(result), msg_id);
                        }
                        bump_queues();
                    });
                }
            }
            else if(_.isFunction(p[0])) {
                if(!result.ocap_mode) {
                    _send_cmd_now(Rserve.Rsrv.RESP_ERROR | cmd,
                                  _encode_string("JavaScript function calls only allowed in ocap mode"), msg_id);
                }
                else {
                    var captured_function = p[0], params = p.slice(1);
                    params.push(function(err, result) {
                        if (err) {
                            _send_cmd_now(Rserve.Rsrv.RESP_ERR | cmd, _encode_value(err), msg_id);
                        } else {
                            _send_cmd_now(cmd, _encode_value(result), msg_id);
                        }
                    });
                    captured_function.apply(undefined, params);
                }
            }
            else {
                _send_cmd_now(Rserve.Rsrv.RESP_ERROR | cmd,
                              _encode_string("Unknown oob message type: " + typeof(p[0])));
            }
        } else {
            handle_error("Internal Error, parse returned unexpected type " + v.header[0], -1);
        }
    };

    function _send_cmd_now(command, buffer, msg_id) {
        var big_buffer = _encode_command(command, buffer, msg_id);
        if (opts.debug)
            opts.debug.message_out && opts.debug.message_out(big_buffer[0], command);
        socket.send(big_buffer);
        return big_buffer;
    };

    var ctrl_queue = {
        queue: [],
        in_oob_message: false,
        awaiting_result: false,
        msg_id: 0,
        name: "control"
    };

    var compute_queue = {
        queue: [],
        in_oob_message: false,
        awaiting_result: false,
        msg_id: 1,
        name: "compute"
    };

    // the order matters - the first queue is used if the association cannot be determined from the msg_id/cmd
    var queues = [ ctrl_queue, compute_queue ];

    function queue_can_send(queue) { return !queue.in_oob_message && !queue.awaiting_result && queue.queue.length; }

    function bump_queues() {
        var available = _.filter(queues, queue_can_send);
        // nothing in the queues (or all busy)? get out
        if (!available.length) return;
        if (result.closed) {
            handle_error("Cannot send messages on a closed socket!", -1);
        } else {
            var queue = _.sortBy(available, function(queue) { return queue.queue[0].timestamp; })[0];
            var lst = queue.queue.shift();
            queue.result_callback = lst.callback;
            queue.awaiting_result = true;
            if (opts.debug)
                opts.debug.message_out && opts.debug.message_out(lst.buffer, lst.command);
            socket.send(lst.buffer);
        }
    }

    function enqueue(buffer, k, command, queue) {
        queue.queue.push({
            buffer: buffer,
          callback: function(error, result) {
              queue.awaiting_result = false;
              bump_queues();
              k(error, result);
          },
            command: command,
            timestamp: Date.now()
        });
        bump_queues();
    };

    function _cmd(command, buffer, k, string, queue) {
        // default to the first queue - only used in non-OCAP mode which doesn't support multiple queues
        if (!queue) queue = queues[0];

        k = k || function() {};
        var big_buffer = _encode_command(command, buffer, queue.msg_id);
        return enqueue(big_buffer, k, string, queue);
    };

    result = {
        ocap_mode: false,
        running: false,
        closed: false,
        close: function() {
            socket.close();
        },

        //////////////////////////////////////////////////////////////////////
        // non-ocap mode

        login: function(command, k) {
            _cmd(Rserve.Rsrv.CMD_login, _encode_string(command), k, command);
        },
        eval: function(command, k) {
            _cmd(Rserve.Rsrv.CMD_eval, _encode_string(command), k, command);
        },
        createFile: function(command, k) {
            _cmd(Rserve.Rsrv.CMD_createFile, _encode_string(command), k, command);
        },
        writeFile: function(chunk, k) {
            _cmd(Rserve.Rsrv.CMD_writeFile, _encode_bytes(chunk), k, "");
        },
        closeFile: function(k) {
            _cmd(Rserve.Rsrv.CMD_closeFile, new ArrayBuffer(0), k, "");
        },
        set: function(key, value, k) {
            _cmd(Rserve.Rsrv.CMD_setSEXP, [_encode_string(key), _encode_value(value)], k, "");
        },

        //////////////////////////////////////////////////////////////////////
        // ocap mode

        OCcall: function(ocap, values, k) {
            var is_ocap = false, str;
            try {
                is_ocap |= ocap.r_attributes['class'] === 'OCref';
                str = ocap[0];
            } catch (e) {};
            if(!is_ocap) {
                try {
                    is_ocap |= ocap.attributes.value[0].value.value[0] === 'OCref';
                    str = ocap.value[0];
                } catch (e) {};
            }
            if (!is_ocap) {
                k(new Error("Expected an ocap, instead got " + ocap), undefined);
                return;
            }
            var params = [str];
            params.push.apply(params, values);
            // determine the proper queue from the OCAP prefix
            var queue = (str.charCodeAt(0) == 64) ? compute_queue : ctrl_queue;
            _cmd(Rserve.Rsrv.CMD_OCcall, _encode_value(params, Rserve.Rsrv.XT_LANG_NOTAG),
                 k, "", queue);
        },

        wrap_ocap: function(ocap) {
            return Rserve.wrap_ocap(this, ocap);
        },

        resolve_hash: function(hash) {
            if (!(hash in captured_functions))
                throw new Error("hash " + hash + " not found.");
            return captured_functions[hash];
        }
    };
    return result;
};

Rserve.wrap_all_ocaps = function(s, v) {
    v = v.value.json(s.resolve_hash);
    function replace(obj) {
        var result = obj;
        if (_.isArray(obj) &&
            obj.r_attributes &&
            obj.r_attributes['class'] == 'OCref') {
            return Rserve.wrap_ocap(s, obj);
        } else if (_.isArray(obj)) {
            result = _.map(obj, replace);
            result.r_type = obj.r_type;
            result.r_attributes = obj.r_attributes;
        } else if (_.isTypedArray(obj)) {
            return obj;
        } else if (_.isFunction(obj)) {
            return obj;
        } else if (obj && !_.isUndefined(obj.byteLength) && !_.isUndefined(obj.slice)) { // ArrayBuffer
            return obj;
        } else if (_.isObject(obj)) {
            result = _.object(_.map(obj, function(v, k) {
                return [k, replace(v)];
            }));
        }
        return result;
    }
    return replace(v);
};

Rserve.wrap_ocap = function(s, ocap) {
    var wrapped_ocap = function() {
        var values = _.toArray(arguments);
        // common error (tho this won't catch the case where last arg is a function)
        if(!values.length || !_.isFunction(values[values.length-1]))
            throw new Error("forgot to pass continuation to ocap");
        var k = values.pop();
        s.OCcall(ocap, values, function(err, v) {
            if (!_.isUndefined(v))
                v = Rserve.wrap_all_ocaps(s, v);
            k(err, v);
        });
    };
    wrapped_ocap.bare_ocap = ocap;
    return wrapped_ocap;
};

})();
Rserve.RserveError = function(message, status_code) {
    this.name = "RserveError";
    this.message = message;
    this.status_code = status_code;
};

Rserve.RserveError.prototype = Object.create(Error);
Rserve.RserveError.prototype.constructor = Rserve.RserveError;
(function () {

_.mixin({
    isTypedArray: function(v) {
        if (!_.isObject(v))
            return false;
        return !_.isUndefined(v.byteLength) && !_.isUndefined(v.BYTES_PER_ELEMENT);
    }
});

// type_id tries to match some javascript values to Rserve value types
Rserve.type_id = function(value)
{
    if (_.isNull(value) || _.isUndefined(value))
        return Rserve.Rsrv.XT_NULL;
    var type_dispatch = {
        "boolean": Rserve.Rsrv.XT_ARRAY_BOOL,
        "number":  Rserve.Rsrv.XT_ARRAY_DOUBLE,
        "string":  Rserve.Rsrv.XT_ARRAY_STR // base strings need to be array_str or R gets confused?
    };
    if (!_.isUndefined(type_dispatch[typeof value]))
        return type_dispatch[typeof value];

    // typed arrays
    if (_.isTypedArray(value))
        return Rserve.Rsrv.XT_ARRAY_DOUBLE;

    // arraybuffers
    if (!_.isUndefined(value.byteLength) && !_.isUndefined(value.slice))
        return Rserve.Rsrv.XT_RAW;

    // lists of strings (important for tags)
    if (_.isArray(value) && _.all(value, function(el) { return typeof el === 'string'; }))
        return Rserve.Rsrv.XT_ARRAY_STR;

    if (_.isArray(value) && _.all(value, function(el) { return typeof el === 'boolean'; }))
        return Rserve.Rsrv.XT_ARRAY_BOOL;

    // arbitrary lists
    if (_.isArray(value))
        return Rserve.Rsrv.XT_VECTOR;

    // functions get passed as an array_str with extra attributes
    if (_.isFunction(value))
        return Rserve.Rsrv.XT_ARRAY_STR | Rserve.Rsrv.XT_HAS_ATTR;

    // objects
    if (_.isObject(value))
        return Rserve.Rsrv.XT_VECTOR | Rserve.Rsrv.XT_HAS_ATTR;

    throw new Rserve.RServeError("Value type unrecognized by Rserve: " + value);
};

// FIXME this is really slow, as it's walking the object many many times.
Rserve.determine_size = function(value, forced_type)
{
    function list_size(lst) {
        return _.reduce(lst, function(memo, el) {
            return memo + Rserve.determine_size(el);
        }, 0);
    }
    function final_size(payload_size) {
        if (payload_size > (1 << 24))
            return payload_size + 8; // large header
        else
            return payload_size + 4;
    }
    var header_size = 4, t = forced_type || Rserve.type_id(value);

    switch (t & ~Rserve.Rsrv.XT_LARGE) {
    case Rserve.Rsrv.XT_NULL:
        return final_size(0);
    case Rserve.Rsrv.XT_ARRAY_BOOL:
        if (_.isBoolean(value))
            return final_size(8);
        else
            return final_size((value.length + 7) & ~3);
    case Rserve.Rsrv.XT_ARRAY_STR:
        if (_.isArray(value))
            return final_size(_.reduce(value, function(memo, str) {
		// FIXME: this is a bit silly, since we'll be re-encoding this twice: once for the size and second time for the content
		var utf8 = unescape(encodeURIComponent(str));
                return memo + utf8.length + 1;
            }, 0));
        else {
	    var utf8 = unescape(encodeURIComponent(value));
            return final_size(utf8.length + 1);
	}
    case Rserve.Rsrv.XT_ARRAY_DOUBLE:
        if (_.isNumber(value))
            return final_size(8);
        else
            return final_size(8 * value.length);
    case Rserve.Rsrv.XT_RAW:
        return final_size(4 + value.byteLength);
    case Rserve.Rsrv.XT_VECTOR:
    case Rserve.Rsrv.XT_LANG_NOTAG:
        return final_size(list_size(value));
    case Rserve.Rsrv.XT_VECTOR | Rserve.Rsrv.XT_HAS_ATTR: // a named list (that is, a js object)
        var names_size_1 = final_size("names".length + 3);
        var names_size_2 = Rserve.determine_size(_.keys(value));
        var names_size = final_size(names_size_1 + names_size_2);
        return final_size(names_size + list_size(_.values(value)));
/*        return header_size // XT_VECTOR | XT_HAS_ATTR
            + header_size // XT_LIST_TAG (attribute)
              + header_size + "names".length + 3 // length of 'names' + padding (tag as XT_SYMNAME)
              + Rserve.determine_size(_.keys(value)) // length of names
            + list_size(_.values(value)); // length of values
*/
    case Rserve.Rsrv.XT_ARRAY_STR | Rserve.Rsrv.XT_HAS_ATTR: // js->r ocap (that is, a js function)
        return Rserve.determine_size("0403556553") // length of ocap nonce; that number is meaningless aside from length
            + header_size // XT_LIST_TAG (attribute)
              + header_size + "class".length + 3 // length of 'class' + padding (tag as XT_SYMNAME)
              + Rserve.determine_size(["javascript_function"]); // length of class name

    default:
        throw new Rserve.RserveError("Internal error, can't handle type " + t);
    }
};

Rserve.write_into_view = function(value, array_buffer_view, forced_type, convert)
{
    var size = Rserve.determine_size(value, forced_type);
    var is_large = size > 16777215;
    // if (size > 16777215)
    //     throw new Rserve.RserveError("Can't currently handle objects >16MB");
    var t = forced_type || Rserve.type_id(value), i, current_offset, lbl;
    if (is_large)
        t = t | Rserve.Rsrv.XT_LARGE;
    var read_view;
    var write_view = array_buffer_view.data_view();
    var payload_start;
    if (is_large) {
        payload_start = 8;
        write_view.setInt32(0, t + ((size - 8) << 8));
        write_view.setInt32(4, (size - 8) >>> 24);
    } else {
        payload_start = 4;
        write_view.setInt32(0, t + ((size - 4) << 8));
    }

    switch (t & ~Rserve.Rsrv.XT_LARGE) {
    case Rserve.Rsrv.XT_NULL:
        break;
    case Rserve.Rsrv.XT_ARRAY_BOOL:
        if (_.isBoolean(value)) {
            write_view.setInt32(payload_start, 1);
            write_view.setInt8(payload_start + 4, value ? 1 : 0);
        } else {
            write_view.setInt32(payload_start, value.length);
            for (i=0; i<value.length; ++i)
                write_view.setInt8(payload_start + 4 + i, value[i] ? 1 : 0);
        }
        break;
    case Rserve.Rsrv.XT_ARRAY_STR:
        if (_.isArray(value)) {
            var offset = payload_start;
            _.each(value, function(el) {
		var utf8 = unescape(encodeURIComponent(el));
                for (var i=0; i<utf8.length; ++i, ++offset)
                    write_view.setUint8(offset, utf8.charCodeAt(i));
                write_view.setUint8(offset++, 0);
            });
        } else {
	    var utf8 = unescape(encodeURIComponent(value));
            for (i=0; i<utf8.length; ++i)
                write_view.setUint8(payload_start + i, utf8.charCodeAt(i));
            write_view.setUint8(payload_start + utf8.length, 0);
        }
        break;
    case Rserve.Rsrv.XT_ARRAY_DOUBLE:
        if (_.isNumber(value))
            write_view.setFloat64(payload_start, value);
        else {
            for (i=0; i<value.length; ++i)
                write_view.setFloat64(payload_start + 8 * i, value[i]);
        }
        break;
    case Rserve.Rsrv.XT_RAW:
        read_view = new Rserve.EndianAwareDataView(value);
        write_view.setUint32(payload_start, value.byteLength);
        for (i=0; i<value.byteLength; ++i) {
            write_view.setUint8(payload_start + 4 + i, read_view.getUint8(i));
        }
        break;
    case Rserve.Rsrv.XT_VECTOR:
    case Rserve.Rsrv.XT_LANG_NOTAG:
        current_offset = payload_start;
        _.each(value, function(el) {
            var sz = Rserve.determine_size(el);
            Rserve.write_into_view(el, array_buffer_view.skip(
                current_offset), undefined, convert);
            current_offset += sz;
        });
        break;
    case Rserve.Rsrv.XT_VECTOR | Rserve.Rsrv.XT_HAS_ATTR:
        current_offset = payload_start + 8;
        _.each(_.keys(value), function(el) {
            for (var i=0; i<el.length; ++i, ++current_offset)
                write_view.setUint8(current_offset, el.charCodeAt(i));
            write_view.setUint8(current_offset++, 0);
        });
        write_view.setUint32(payload_start + 4, Rserve.Rsrv.XT_ARRAY_STR + ((current_offset - (payload_start + 8)) << 8));

        write_view.setUint32(current_offset, Rserve.Rsrv.XT_SYMNAME + (8 << 8));
        current_offset += 4;
        lbl = "names";
        for (i=0; i<lbl.length; ++i, ++current_offset)
            write_view.setUint8(current_offset, lbl.charCodeAt(i));
        current_offset += 3;

        write_view.setUint32(payload_start, Rserve.Rsrv.XT_LIST_TAG + ((current_offset - (payload_start + 4)) << 8));

        _.each(_.values(value), function(el) {
            var sz = Rserve.determine_size(el);
            Rserve.write_into_view(el, array_buffer_view.skip(
                current_offset), undefined, convert);
            current_offset += sz;
        });
        break;

    case Rserve.Rsrv.XT_ARRAY_STR | Rserve.Rsrv.XT_HAS_ATTR:
        var converted_function = convert(value);
        current_offset = payload_start + 8;
        var class_name = "javascript_function";
        for (i=0; i<class_name.length; ++i, ++current_offset)
            write_view.setUint8(current_offset, class_name.charCodeAt(i));
        write_view.setUint8(current_offset++, 0);
        write_view.setUint32(8, Rserve.Rsrv.XT_ARRAY_STR + ((current_offset - (payload_start + 8)) << 8));
        write_view.setUint32(current_offset, Rserve.Rsrv.XT_SYMNAME + (8 << 8));
        current_offset += 4;
        lbl = "class";
        for (i=0; i<lbl.length; ++i, ++current_offset)
            write_view.setUint8(current_offset, lbl.charCodeAt(i));
        current_offset += 3;
        write_view.setUint32(4, Rserve.Rsrv.XT_LIST_TAG + ((current_offset - (payload_start + 4)) << 8));
        for (i=0; i<converted_function.length; ++i)
            write_view.setUint8(current_offset + i, converted_function.charCodeAt(i));
        write_view.setUint8(current_offset + converted_function.length, 0);
        break;
    default:
        throw new Rserve.RserveError("Internal error, can't handle type " + t);
    }
};

})();
this.Rserve = Rserve;
})();

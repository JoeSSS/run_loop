      throw new Error('Namespace "' + name + '" already declared.');
    throw new Error("Importing test-only code into non-debug environment" + opt_message ? ": " + opt_message : ".");
    throw new Error(errorMessage);
  throw new Error("unimplemented abstract method");
              throw new Error("Undefined nameToPath for " + requireName);
        throw new Error("Undefined script input");
    throw new Error;
      throw new Error("goog.globalEval not available");
    throw new Error("goog.base called from a method of one name " + "to a method of a different name");
goog.provide("goog.debug.Error");
goog.debug.Error = function(opt_msg) {
  if(Error.captureStackTrace) {
    Error.captureStackTrace(this, goog.debug.Error)
    this.stack = (new Error).stack || ""
goog.inherits(goog.debug.Error, Error);
goog.debug.Error.prototype.name = "CustomError";
goog.provide("goog.asserts.AssertionError");
goog.require("goog.debug.Error");
goog.asserts.AssertionError = function(messagePattern, messageArgs) {
  goog.debug.Error.call(this, goog.string.subs.apply(null, messageArgs));
goog.inherits(goog.asserts.AssertionError, goog.debug.Error);
goog.asserts.AssertionError.prototype.name = "AssertionError";
  throw new goog.asserts.AssertionError("" + message, args || []);
    throw new goog.asserts.AssertionError("Failure" + (opt_message ? ": " + opt_message : ""), Array.prototype.slice.call(arguments, 1));
    throw new Error('The object already contains the key "' + key + '"');
    throw new Error("Uneven number of arguments");
    throw new Error("[goog.string.format] Template required");
      throw new Error("[goog.string.format] Not enough arguments");
  throw new Error("No *print-fn* fn set for evaluation environment");
  return new Error(["No protocol method ", proto, " defined for type ", goog.typeOf(obj), ": ", obj].join(""))
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Index out of bounds");
            throw new Error("Index out of bounds");
                throw new Error("Index out of bounds");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
            throw new Error("compare on non-nil objects of different types");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
  throw new Error("Can't pop empty list");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("-drop-first of empty chunk");
    throw new Error("Invalid arity: " + arguments.length);
          throw new Error("long-array called with something other than size or ISeq");
    throw new Error("Invalid arity: " + arguments.length);
          throw new Error("double-array called with something other than size or ISeq");
    throw new Error("Invalid arity: " + arguments.length);
          throw new Error("object-array called with something other than size or ISeq");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
                                            throw new Error("Only up to 20 arguments supported on functions");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error([cljs.core.str("Argument must be an integer: "), cljs.core.str(n)].join(""));
      throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
          throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
          throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Can't pop empty vector");
    throw new Error([cljs.core.str("No item "), cljs.core.str(i), cljs.core.str(" in vector of length "), cljs.core.str(pv.cnt)].join(""));
        throw new Error([cljs.core.str("Index "), cljs.core.str(k), cljs.core.str(" out of bounds  [0,"), cljs.core.str(self__.cnt), cljs.core.str("]")].join(""));
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Can't pop empty vector");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Can't pop empty vector");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error([cljs.core.str("No item "), cljs.core.str(i), cljs.core.str(" in transient vector of length "), cljs.core.str(tv.cnt)].join(""));
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("nth after persistent!");
    throw new Error("count after persistent!");
          throw new Error([cljs.core.str("Index "), cljs.core.str(n), cljs.core.str(" out of bounds for TransientVector of length"), cljs.core.str(self__.cnt)].join(""));
    throw new Error("assoc! after persistent!");
      throw new Error("Can't pop empty vector");
    throw new Error("pop! after persistent!");
    throw new Error("conj! after persistent!");
    throw new Error("persistent! called twice");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("dissoc! after persistent!");
    throw new Error("assoc! after persistent!");
    throw new Error("conj! after persistent!");
    throw new Error("persistent! called twice");
    throw new Error("lookup after persistent!");
    throw new Error("count after persistent!");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("count after persistent!");
    throw new Error("conj! after persistent");
    throw new Error("assoc! after persistent!");
    throw new Error("dissoc! after persistent!");
    throw new Error("persistent! called twice");
          throw new Error("red-black tree invariant violation");
          throw new Error("red-black tree invariant violation");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
  throw new Error("red-black tree invariant violation");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
        throw new Error([cljs.core.str("Doesn't support name: "), cljs.core.str(x)].join(""));
    throw new Error([cljs.core.str("Doesn't support namespace: "), cljs.core.str(x)].join(""));
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
      throw new Error("Index out of bounds");
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
        throw new Error("Invalid arity: " + arguments.length);
          throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
      throw new Error([cljs.core.str("Assert failed: "), cljs.core.str("Validator rejected reference state"), cljs.core.str("\n"), cljs.core.str(cljs.core.pr_str.call(null, cljs.core.with_meta(cljs.core.list("\ufdd1'validate", "\ufdd1'new-value"), cljs.core.hash_map("\ufdd0'line", 6700))))].join(""));
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
      throw new Error([cljs.core.str("Assert failed: "), cljs.core.str(cljs.core.pr_str.call(null, cljs.core.with_meta(cljs.core.list("\ufdd1'namespace", "\ufdd1'parent"), cljs.core.hash_map("\ufdd0'line", 6984))))].join(""));
      throw new Error([cljs.core.str("Assert failed: "), cljs.core.str(cljs.core.pr_str.call(null, cljs.core.with_meta(cljs.core.list("\ufdd1'not=", "\ufdd1'tag", "\ufdd1'parent"), cljs.core.hash_map("\ufdd0'line", 6988))))].join(""));
        throw new Error([cljs.core.str(tag), cljs.core.str("already has"), cljs.core.str(parent), cljs.core.str("as ancestor")].join(""));
        throw new Error([cljs.core.str("Cyclic derivation:"), cljs.core.str(parent), cljs.core.str("has"), cljs.core.str(tag), cljs.core.str("as ancestor")].join(""));
    throw new Error("Invalid arity: " + arguments.length);
    throw new Error("Invalid arity: " + arguments.length);
        throw new Error([cljs.core.str("Multiple methods in multimethod '"), cljs.core.str(name), cljs.core.str("' match dispatch value: "), cljs.core.str(dispatch_val), cljs.core.str(" -> "), cljs.core.str(k), cljs.core.str(" and "), cljs.core.str(cljs.core.first.call(null, be2)), cljs.core.str(", and neither is preferred")].join(""));
    throw new Error([cljs.core.str("No method in multimethod '"), cljs.core.str(cljs.core.name), cljs.core.str("' for dispatch value: "), cljs.core.str(dispatch_val)].join(""));
    throw new Error([cljs.core.str("Preference conflict in multimethod '"), cljs.core.str(self__.name), cljs.core.str("': "), cljs.core.str(dispatch_val_y), cljs.core.str(" is already preferred to "), cljs.core.str(dispatch_val_x)].join(""));
    throw new Error(reason);
    throw new Error("Invalid arity: " + arguments.length);

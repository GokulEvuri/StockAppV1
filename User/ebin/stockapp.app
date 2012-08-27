{application, stockapp,
 [
  {description, "stock market application"},
  {vsn, "1.0"},
  {id, "stockserver"},
  {modules,      []},
  {registered,   []},
  {applications, [kernel, stdlib,sasl]},
  {mod, {test, []}},
  {env, []}
 ]
}.
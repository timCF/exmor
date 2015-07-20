Exmor
=====

Usage
-----

If you want, you can declare os (linux | mac) in config, else application will recognize it automatically on start. If you want, you can declare also predicate, that will check eval string or not.

```
config :exmor, 
	os: "linux", 
	pred: &MyModule.pred/1
```

Next, you can use eval function in your code

```
Exmor.eval "привет всем мирам"
%Exmor.Parsed{error: [], info: "",
 ok: ["привету", "миро", "мир", "всего", "всея",
  "привете", "приветам", "всеми", "мира", "миру",
  "всём", "привет", "всех", "привета", "мирами",
  "всем", "вся", "всё", "миров", "мире",
  "приветами", "всей", "мирам", "все", "приветы",
  "приветов", "весь", "миром", "приветом", "всю",
  "мирах", "миры", "приветах", "всему"]}

Exmor.eval ["привет","всем","мирам"]
%Exmor.Parsed{error: [], info: "",
 ok: ["весь", "все", "приветом", "миру", "мир",
  "привета", "всего", "миро", "миров", "мирами",
  "всей", "вся", "мирах", "всё", "мирам", "привете",
  "всём", "приветами", "привет", "миром", "мире",
  "всея", "миры", "всю", "привету", "всему",
  "приветах", "всех", "приветы", "приветам",
  "всем", "всеми", "приветов", "мира"]}
```

Some else examples in tests.
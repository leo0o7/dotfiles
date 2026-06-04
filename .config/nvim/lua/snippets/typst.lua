local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"preamble",
		fmt(
			[[
#import "@preview/theorion:0.6.0": *
#import cosmos.fancy: *
#show: show-theorion

#set heading(numbering: "1.1")

= {}

{}
]],
			{
				i(1, "Title"),
				i(2),
			}
		)
	),
	s("sec", fmt("= {}", { i(1, "Section") })),
	s("ssec", fmt("== {}", { i(1, "Subsection") })),

	s(
		"def",
		fmt(
			[[
#definition[{}][
  {}
] <def:{}>
]],
			{ i(1, "Name"), i(2), i(3, "label") }
		)
	),

	s(
		"thm",
		fmt(
			[[
#theorem[{}][
  {}
] <thm:{}>
]],
			{ i(1, "Name"), i(2), i(3, "label") }
		)
	),

	s(
		"lem",
		fmt(
			[[
#lemma[
  {}
] <lem:{}>
]],
			{ i(1), i(2, "label") }
		)
	),

	s(
		"cor",
		fmt(
			[[
#corollary[
  {}
] <cor:{}>
]],
			{ i(1), i(2, "label") }
		)
	),

	s(
		"ex",
		fmt(
			[[
#example[
  {}
]
]],
			{ i(1) }
		)
	),

	s(
		"rmk",
		fmt(
			[[
#remark-block[
  {}
]
]],
			{ i(1) }
		)
	),

	s(
		"pf",
		fmt(
			[[
#proof[{}][
  {}
]
]],
			{ i(1, "Proof of @thm:name"), i(2) }
		)
	),

	s(
		"prob",
		fmt(
			[[
#problem[
  {}
]
]],
			{ i(1) }
		)
	),

	s(
		"sol",
		fmt(
			[[
#solution(qed: auto)[
  {}
]
]],
			{ i(1) }
		)
	),

	s(
		"exr",
		fmt(
			[[
#exercise[
  {}
]
]],
			{ i(1) }
		)
	),

	s(
		"eq",
		fmt(
			[[
$ {} $ <eq:{}>
]],
			{ i(1), i(2, "label") }
		)
	),

	s(
		"al",
		fmt(
			[[
$ {}
  &= {} \
  &= {} $ <eq:{}>
]],
			{ i(1), i(2), i(3), i(4, "label") }
		)
	),

	s(
		"cases",
		fmt(
			[[
$ {} := cases(
  ({}, {}),
  ({}, {}),
) $
]],
			{
				i(1, "f(x)"),
				i(2, "expr1"),
				i(3, "cond1"),
				i(4, "expr2"),
				i(5, "cond2"),
			}
		)
	),

	s(
		"sum",
		fmt("$ sum_({} = {})^{} {} $", {
			i(1, "k"),
			i(2, "1"),
			i(3, "n"),
			i(4, "a_k"),
		})
	),

	s(
		"lim",
		fmt("$ lim_({} -> {}) {} $", {
			i(1, "n"),
			i(2, "inf"),
			i(3, "a_n"),
		})
	),

	s(
		"mat",
		fmt(
			[[
$ mat(
  {}, {};
  {}, {}
) $
]],
			{
				i(1, "a"),
				i(2, "b"),
				i(3, "c"),
				i(4, "d"),
			}
		)
	),
}

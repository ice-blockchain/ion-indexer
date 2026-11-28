import ast
from pathlib import Path
from types import SimpleNamespace
import unittest


class ExclusiveMatcherNullableTest(unittest.TestCase):
    def test_nullable_predicates(self):
        # Isolate the predicate from optional native classifier dependencies.
        source = Path(__file__).parents[1] / "indexer/events/blocks/basic_matchers.py"
        tree = ast.parse(source.read_text())
        cls = next(n for n in tree.body if isinstance(n, ast.ClassDef)
                   and n.name == "ExclusiveOrMatcher")
        method = next(n for n in cls.body if isinstance(n, ast.FunctionDef)
                      and n.name == "test_self")
        namespace = {"Block": object}
        exec(compile(ast.Module(body=[method], type_ignores=[]), str(source), "exec"), namespace)
        for values, expected in [([None, True], True), ([None, False], False),
                                 ([True, True], False), ([None, None], False), ([], False)]:
            with self.subTest(values=values):
                obj = SimpleNamespace(matchers=[SimpleNamespace(test_self=lambda b, v=v: v)
                                                for v in values])
                self.assertEqual(namespace["test_self"](obj, None), expected)


if __name__ == "__main__":
    unittest.main()

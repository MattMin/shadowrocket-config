"""运行：python3 scripts/check-config.py"""
from pathlib import Path

root = Path(__file__).resolve().parent.parent
sections = {}
section = None
for raw in (root / 'shadowrocket.conf').read_text().splitlines():
    line = raw.strip()
    if not line or line.startswith('#'):
        continue
    if line.startswith('['):
        section = line
        sections[section] = []
    else:
        sections[section].append(line)

groups = {line.split('=', 1)[0].strip() for line in sections['[Proxy Group]']}
policies = groups | {'DIRECT', 'REJECT', 'PROXY'}
references = []
for line in sections['[Rule]']:
    fields = line.split(',')
    assert fields[-1] in policies, f'未定义的策略：{line}'
    if fields[0] == 'RULE-SET':
        name = fields[1].rsplit('/', 1)[-1]
        references.append(name)
        rules = (root / 'rules' / name).read_text().splitlines()
        assert any(rule and not rule.startswith('#') for rule in rules), name
        assert not any(rule.startswith('HOST') for rule in rules), name
        for rule in rules:
            if rule and not rule.startswith('#'):
                parts = rule.split(',')
                assert len(parts) == 2 or (len(parts) == 3 and parts[2] == 'no-resolve'), (name, rule)

assert references.index('TikTok.list') < references.index('China.list')
assert any(line.endswith('/TikTok.list,TikTok') for line in sections['[Rule]'])
china = [line for line in (root / 'rules/China.list').read_text().splitlines()
         if line and not line.startswith('#')]
assert len(china) == len(set(china)), 'China 存在重复规则'
print(f'检查通过：{len(references)} 个规则集，策略名称、TikTok 顺序、规则格式及 China 去重正常')

"""运行：python3 scripts/check-config.py"""
from pathlib import Path
import re

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
                if name in {'Apple.list', 'Global.list', 'China.list'} and parts[0] in {'IP-CIDR', 'IP6-CIDR', 'IP-CIDR6'}:
                    assert parts[2:] == ['no-resolve'], (name, rule)

assert references.index('AWAvenue-Ads.list') < references.index('KRAK.list')
assert references.index('TikTok.list') < references.index('China.list')
assert any(line.endswith('/TikTok.list,TikTok') for line in sections['[Rule]'])
china = [line for line in (root / 'rules/China.list').read_text().splitlines()
         if line and not line.startswith('#')]
assert len(china) == len(set(china)), 'China 存在重复规则'
hong_kong = next(line for line in sections['[Proxy Group]'] if line.startswith('香港节点 ='))
node_filter = re.compile(hong_kong.split('policy-regex-filter=', 1)[1])
assert node_filter.search('香港-01')
for node in ['香港-IPV6-01', 'IPV6-香港-01', '香港-ipv6-01', '香港-直连-01', '日本-01']:
    assert not node_filter.search(node), f'香港节点筛选错误：{node}'
print(f'检查通过：{len(references)} 个规则集，策略、优先级、IP 规则、China 去重及香港节点筛选正常')

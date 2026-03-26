#!/bin/bash
python3 -c "
import json
with open('/config/web.conf', 'r') as f:
    c = json.load(f)
c['enabled_plugins'] = ['Label']
with open('/config/web.conf', 'w') as f:
    json.dump(c, f, indent=4)
print('Label plugin enabled in web.conf')
"

import sys
import re
import json

if len(sys.argv) != 3:
    print("Usage: python3 clean_data.py <input_file> <output_file>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

# Read invalid json file
with open(input_file, 'r', encoding='utf-8') as f:
    content = f.read()

# This converts to valid JSON string keys
content = re.sub(r':([a-zA-Z_]+)\s*=>', r'"\1":', content)

try:
    # Parse as a JSON array
    data = json.loads(content)
except json.JSONDecodeError as e:
    print(f"Error parsing JSON: {e}")
    sys.exit(1)

# Write out as JSON Lines
with open(output_file, 'w', encoding='utf-8') as f:
    for item in data:
        f.write(json.dumps(item) + '\n')
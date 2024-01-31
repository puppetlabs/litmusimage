import json
import os
from re import match

# parse workflow inputs
image = os.environ['image']
dockerfile = os.environ['dockerfile']
refresh = True if os.environ['refresh'] == "true" else False

# output
matrix = []

# load matrix json
with open('images.json') as fd:
    builds = json.load(fd)
    for i, v in enumerate(builds):
        builds[i]['image_tag'] = f"{v['image']}:{v['tag']}"
        builds[i]['base_image_tag'] = f"{v['base_image']}:{v['base_tag']}"
        builds[i]['refresh'] = refresh

if dockerfile:
    dockerfile = f"^{dockerfile}$"
    for _, v in enumerate(builds):
        if match(dockerfile, v['dockerfile']):
            # always refresh
            v['refresh'] = True
            matrix.append(v)

if image:
    image = f"^{image}$" if image else image
    for _, v in enumerate(builds):
        if match(image, v['image_tag']):
            matrix.append(v)

# unique list of images
matrix = list({v['image_tag']:v for v in matrix}.values())

if len(matrix) == 0:
    print("::error title::failed to build matrix, no images matched?")
    raise SystemExit(1)

with open(os.environ['GITHUB_OUTPUT'], 'a') as output:
    print('matrix=' + json.dumps({ 'include': matrix }), file=output)
